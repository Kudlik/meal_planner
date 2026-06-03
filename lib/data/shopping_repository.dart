import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class ShoppingRepository {
  static const _fileName = 'shopping_overrides.json';

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<ShoppingOverrides> load() async {
    final file = await _file();
    if (!await file.exists()) return ShoppingOverrides([], [], {});
    try {
      final raw = await file.readAsString();
      final data = json.decode(raw) as Map<String, dynamic>;
      final manuals = (data['manuals'] as List? ?? [])
          .map((e) => ManualItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final overrides = (data['overrides'] as List? ?? [])
          .map((e) => QuantityOverride.fromJson(e as Map<String, dynamic>))
          .toList();
      final bought = (data['bought'] as List? ?? [])
          .map((e) => e as String)
          .toSet();
      return ShoppingOverrides(manuals, overrides, bought);
    } catch (_) {
      return ShoppingOverrides([], [], {});
    }
  }

  Future<void> save(
    List<ManualItem> manuals,
    List<QuantityOverride> overrides,
    Set<String> bought,
  ) async {
    final file = await _file();
    await file.writeAsString(json.encode({
      'manuals': manuals.map((m) => m.toJson()).toList(),
      'overrides': overrides.map((o) => o.toJson()).toList(),
      'bought': bought.toList(),
    }));
  }
}

class ShoppingOverrides {
  final List<ManualItem> manuals;
  final List<QuantityOverride> overrides;
  final Set<String> bought;
  ShoppingOverrides(this.manuals, this.overrides, this.bought);
}
