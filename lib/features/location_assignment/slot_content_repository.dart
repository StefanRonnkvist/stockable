import '../../core/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../texts/repository_texts.dart';

/// Stores free-form contents for an individual drawer or shelf slot.
class SlotContentRepository {
  SlotContentRepository._();

  static final SlotContentRepository instance = SlotContentRepository._();

  static const _tableName = RepositoryTexts.slotContentsTable;

  Future<String?> readContent({
    required String locationCode,
    required String slotType,
    required String containerLabel,
    required String slotLabel,
  }) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      columns: [RepositoryTexts.contentsColumn],
      where: RepositoryTexts.whereSlotContentByLocationAndSlot,
      whereArgs: [locationCode, slotType, containerLabel, slotLabel],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first[RepositoryTexts.contentsColumn] as String?;
  }

  /// Saves normalized slot text, or deletes the row when the text is empty.
  ///
  /// The unique slot key and `replace` conflict policy make repeated saves
  /// idempotent while updating the modification timestamp.
  Future<void> upsertContent({
    required String locationCode,
    required String slotType,
    required String containerLabel,
    required String slotLabel,
    required String? contents,
  }) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().toIso8601String();

    final normalizedContents = (contents ?? RepositoryTexts.empty).trim();
    if (normalizedContents.isEmpty) {
      await db.delete(
        _tableName,
        where: RepositoryTexts.whereSlotContentByLocationAndSlot,
        whereArgs: [locationCode, slotType, containerLabel, slotLabel],
      );
      return;
    }

    await db.insert(_tableName, {
      RepositoryTexts.locationCodeColumn: locationCode,
      RepositoryTexts.slotTypeColumn: slotType,
      RepositoryTexts.containerLabelColumn: containerLabel,
      RepositoryTexts.slotLabelColumn: slotLabel,
      RepositoryTexts.contentsColumn: normalizedContents,
      RepositoryTexts.updatedAtColumn: now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
