import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class ShoppingRepository {
  static const _householdId = 'household_01';

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('households').doc(_householdId);

  Future<void> save(
    List<ManualItem> manuals,
    List<QuantityOverride> overrides,
    Set<String> bought,
  ) =>
      _doc.set({
        'manualItems': manuals.map((m) => m.toJson()).toList(),
        'quantityOverrides': overrides.map((o) => o.toJson()).toList(),
        'boughtItems': bought.toList(),
      }, SetOptions(merge: true));

  static ShoppingOverrides overridesFromMap(Map<String, dynamic> data) {
    final manuals = (data['manualItems'] as List? ?? [])
        .map((e) => ManualItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final overrides = (data['quantityOverrides'] as List? ?? [])
        .map((e) => QuantityOverride.fromJson(e as Map<String, dynamic>))
        .toList();
    final bought = (data['boughtItems'] as List? ?? [])
        .map((e) => e as String)
        .toSet();
    return ShoppingOverrides(manuals, overrides, bought);
  }
}

class ShoppingOverrides {
  final List<ManualItem> manuals;
  final List<QuantityOverride> overrides;
  final Set<String> bought;
  ShoppingOverrides(this.manuals, this.overrides, this.bought);
}
