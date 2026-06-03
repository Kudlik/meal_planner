import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/recipe_repository.dart';
import '../data/plan_repository.dart';
import '../data/shopping_repository.dart';
import '../data/plan_export_service.dart';

class AppState extends ChangeNotifier {
  final RecipeRepository _recipes = RecipeRepository();
  final PlanRepository _planRepo = PlanRepository();
  final ShoppingRepository _shoppingRepo = ShoppingRepository();

  List<PlanSlot> _slots = [];
  List<ManualItem> _manuals = [];
  List<QuantityOverride> _quantityOverrides = [];
  Set<String> _boughtItems = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<PlanSlot> get slots => _slots;

  Future<void> init() async {
    await _recipes.load();
    _slots = await _planRepo.load();
    if (_slots.isEmpty) _slots = _planRepo.emptySlots();
    final overrides = await _shoppingRepo.load();
    _manuals = overrides.manuals;
    _quantityOverrides = overrides.overrides;
    _boughtItems = overrides.bought;
    _isLoaded = true;
    notifyListeners();
  }

  // --- Menu ---

  List<Meal> mealsForType(String rawMealType) =>
      _recipes.mealsForType(rawMealType);

  PlanSlot? slotFor(String dayKey, String rawMealType) {
    try {
      return _slots.firstWhere(
        (s) => s.dayKey == dayKey && s.rawMealType == rawMealType,
      );
    } catch (_) {
      return null;
    }
  }

  void assignMeal(String dayKey, String rawMealType, String mealName) {
    final slot = slotFor(dayKey, rawMealType);
    if (slot != null) {
      slot.mealName = mealName;
      _planRepo.save(_slots);
      notifyListeners();
    }
  }

  void removeFromSlot(String dayKey, String rawMealType) {
    final slot = slotFor(dayKey, rawMealType);
    if (slot != null) {
      slot.mealName = null;
      _planRepo.save(_slots);
      notifyListeners();
    }
  }

  void clearPlan() {
    for (final slot in _slots) {
      slot.mealName = null;
    }
    _manuals.clear();
    _quantityOverrides.clear();
    _boughtItems.clear();
    _planRepo.save(_slots);
    _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
    notifyListeners();
  }

  Meal? mealInfo(String name) => _recipes.findMeal(name);

  // --- Shopping list ---

  List<ShoppingItem> get shoppingItems {
    // Collect assigned meal names (same meal can appear multiple times)
    final assignedMeals = _slots
        .where((s) => s.mealName != null)
        .map((s) => s.mealName!)
        .toList();

    // Sum ingredients across all assigned meals (quantity × 2 for 2 people)
    final totals = <String, ShoppingItem>{};
    for (final mealName in assignedMeals) {
      for (final ing in _recipes.ingredientsForMeal(mealName)) {
        if (totals.containsKey(ing.name)) {
          totals[ing.name]!.quantity += ing.quantityPer1 * 4;
        } else {
          totals[ing.name] = ShoppingItem(
            name: ing.name,
            unit: ing.unit,
            quantity: ing.quantityPer1 * 4,
            category: ing.category,
          );
        }
      }
    }

    // Apply quantity overrides as deltas so totals still scale with meals
    for (final override in _quantityOverrides) {
      if (totals.containsKey(override.itemName)) {
        totals[override.itemName]!.quantity += override.delta;
        totals[override.itemName]!.unit = override.unit;
      }
    }

    const categoryOrder = [
      'owoce', 'warzywa', 'konserwowe', 'pieczywo', 'tłuszcze',
      'słodycze', 'nabiał', 'mięso', 'sypkie', 'mrożonki', 'higiena',
    ];

    int categoryRank(String? cat) {
      if (cat == null) return categoryOrder.length;
      final i = categoryOrder.indexOf(cat.toLowerCase());
      return i == -1 ? categoryOrder.length : i;
    }

    final result = totals.values.toList()
      ..sort((a, b) {
        final cmp = categoryRank(a.category).compareTo(categoryRank(b.category));
        return cmp != 0 ? cmp : a.name.compareTo(b.name);
      });

    final manualItems = _manuals.map((m) {
      final qty = double.tryParse(
        m.quantity.replaceAll(RegExp(r'[^0-9.]'), ''),
      ) ?? 0.0;
      final unit = m.quantity.replaceAll(RegExp(r'[0-9. ]'), '').trim();
      return ShoppingItem(
        name: m.name,
        unit: unit,
        quantity: qty,
        category: m.category,
        isManual: true,
      );
    }).toList();

    return [...result, ...manualItems]
      ..sort((a, b) {
        final cmp = categoryRank(a.category).compareTo(categoryRank(b.category));
        return cmp != 0 ? cmp : a.name.compareTo(b.name);
      });
  }

  bool get isShoppingListEmpty =>
      _slots.every((s) => s.mealName == null) && _manuals.isEmpty;

  bool isBought(String name) => _boughtItems.contains(name);

  void toggleBought(String name) {
    if (_boughtItems.contains(name)) {
      _boughtItems.remove(name);
    } else {
      _boughtItems.add(name);
    }
    _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
    notifyListeners();
  }

  double _computedQuantity(String itemName) {
    double total = 0.0;
    for (final mealName in _slots.where((s) => s.mealName != null).map((s) => s.mealName!)) {
      for (final ing in _recipes.ingredientsForMeal(mealName)) {
        if (ing.name == itemName) total += ing.quantityPer1 * 4;
      }
    }
    return total;
  }

  void updateItemQuantity(String itemName, double newQty, String unit) {
    final delta = newQty - _computedQuantity(itemName);
    _quantityOverrides.removeWhere((o) => o.itemName == itemName);
    if (delta != 0) {
      _quantityOverrides.add(QuantityOverride(
        itemName: itemName,
        delta: delta,
        unit: unit,
      ));
    }
    _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
    notifyListeners();
  }

  void addManualItem(String name, String quantity, String? category) {
    _manuals.insert(0, ManualItem(name: name, quantity: quantity, category: category));
    _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
    notifyListeners();
  }

  void updateManualItem(String oldName, String newName, String quantity, String? category) {
    final index = _manuals.indexWhere((m) => m.name == oldName);
    if (index != -1) {
      _manuals[index] = ManualItem(name: newName, quantity: quantity, category: category);
      _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
      notifyListeners();
    }
  }

  // --- Export / Import ---

  final _exportService = PlanExportService();

  Future<void> exportPlan() async {
    final payload = _exportService.buildExportJson(_slots, _manuals, _quantityOverrides);
    await _exportService.share(payload);
  }

  // Returns null on success, an error message string on failure, or empty string if cancelled.
  Future<String?> importPlan() async {
    final ImportResult result;
    try {
      result = await _exportService.pickAndParse();
    } catch (e) {
      return e.toString();
    }
    if (result.cancelled) return '';
    _slots = result.slots!;
    _manuals = result.manuals!;
    _quantityOverrides = result.overrides!;
    _boughtItems = {};
    await _planRepo.save(_slots);
    await _shoppingRepo.save(_manuals, _quantityOverrides, _boughtItems);
    notifyListeners();
    return null;
  }
}
