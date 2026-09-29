class DatabaseSqlTexts {
  const DatabaseSqlTexts._();

  static const databaseName = 'stockable.db';
  static const integrityCheckPragma = 'PRAGMA integrity_check';
  static const unknownResult = 'unknown';

  static const vacuum = 'VACUUM';
  static const analyze = 'ANALYZE';
  static const reindex = 'REINDEX';

  static const storageLocationCountQuery =
      'SELECT COUNT(*) AS count FROM storage_locations';
  static const countAlias = 'count';

  static const createStorageLocationsTable = '''
      CREATE TABLE storage_locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_code TEXT NOT NULL,
        batch_id TEXT NOT NULL,
        batch_index INTEGER NOT NULL,
        batch_size INTEGER NOT NULL,
        use_metric INTEGER NOT NULL,
        storage_type TEXT NOT NULL,
        storage_environment TEXT NOT NULL,
        storage_layout TEXT NOT NULL,
        compartment_type TEXT NOT NULL,
        drawers INTEGER NOT NULL,
        shelves INTEGER NOT NULL,
        drawer_rows INTEGER NOT NULL,
        drawer_columns INTEGER NOT NULL,
        shelf_rows INTEGER NOT NULL,
        shelf_columns INTEGER NOT NULL,
        min_length INTEGER NOT NULL,
        max_length INTEGER NOT NULL,
        min_width INTEGER NOT NULL,
        max_width INTEGER NOT NULL,
        min_height INTEGER NOT NULL,
        max_height INTEGER NOT NULL,
        min_weight INTEGER NOT NULL,
        max_weight INTEGER NOT NULL,
        drawer_length INTEGER NOT NULL DEFAULT 0,
        drawer_width INTEGER NOT NULL DEFAULT 0,
        drawer_height INTEGER NOT NULL DEFAULT 0,
        drawer_max_weight INTEGER NOT NULL DEFAULT 0,
        shelf_length INTEGER NOT NULL DEFAULT 0,
        shelf_width INTEGER NOT NULL DEFAULT 0,
        shelf_height INTEGER NOT NULL DEFAULT 0,
        shelf_max_weight INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''';

  static const createSlotContentsTable = '''
      CREATE TABLE location_slot_contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_code TEXT NOT NULL,
        slot_type TEXT NOT NULL,
        container_label TEXT NOT NULL,
        slot_label TEXT NOT NULL,
        contents TEXT,
        updated_at TEXT NOT NULL
      )
    ''';

  static const createSlotMergesTable = '''
      CREATE TABLE location_slot_merges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        location_code TEXT NOT NULL,
        slot_type TEXT NOT NULL,
        container_label TEXT NOT NULL,
        first_slot_label TEXT NOT NULL,
        second_slot_label TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''';

  static const alterStorageLocationsAddLocationCode =
      'ALTER TABLE storage_locations ADD COLUMN location_code TEXT';
  static const alterStorageLocationsAddUpdatedAt =
      'ALTER TABLE storage_locations ADD COLUMN updated_at TEXT';

  static const updateStorageLocationsBackfill = '''
        UPDATE storage_locations
        SET location_code = COALESCE(location_code, 'LOC-' || id),
            updated_at = COALESCE(updated_at, created_at)
      ''';

  static const createSlotContentsTableIfNotExists = '''
        CREATE TABLE IF NOT EXISTS location_slot_contents (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_code TEXT NOT NULL,
          slot_type TEXT NOT NULL,
          container_label TEXT NOT NULL,
          slot_label TEXT NOT NULL,
          contents TEXT,
          updated_at TEXT NOT NULL
        )
      ''';

  static const createSlotMergesTableIfNotExists = '''
        CREATE TABLE IF NOT EXISTS location_slot_merges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          location_code TEXT NOT NULL,
          slot_type TEXT NOT NULL,
          container_label TEXT NOT NULL,
          first_slot_label TEXT NOT NULL,
          second_slot_label TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''';

  static const alterStorageLocationsAddDrawerLength =
      'ALTER TABLE storage_locations ADD COLUMN drawer_length INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddDrawerWidth =
      'ALTER TABLE storage_locations ADD COLUMN drawer_width INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddDrawerHeight =
      'ALTER TABLE storage_locations ADD COLUMN drawer_height INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddDrawerMaxWeight =
      'ALTER TABLE storage_locations ADD COLUMN drawer_max_weight INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddShelfLength =
      'ALTER TABLE storage_locations ADD COLUMN shelf_length INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddShelfWidth =
      'ALTER TABLE storage_locations ADD COLUMN shelf_width INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddShelfHeight =
      'ALTER TABLE storage_locations ADD COLUMN shelf_height INTEGER NOT NULL DEFAULT 0';
  static const alterStorageLocationsAddShelfMaxWeight =
      'ALTER TABLE storage_locations ADD COLUMN shelf_max_weight INTEGER NOT NULL DEFAULT 0';

  static const createUniqueIndexStorageLocations = '''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_storage_locations_location_code
      ON storage_locations(location_code)
    ''';

  static const createUniqueIndexSlotContents = '''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_location_slot_contents_unique
      ON location_slot_contents(
        location_code,
        slot_type,
        container_label,
        slot_label
      )
    ''';

  static const createUniqueIndexSlotMerges = '''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_location_slot_merges_unique
      ON location_slot_merges(
        location_code,
        slot_type,
        container_label,
        first_slot_label,
        second_slot_label
      )
    ''';
}
