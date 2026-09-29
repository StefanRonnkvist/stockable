/// Immutable representation of one row in the storage locations table.
class StorageLocationRecord {
  const StorageLocationRecord({
    this.id,
    required this.locationCode,
    required this.batchId,
    required this.batchIndex,
    required this.batchSize,
    required this.useMetric,
    required this.storageType,
    required this.storageEnvironment,
    required this.storageLayout,
    required this.compartmentType,
    required this.drawers,
    required this.shelves,
    required this.drawerRows,
    required this.drawerColumns,
    required this.shelfRows,
    required this.shelfColumns,
    required this.minLength,
    required this.maxLength,
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
    required this.minWeight,
    required this.maxWeight,
    required this.drawerLength,
    required this.drawerWidth,
    required this.drawerHeight,
    required this.drawerMaxWeight,
    required this.shelfLength,
    required this.shelfWidth,
    required this.shelfHeight,
    required this.shelfMaxWeight,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String locationCode;
  final String batchId;
  final int batchIndex;
  final int batchSize;
  final bool useMetric;
  final String storageType;
  final String storageEnvironment;
  final String storageLayout;
  final String compartmentType;
  final int drawers;
  final int shelves;
  final int drawerRows;
  final int drawerColumns;
  final int shelfRows;
  final int shelfColumns;
  final int minLength;
  final int maxLength;
  final int minWidth;
  final int maxWidth;
  final int minHeight;
  final int maxHeight;
  final int minWeight;
  final int maxWeight;
  final int drawerLength;
  final int drawerWidth;
  final int drawerHeight;
  final int drawerMaxWeight;
  final int shelfLength;
  final int shelfWidth;
  final int shelfHeight;
  final int shelfMaxWeight;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Rehydrates a record, defaulting columns added by later migrations to zero.
  factory StorageLocationRecord.fromMap(Map<String, Object?> map) {
    return StorageLocationRecord(
      id: map['id'] as int?,
      locationCode: map['location_code'] as String,
      batchId: map['batch_id'] as String,
      batchIndex: map['batch_index'] as int,
      batchSize: map['batch_size'] as int,
      useMetric: (map['use_metric'] as int) == 1,
      storageType: map['storage_type'] as String,
      storageEnvironment: map['storage_environment'] as String,
      storageLayout: map['storage_layout'] as String,
      compartmentType: map['compartment_type'] as String,
      drawers: map['drawers'] as int,
      shelves: map['shelves'] as int,
      drawerRows: map['drawer_rows'] as int,
      drawerColumns: map['drawer_columns'] as int,
      shelfRows: map['shelf_rows'] as int,
      shelfColumns: map['shelf_columns'] as int,
      minLength: map['min_length'] as int,
      maxLength: map['max_length'] as int,
      minWidth: map['min_width'] as int,
      maxWidth: map['max_width'] as int,
      minHeight: map['min_height'] as int,
      maxHeight: map['max_height'] as int,
      minWeight: map['min_weight'] as int,
      maxWeight: map['max_weight'] as int,
      drawerLength: (map['drawer_length'] as int?) ?? 0,
      drawerWidth: (map['drawer_width'] as int?) ?? 0,
      drawerHeight: (map['drawer_height'] as int?) ?? 0,
      drawerMaxWeight: (map['drawer_max_weight'] as int?) ?? 0,
      shelfLength: (map['shelf_length'] as int?) ?? 0,
      shelfWidth: (map['shelf_width'] as int?) ?? 0,
      shelfHeight: (map['shelf_height'] as int?) ?? 0,
      shelfMaxWeight: (map['shelf_max_weight'] as int?) ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Creates a record with selected values replaced.
  StorageLocationRecord copyWith({
    int? id,
    String? locationCode,
    String? batchId,
    int? batchIndex,
    int? batchSize,
    bool? useMetric,
    String? storageType,
    String? storageEnvironment,
    String? storageLayout,
    String? compartmentType,
    int? drawers,
    int? shelves,
    int? drawerRows,
    int? drawerColumns,
    int? shelfRows,
    int? shelfColumns,
    int? minLength,
    int? maxLength,
    int? minWidth,
    int? maxWidth,
    int? minHeight,
    int? maxHeight,
    int? minWeight,
    int? maxWeight,
    int? drawerLength,
    int? drawerWidth,
    int? drawerHeight,
    int? drawerMaxWeight,
    int? shelfLength,
    int? shelfWidth,
    int? shelfHeight,
    int? shelfMaxWeight,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StorageLocationRecord(
      id: id ?? this.id,
      locationCode: locationCode ?? this.locationCode,
      batchId: batchId ?? this.batchId,
      batchIndex: batchIndex ?? this.batchIndex,
      batchSize: batchSize ?? this.batchSize,
      useMetric: useMetric ?? this.useMetric,
      storageType: storageType ?? this.storageType,
      storageEnvironment: storageEnvironment ?? this.storageEnvironment,
      storageLayout: storageLayout ?? this.storageLayout,
      compartmentType: compartmentType ?? this.compartmentType,
      drawers: drawers ?? this.drawers,
      shelves: shelves ?? this.shelves,
      drawerRows: drawerRows ?? this.drawerRows,
      drawerColumns: drawerColumns ?? this.drawerColumns,
      shelfRows: shelfRows ?? this.shelfRows,
      shelfColumns: shelfColumns ?? this.shelfColumns,
      minLength: minLength ?? this.minLength,
      maxLength: maxLength ?? this.maxLength,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      minWeight: minWeight ?? this.minWeight,
      maxWeight: maxWeight ?? this.maxWeight,
      drawerLength: drawerLength ?? this.drawerLength,
      drawerWidth: drawerWidth ?? this.drawerWidth,
      drawerHeight: drawerHeight ?? this.drawerHeight,
      drawerMaxWeight: drawerMaxWeight ?? this.drawerMaxWeight,
      shelfLength: shelfLength ?? this.shelfLength,
      shelfWidth: shelfWidth ?? this.shelfWidth,
      shelfHeight: shelfHeight ?? this.shelfHeight,
      shelfMaxWeight: shelfMaxWeight ?? this.shelfMaxWeight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts this record to SQLite column names and primitive values.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'location_code': locationCode,
      'batch_id': batchId,
      'batch_index': batchIndex,
      'batch_size': batchSize,
      'use_metric': useMetric ? 1 : 0,
      'storage_type': storageType,
      'storage_environment': storageEnvironment,
      'storage_layout': storageLayout,
      'compartment_type': compartmentType,
      'drawers': drawers,
      'shelves': shelves,
      'drawer_rows': drawerRows,
      'drawer_columns': drawerColumns,
      'shelf_rows': shelfRows,
      'shelf_columns': shelfColumns,
      'min_length': minLength,
      'max_length': maxLength,
      'min_width': minWidth,
      'max_width': maxWidth,
      'min_height': minHeight,
      'max_height': maxHeight,
      'min_weight': minWeight,
      'max_weight': maxWeight,
      'drawer_length': drawerLength,
      'drawer_width': drawerWidth,
      'drawer_height': drawerHeight,
      'drawer_max_weight': drawerMaxWeight,
      'shelf_length': shelfLength,
      'shelf_width': shelfWidth,
      'shelf_height': shelfHeight,
      'shelf_max_weight': shelfMaxWeight,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
