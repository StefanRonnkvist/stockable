import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/database/app_database.dart';
import '../../texts/repository_texts.dart';

/// Persists pairs of slots that the assignment UI presents as merged.
class SlotMergeRepository {
  SlotMergeRepository._();

  static final SlotMergeRepository instance = SlotMergeRepository._();

  static const _tableName = RepositoryTexts.slotMergesTable;

  Future<Map<String, Set<String>>> fetchMergedPairsForLocation(
    String locationCode,
  ) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      columns: [
        RepositoryTexts.slotTypeColumn,
        RepositoryTexts.containerLabelColumn,
        RepositoryTexts.firstSlotLabelColumn,
        RepositoryTexts.secondSlotLabelColumn,
      ],
      where: RepositoryTexts.whereLocationCodeEquals,
      whereArgs: [locationCode],
    );

    final mergedByContainer = <String, Set<String>>{};
    for (final row in rows) {
      final slotType =
          (row[RepositoryTexts.slotTypeColumn] as String?) ??
          RepositoryTexts.empty;
      final containerLabel =
          (row[RepositoryTexts.containerLabelColumn] as String?) ??
          RepositoryTexts.empty;
      final firstSlot =
          (row[RepositoryTexts.firstSlotLabelColumn] as String?) ??
          RepositoryTexts.empty;
      final secondSlot =
          (row[RepositoryTexts.secondSlotLabelColumn] as String?) ??
          RepositoryTexts.empty;
      if (slotType.isEmpty ||
          containerLabel.isEmpty ||
          firstSlot.isEmpty ||
          secondSlot.isEmpty) {
        continue;
      }

      final containerKey = RepositoryTexts.containerKey(
        locationCode,
        slotType,
        containerLabel,
      );
      final pairKey = RepositoryTexts.pairKey(firstSlot, secondSlot);
      mergedByContainer
          .putIfAbsent(containerKey, () => <String>{})
          .add(pairKey);
    }

    return mergedByContainer;
  }

  /// Inserts or refreshes one canonical pair within a slot container.
  Future<void> upsertMerge({
    required String locationCode,
    required String slotType,
    required String containerLabel,
    required String firstSlotLabel,
    required String secondSlotLabel,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert(_tableName, {
      RepositoryTexts.locationCodeColumn: locationCode,
      RepositoryTexts.slotTypeColumn: slotType,
      RepositoryTexts.containerLabelColumn: containerLabel,
      RepositoryTexts.firstSlotLabelColumn: firstSlotLabel,
      RepositoryTexts.secondSlotLabelColumn: secondSlotLabel,
      RepositoryTexts.updatedAtColumn: DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMerge({
    required String locationCode,
    required String slotType,
    required String containerLabel,
    required String firstSlotLabel,
    required String secondSlotLabel,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _tableName,
      where: RepositoryTexts.whereSlotMergeByLocationAndPair,
      whereArgs: [
        locationCode,
        slotType,
        containerLabel,
        firstSlotLabel,
        secondSlotLabel,
      ],
    );
  }
}
