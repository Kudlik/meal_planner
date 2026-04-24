import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class PlanRepository {
  static const _fileName = 'plan.json';

  static const _dayKeys = ['1-2', '3-4', '5-6', '7-8'];
  static const _rawMealTypes = ['Śniadanie', 'Deser', 'Lunch', 'Kolacja'];

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<PlanSlot>> load() async {
    final file = await _file();
    if (!await file.exists()) return _emptySlots();
    try {
      final raw = await file.readAsString();
      final list = json.decode(raw) as List;
      return list.map((e) => PlanSlot.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _emptySlots();
    }
  }

  Future<void> save(List<PlanSlot> slots) async {
    final file = await _file();
    await file.writeAsString(json.encode(slots.map((s) => s.toJson()).toList()));
  }

  List<PlanSlot> _emptySlots() => [
    for (final day in _dayKeys)
      for (final type in _rawMealTypes)
        PlanSlot(dayKey: day, rawMealType: type),
  ];

  List<PlanSlot> emptySlots() => _emptySlots();
}
