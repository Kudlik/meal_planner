import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class PlanRepository {
  static const _householdId = 'household_01';
  static const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];
  static const _rawMealTypes = ['Śniadanie', 'Deser', 'Lunch', 'Kolacja'];

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('households').doc(_householdId);

  // Writes only the given slot. Merge-set deep-merges nested maps, so a
  // cleared slot must be removed explicitly with FieldValue.delete().
  Future<void> saveSlot(PlanSlot slot) {
    final key = '${slot.dayKey}|${slot.rawMealType}';
    return _doc.set({
      'plan': {key: slot.mealName ?? FieldValue.delete()},
      'slotStatuses': {key: slot.status ?? FieldValue.delete()},
    }, SetOptions(merge: true));
  }

  Future<void> clear() => _doc.set({
        'plan': FieldValue.delete(),
        'slotStatuses': FieldValue.delete(),
      }, SetOptions(merge: true));

  List<PlanSlot> emptySlots() => [
    for (final day in _dayKeys)
      for (final type in _rawMealTypes)
        PlanSlot(dayKey: day, rawMealType: type),
  ];

  static List<PlanSlot> slotsFromMap(
    Map<String, dynamic>? planMap, [
    Map<String, dynamic>? statusMap,
  ]) {
    planMap ??= {};
    statusMap ??= {};
    return [
      for (final day in _dayKeys)
        for (final type in _rawMealTypes)
          PlanSlot(
            dayKey: day,
            rawMealType: type,
            mealName: planMap['$day|$type'] as String?,
            status: statusMap['$day|$type'] as String?,
          ),
    ];
  }
}
