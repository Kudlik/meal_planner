import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';

class PlanExportService {
  static const _version = 1;

  Map<String, dynamic> buildExportJson(
    List<PlanSlot> slots,
    List<ManualItem> manuals,
    List<QuantityOverride> overrides,
  ) {
    return {
      'version': _version,
      'slots': slots.map((s) => s.toJson()).toList(),
      'manuals': manuals.map((m) => m.toJson()).toList(),
      'overrides': overrides.map((o) => o.toJson()).toList(),
    };
  }

  Future<void> share(Map<String, dynamic> exportJson) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/plan.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(exportJson));
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  }

  // Returns parsed data or throws a descriptive error string.
  Future<ImportResult> pickAndParse() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) {
      return ImportResult.cancelled();
    }

    final raw = await File(result.files.single.path!).readAsString();
    final Map<String, dynamic> data;
    try {
      data = json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      throw 'Plik nie jest prawidłowym plikiem JSON.';
    }

    if (!data.containsKey('slots')) {
      throw 'To nie jest plik planu posiłków.';
    }

    try {
      final slots = (data['slots'] as List)
          .map((e) => PlanSlot.fromJson(e as Map<String, dynamic>))
          .toList();
      final manuals = (data['manuals'] as List? ?? [])
          .map((e) => ManualItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final overrides = (data['overrides'] as List? ?? [])
          .map((e) => QuantityOverride.fromJson(e as Map<String, dynamic>))
          .toList();
      return ImportResult.success(slots, manuals, overrides);
    } catch (_) {
      throw 'Nie udało się odczytać danych z pliku.';
    }
  }
}

class ImportResult {
  final bool cancelled;
  final List<PlanSlot>? slots;
  final List<ManualItem>? manuals;
  final List<QuantityOverride>? overrides;

  ImportResult._({required this.cancelled, this.slots, this.manuals, this.overrides});

  factory ImportResult.cancelled() => ImportResult._(cancelled: true);
  factory ImportResult.success(
    List<PlanSlot> slots,
    List<ManualItem> manuals,
    List<QuantityOverride> overrides,
  ) => ImportResult._(cancelled: false, slots: slots, manuals: manuals, overrides: overrides);
}
