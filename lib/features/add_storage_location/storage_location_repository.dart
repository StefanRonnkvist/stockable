import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../texts/repository_texts.dart';
import 'storage_location_record.dart';

/// Persists storage locations and allocates their display-name sequences.
class StorageLocationRepository {
  StorageLocationRepository._();

  static final StorageLocationRepository instance =
      StorageLocationRepository._();

  static const _tableName = RepositoryTexts.storageLocationsTable;

  Future<List<StorageLocationRecord>> fetchAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      orderBy: RepositoryTexts.orderByUpdatedAtIdDesc,
    );
    return rows.map(StorageLocationRecord.fromMap).toList();
  }

  Future<void> insertAll(List<StorageLocationRecord> records) async {
    if (records.isEmpty) {
      return;
    }

    final db = await AppDatabase.instance.database;
    final batch = db.batch();

    for (final record in records) {
      batch.insert(
        _tableName,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Updates an existing location and rejects records without a database ID.
  Future<void> update(StorageLocationRecord record) async {
    final recordId = record.id;
    if (recordId == null) {
      throw ArgumentError(RepositoryTexts.updateMissingIdError);
    }

    final db = await AppDatabase.instance.database;
    await db.update(
      _tableName,
      record.toMap(),
      where: RepositoryTexts.whereIdEquals,
      whereArgs: [recordId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete(
      _tableName,
      where: RepositoryTexts.whereIdEquals,
      whereArgs: [id],
    );
  }

  /// Returns `true` if a row with [locationCode] already exists.
  /// Pass [excludeId] to ignore a specific row (useful when editing).
  Future<bool> existsWithCode(String locationCode, {int? excludeId}) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      columns: [RepositoryTexts.idColumn],
      where: excludeId != null
          ? RepositoryTexts.whereLocationCodeEqualsAndIdNotEquals
          : RepositoryTexts.whereLocationCodeEquals,
      whereArgs: excludeId != null ? [locationCode, excludeId] : [locationCode],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Finds the first unused numeric suffix for [baseIdentifier].
  ///
  /// An unsuffixed exact match occupies sequence 1. Malformed suffixes and
  /// codes that only partially share the prefix are ignored.
  Future<int> nextIdentifierSequence(String baseIdentifier) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      columns: [RepositoryTexts.locationCodeColumn],
      where: RepositoryTexts.whereLocationCodeEqualsOrLike,
      whereArgs: [
        baseIdentifier,
        RepositoryTexts.likePatternForIdentifier(baseIdentifier),
      ],
    );

    var maxSequence = 0;

    for (final row in rows) {
      final code = row[RepositoryTexts.locationCodeColumn] as String?;
      if (code == null || code.isEmpty) {
        continue;
      }

      if (code == baseIdentifier) {
        if (maxSequence < 1) {
          maxSequence = 1;
        }
        continue;
      }

      if (!code.startsWith(
        RepositoryTexts.startsWithIdentifierPrefix(baseIdentifier),
      )) {
        continue;
      }

      final suffix = code.substring(baseIdentifier.length + 1);
      final sequence = int.tryParse(suffix);
      if (sequence != null && sequence > maxSequence) {
        maxSequence = sequence;
      }
    }

    return maxSequence + 1;
  }

  /// Finds the next quick-name number used by a normalized storage type.
  ///
  /// Only location codes matching the repository's quick-name pattern count;
  /// unrelated numeric fragments do not advance the sequence.
  Future<int> nextQuickNameSequenceForStorage(String storageBase) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      _tableName,
      columns: [RepositoryTexts.locationCodeColumn],
      where: RepositoryTexts.whereLocationCodeLike,
      whereArgs: [RepositoryTexts.quickNameLikePattern(storageBase)],
    );

    final pattern = RepositoryTexts.quickNamePattern(storageBase);
    var maxSequence = 0;

    for (final row in rows) {
      final code = row[RepositoryTexts.locationCodeColumn] as String?;
      if (code == null || code.isEmpty) {
        continue;
      }

      final match = pattern.firstMatch(code);
      if (match == null) {
        continue;
      }

      final sequence = int.tryParse(match.group(1) ?? '');
      if (sequence != null && sequence > maxSequence) {
        maxSequence = sequence;
      }
    }

    return maxSequence + 1;
  }
}
