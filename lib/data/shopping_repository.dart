import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

// Each edit touches only its own array element (arrayUnion/arrayRemove), so
// concurrent edits from different devices don't overwrite each other.
class ShoppingRepository {
  static const _householdId = 'household_01';

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('households').doc(_householdId);

  Future<void> _merge(Map<String, dynamic> data) =>
      _doc.set(data, SetOptions(merge: true));

  // Removes [oldValues] then adds [newValue] in one atomic batch. Firestore
  // doesn't allow arrayRemove and arrayUnion on the same field in one write.
  Future<void> _replaceInArray(
    String field,
    List<Map<String, dynamic>> oldValues,
    Map<String, dynamic>? newValue,
  ) {
    final batch = FirebaseFirestore.instance.batch();
    if (oldValues.isNotEmpty) {
      batch.set(_doc, {field: FieldValue.arrayRemove(oldValues)},
          SetOptions(merge: true));
    }
    if (newValue != null) {
      batch.set(_doc, {field: FieldValue.arrayUnion([newValue])},
          SetOptions(merge: true));
    }
    return batch.commit();
  }

  Future<void> setBought(String name, bool bought) => _merge({
        'boughtItems': bought
            ? FieldValue.arrayUnion([name])
            : FieldValue.arrayRemove([name]),
      });

  Future<void> replaceOverride(
    List<QuantityOverride> old,
    QuantityOverride? replacement,
  ) =>
      _replaceInArray(
        'quantityOverrides',
        old.map((o) => o.toJson()).toList(),
        replacement?.toJson(),
      );

  Future<void> addManual(ManualItem item) =>
      _merge({'manualItems': FieldValue.arrayUnion([item.toJson()])});

  Future<void> replaceManual(ManualItem old, ManualItem replacement) =>
      _replaceInArray('manualItems', [old.toJson()], replacement.toJson());

  Future<void> clear() => _merge({
        'manualItems': [],
        'quantityOverrides': [],
        'boughtItems': [],
      });

  static ShoppingOverrides overridesFromMap(Map<String, dynamic> data) {
    final manuals = (data['manualItems'] as List? ?? [])
        .map((e) => ManualItem.fromJson(e as Map<String, dynamic>))
        .toList();
    // Concurrent edits of the same item can leave two overrides; keep the last.
    final overridesByItem = <String, QuantityOverride>{};
    for (final e in data['quantityOverrides'] as List? ?? []) {
      final o = QuantityOverride.fromJson(e as Map<String, dynamic>);
      overridesByItem[o.itemName] = o;
    }
    final bought = (data['boughtItems'] as List? ?? [])
        .map((e) => e as String)
        .toSet();
    return ShoppingOverrides(manuals, overridesByItem.values.toList(), bought);
  }
}

class ShoppingOverrides {
  final List<ManualItem> manuals;
  final List<QuantityOverride> overrides;
  final Set<String> bought;
  ShoppingOverrides(this.manuals, this.overrides, this.bought);
}
