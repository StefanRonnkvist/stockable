import 'package:flutter/material.dart';

import 'storage_location_record.dart';

/// Owns and disposes the text controllers used by location forms.
class AddStorageLocationFormControllers {
  AddStorageLocationFormControllers._({
    required this.locationCode,
    required this.drawers,
    required this.shelves,
    required this.drawerRows,
    required this.drawerColumns,
    required this.shelfRows,
    required this.shelfColumns,
    required this.drawerLength,
    required this.drawerWidth,
    required this.drawerHeight,
    required this.drawerMaxWeight,
    required this.shelfLength,
    required this.shelfWidth,
    required this.shelfHeight,
    required this.shelfMaxWeight,
    required this.length,
    required this.width,
    required this.height,
    required this.weight,
    required this.createMultiple,
  });

  /// Creates controllers with defaults suitable for a new location.
  factory AddStorageLocationFormControllers.create() {
    TextEditingController numericController([int initialValue = 1]) =>
        TextEditingController(text: initialValue.toString());
    TextEditingController textController([String initialText = '']) =>
        TextEditingController(text: initialText);

    return AddStorageLocationFormControllers._(
      locationCode: textController(),
      drawers: numericController(0),
      shelves: numericController(0),
      drawerRows: numericController(0),
      drawerColumns: numericController(0),
      shelfRows: numericController(0),
      shelfColumns: numericController(0),
      drawerLength: numericController(0),
      drawerWidth: numericController(0),
      drawerHeight: numericController(0),
      drawerMaxWeight: numericController(0),
      shelfLength: numericController(0),
      shelfWidth: numericController(0),
      shelfHeight: numericController(0),
      shelfMaxWeight: numericController(0),
      length: numericController(0),
      width: numericController(0),
      height: numericController(0),
      weight: numericController(0),
      createMultiple: numericController(),
    );
  }

  /// Creates controllers populated from an existing location for editing.
  factory AddStorageLocationFormControllers.fromRecord(
    StorageLocationRecord record,
  ) {
    TextEditingController numericController(int value) =>
        TextEditingController(text: value.toString());
    TextEditingController textController(String initialText) =>
        TextEditingController(text: initialText);

    return AddStorageLocationFormControllers._(
      locationCode: textController(record.locationCode),
      drawers: numericController(record.drawers),
      shelves: numericController(record.shelves),
      drawerRows: numericController(record.drawerRows),
      drawerColumns: numericController(record.drawerColumns),
      shelfRows: numericController(record.shelfRows),
      shelfColumns: numericController(record.shelfColumns),
      drawerLength: numericController(record.drawerLength),
      drawerWidth: numericController(record.drawerWidth),
      drawerHeight: numericController(record.drawerHeight),
      drawerMaxWeight: numericController(record.drawerMaxWeight),
      shelfLength: numericController(record.shelfLength),
      shelfWidth: numericController(record.shelfWidth),
      shelfHeight: numericController(record.shelfHeight),
      shelfMaxWeight: numericController(record.shelfMaxWeight),
      length: numericController(record.minLength),
      width: numericController(record.minWidth),
      height: numericController(record.minHeight),
      weight: numericController(record.minWeight),
      createMultiple: textController(record.batchSize.toString()),
    );
  }

  final TextEditingController locationCode;
  final TextEditingController drawers;
  final TextEditingController shelves;
  final TextEditingController drawerRows;
  final TextEditingController drawerColumns;
  final TextEditingController shelfRows;
  final TextEditingController shelfColumns;
  final TextEditingController drawerLength;
  final TextEditingController drawerWidth;
  final TextEditingController drawerHeight;
  final TextEditingController drawerMaxWeight;
  final TextEditingController shelfLength;
  final TextEditingController shelfWidth;
  final TextEditingController shelfHeight;
  final TextEditingController shelfMaxWeight;
  final TextEditingController length;
  final TextEditingController width;
  final TextEditingController height;
  final TextEditingController weight;
  final TextEditingController createMultiple;

  List<TextEditingController> get all => [
    locationCode,
    drawers,
    shelves,
    drawerRows,
    drawerColumns,
    shelfRows,
    shelfColumns,
    drawerLength,
    drawerWidth,
    drawerHeight,
    drawerMaxWeight,
    shelfLength,
    shelfWidth,
    shelfHeight,
    shelfMaxWeight,
    length,
    width,
    height,
    weight,
    createMultiple,
  ];

  /// Releases every controller owned by this collection.
  void dispose() {
    for (final controller in all) {
      controller.dispose();
    }
  }
}
