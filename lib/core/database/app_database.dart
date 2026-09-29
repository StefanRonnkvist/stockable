import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';

import '../../texts/database_sql_texts.dart';
import '../../texts/repository_texts.dart';

/// Owns the application's SQLite connection, schema, and maintenance tasks.
///
/// The connection is opened lazily and reused for the lifetime of the process.
/// Desktop platforms use the FFI database factory; mobile platforms keep the
/// factory supplied by `sqflite`.
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = DatabaseSqlTexts.databaseName;
  static const _databaseVersion = 5;

  Database? _database;
  bool _factoryConfigured = false;

  /// Opens the database early so startup can surface initialization failures.
  Future<void> initialize() async {
    await database;
  }

  /// Returns the shared database, creating or upgrading it on first access.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _configureFactory();
    final databasePath = path.join(
      await databaseFactory.getDatabasesPath(),
      _databaseName,
    );
    _database = await databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return _database!;
  }

  Future<String> databasePath() async {
    _configureFactory();
    return path.join(await databaseFactory.getDatabasesPath(), _databaseName);
  }

  /// Runs SQLite's integrity check and returns its first result value.
  Future<String> integrityCheck() async {
    final db = await database;
    final rows = await db.rawQuery(DatabaseSqlTexts.integrityCheckPragma);
    if (rows.isEmpty) {
      return DatabaseSqlTexts.unknownResult;
    }

    final value = rows.first.values.first;
    return value?.toString() ?? DatabaseSqlTexts.unknownResult;
  }

  /// Reclaims unused space and refreshes SQLite query-planner statistics.
  Future<void> optimize() async {
    final db = await database;
    await db.execute(DatabaseSqlTexts.vacuum);
    await db.execute(DatabaseSqlTexts.analyze);
  }

  /// Rebuilds every index in the database.
  Future<void> rebuildIndexes() async {
    final db = await database;
    await db.execute(DatabaseSqlTexts.reindex);
  }

  /// Returns the number of persisted storage locations.
  Future<int> storageLocationCount() async {
    final db = await database;
    final rows = await db.rawQuery(DatabaseSqlTexts.storageLocationCountQuery);
    return (rows.first[DatabaseSqlTexts.countAlias] as int?) ?? 0;
  }

  /// Deletes all locations; dependent slot rows are removed by foreign keys.
  Future<void> clearStorageLocations() async {
    final db = await database;
    await db.delete(RepositoryTexts.storageLocationsTable);
  }

  /// Exports all database tables to a JSON string.
  ///
  /// The returned JSON has the shape:
  /// ```json
  /// {
  ///   "storage_locations": [ { ...row }, ... ],
  ///   "location_slot_contents": [ { ...row }, ... ],
  ///   "location_slot_merges": [ { ...row }, ... ]
  /// }
  /// ```
  Future<String> exportToJson() async {
    final db = await database;
    final tables = [
      RepositoryTexts.storageLocationsTable,
      RepositoryTexts.slotContentsTable,
      RepositoryTexts.slotMergesTable,
    ];
    final data = <String, dynamic>{};
    for (final table in tables) {
      data[table] = await db.query(table);
    }
    return jsonEncode(data);
  }

  /// Imports data from an XML string, replacing all existing table rows.
  ///
  /// Expected XML shape:
  /// ```xml
  /// <stockable>
  ///   <storage_locations>
  ///     <row id="1" location_code="LOC-001" ... />
  ///   </storage_locations>
  ///   <location_slot_contents>
  ///     <row ... />
  ///   </location_slot_contents>
  ///   <location_slot_merges>
  ///     <row ... />
  ///   </location_slot_merges>
  /// </stockable>
  /// ```
  /// Each XML attribute corresponds to a column name. Integer columns must
  /// carry numeric values; all others are treated as text.
  Future<void> importFromXml(String xmlString) async {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;

    final db = await database;
    await db.transaction((txn) async {
      for (final tableElement in root.childElements) {
        final tableName = tableElement.name.local;
        await txn.delete(tableName);
        for (final rowElement in tableElement.childElements) {
          final row = <String, Object?>{};
          for (final attr in rowElement.attributes) {
            final raw = attr.value;
            final asInt = int.tryParse(raw);
            row[attr.name.local] = asInt ?? raw;
          }
          await txn.insert(tableName, row);
        }
      }
    });
  }

  /// Selects the FFI-backed SQLite implementation once on desktop platforms.
  void _configureFactory() {
    if (_factoryConfigured || kIsWeb || !_isDesktopPlatform) {
      return;
    }

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _factoryConfigured = true;
  }

  /// Whether the current native target requires `sqflite_common_ffi`.
  bool get _isDesktopPlatform {
    return switch (defaultTargetPlatform) {
      TargetPlatform.windows ||
      TargetPlatform.linux ||
      TargetPlatform.macOS => true,
      _ => false,
    };
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseSqlTexts.createStorageLocationsTable);
    await db.execute(DatabaseSqlTexts.createSlotContentsTable);
    await db.execute(DatabaseSqlTexts.createSlotMergesTable);
    await _createIndexes(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Upgrade blocks are cumulative so a database can skip multiple versions.
    if (oldVersion < 2) {
      // Version 2 introduced stable location codes and update timestamps.
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddLocationCode);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddUpdatedAt);
      await db.execute(DatabaseSqlTexts.updateStorageLocationsBackfill);
      await _createIndexes(db);
    }

    if (oldVersion < 3) {
      // Version 3 added text contents associated with individual slots.
      await db.execute(DatabaseSqlTexts.createSlotContentsTableIfNotExists);
      await _createIndexes(db);
    }

    if (oldVersion < 4) {
      // Version 4 added persisted relationships between merged slots.
      await db.execute(DatabaseSqlTexts.createSlotMergesTableIfNotExists);
      await _createIndexes(db);
    }
    if (oldVersion < 5) {
      // Version 5 records dimensions and load limits per drawer and shelf.
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddDrawerLength);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddDrawerWidth);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddDrawerHeight);
      await db.execute(
        DatabaseSqlTexts.alterStorageLocationsAddDrawerMaxWeight,
      );
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddShelfLength);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddShelfWidth);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddShelfHeight);
      await db.execute(DatabaseSqlTexts.alterStorageLocationsAddShelfMaxWeight);
    }
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(DatabaseSqlTexts.createUniqueIndexStorageLocations);
    await db.execute(DatabaseSqlTexts.createUniqueIndexSlotContents);
    await db.execute(DatabaseSqlTexts.createUniqueIndexSlotMerges);
  }
}
