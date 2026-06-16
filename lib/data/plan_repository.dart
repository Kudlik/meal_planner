import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class PlanRepository {
  static const _householdId = 'household_01';
  static const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];
  static const _rawMealTypes = ['Śniadanie', 'Deser', 'Lunch', 'Kolacja'];

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.collection('households').doc(_householdId);

  Future<void> save(List<PlanSlot> slots) {
    final map = <String, dynamic>{};
    final statusMap = <String, dynamic>{};
    for (final slot in slots) {
      if (slot.mealName != null) {
        map['${slot.dayKey}|${slot.rawMealType}'] = slot.mealName;
      }
      if (slot.status != null) {
        statusMap['${slot.dayKey}|${slot.rawMealType}'] = slot.status;
      }
    }
    return _doc.set({'plan': map, 'slotStatuses': statusMap}, SetOptions(merge: true));
  }

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
