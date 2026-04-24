import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class RecipeRepository {
  List<Meal> _meals = [];
  List<Ingredient> _ingredients = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data.json');
    final data = json.decode(raw) as Map<String, dynamic>;

    // Build category map from SKŁADNIKI_X_OSÓB: ingredient name → category
    final categoryMap = <String, String>{};
    for (final item in data['SKŁADNIKI_X_OSÓB'] as List) {
      final name = item['Składnik'] as String?;
      final cat = item['Typ produktu'] as String?;
      if (name != null && cat != null) categoryMap[name] = cat;
    }

    // Build ingredient page/source map from BAZA_PRZEPISÓW
    // meal name → {Plik, Strona} (all ingredients of a meal share the same book/page)
    final mealSourceMap = <String, (String, int)>{};
    _ingredients = [];
    for (final item in data['BAZA_PRZEPISÓW'] as List) {
      final mealName = item['Nazwa_dania'] as String? ?? '';
      final skladnik = item['Składnik'] as String? ?? '';
      final qtyRaw = item['Gramatura_na_1_porcję'];
      final qty = qtyRaw == null ? 0.0 : (qtyRaw is num ? qtyRaw.toDouble() : double.tryParse(qtyRaw.toString()) ?? 0.0);
      final unit = item['Jednostka'] as String? ?? '';
      final plik = item['Plik'] as String? ?? '';
      final stronaRaw = item['Strona'];
      final strona = stronaRaw == null ? 0 : (stronaRaw is num ? stronaRaw.toInt() : int.tryParse(stronaRaw.toString()) ?? 0);

      if (!mealSourceMap.containsKey(mealName)) {
        mealSourceMap[mealName] = (plik, strona);
      }

      _ingredients.add(Ingredient(
        mealName: mealName,
        name: skladnik,
        quantityPer1: qty,
        unit: unit,
        category: categoryMap[skladnik],
      ));
    }

    // Build meals from WYBÓR_DAŃ
    _meals = [];
    for (final item in data['WYBÓR_DAŃ'] as List) {
      final name = item['Nazwa_dania'] as String? ?? '';
      final typ = item['Typ_posiłku'] as String? ?? '';
      final source = mealSourceMap[name];
      _meals.add(Meal(
        name: name,
        rawMealType: typ,
        source: source?.$1 ?? '',
        page: source?.$2 ?? 0,
      ));
    }

    _loaded = true;
  }

  List<Meal> mealsForType(String rawMealType) =>
      _meals.where((m) => m.rawMealType == rawMealType).toList();

  List<Ingredient> ingredientsForMeal(String mealName) =>
      _ingredients.where((i) => i.mealName == mealName).toList();

  Meal? findMeal(String name) {
    try {
      return _meals.firstWhere((m) => m.name == name);
    } catch (_) {
      return null;
    }
  }
}
