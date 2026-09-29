class InventoryTexts {
  const InventoryTexts._();

  static const addSparePartTitle = 'Add Spare Part';
  static const oemPartNumberLabel = 'OEM Part Number';
  static const localPartNumberLabel = 'Local Part Number';
  static const descriptionLabel = 'Description';
  static const storageLocationLabel = 'Storage Location';
  static const minimumOrderQuantityLabel = 'Minimum Order Quantity (MOQ)';

  static const failedToLoadLocations = 'Failed to load storage locations.';
  static const retryButton = 'Retry';

  static const editTooltip = 'Edit';
  static const deleteTooltip = 'Delete';
  static const compartmentLabel = 'Compartment';
  static const unitsLabel = 'Units';
  static const batchLabel = 'Batch';
  static const metricLabel = 'Metric';
  static const imperialLabel = 'Imperial';
  static const unitCentimetre = 'cm';
  static const unitInch = 'in';
  static const unitKilogram = 'kg';
  static const unitPound = 'lb';

  static const deleteStorageLocationTitle = 'Delete Storage Location';
  static const cancelButton = 'Cancel';
  static const deleteButton = 'Delete';

  static const dimensionsPrefix = 'Dimensions';
  static const weightPrefix = 'Weight';
  static const updatedPrefix = 'Updated';

  static const editStorageLocationTitle = 'Edit Storage Location';
  static const locationIdentifierLabel = 'Location Identifier';
  static const centimetresAndKilograms = 'Centimetres & kilograms';
  static const inchesAndPounds = 'Inches & pounds';
  static const numberOfDrawersLabel = 'Number of Drawers';
  static const numberOfShelvesLabel = 'Number of Shelves';
  static const drawerLengthLabel = 'Drawer Length';
  static const drawerWidthLabel = 'Drawer Width';
  static const drawerHeightLabel = 'Drawer Height';
  static const drawerMaxWeightLabel = 'Drawer Max Weight';
  static const shelfLengthLabel = 'Shelf Length';
  static const shelfWidthLabel = 'Shelf Width';
  static const shelfHeightLabel = 'Shelf Height';
  static const shelfMaxWeightLabel = 'Shelf Max Weight';
  static const lengthLabel = 'Length';
  static const widthLabel = 'Width';
  static const heightLabel = 'Height';
  static const weightLabel = 'Weight';
  static const saveChangesButton = 'Save Changes';
  static const savingButton = 'Saving...';

  static const locationIdentifierEmptyError =
      'Location identifier cannot be empty.';
  static const locationIdentifierDuplicateError =
      'This identifier is already in use.';

  static const compartmentDrawer = 'Drawer';
  static const compartmentShelf = 'Shelf';
  static const compartmentBoth = 'Both';

  static String updatedLocationMessage(String code) => 'Updated $code';

  static String failedToUpdateLocationMessage(Object error) =>
      'Failed to update location: $error';

  static String deleteLocationPrompt(String code) => 'Delete $code?';

  static String deletedLocationMessage(String code) => 'Deleted $code';

  static String failedToDeleteLocationMessage(Object error) =>
      'Failed to delete location: $error';

  static String unitTitle(bool useMetric) =>
      useMetric ? metricLabel : imperialLabel;

  static String unitSubtitle(bool useMetric) =>
      useMetric ? centimetresAndKilograms : inchesAndPounds;

  static String lengthLabelWithUnit(String unit) => 'Length ($unit)';

  static String widthLabelWithUnit(String unit) => 'Width ($unit)';

  static String heightLabelWithUnit(String unit) => 'Height ($unit)';

  static String weightLabelWithUnit(String unit) => 'Weight ($unit)';

  static String dimensionUnit(bool useMetric) =>
      useMetric ? unitCentimetre : unitInch;

  static String weightUnit(bool useMetric) =>
      useMetric ? unitKilogram : unitPound;

  static String batchValue(int index, int size) => '$index/$size';

  static String dimensionsSummary(
    int minLength,
    int maxLength,
    int minWidth,
    int maxWidth,
    int minHeight,
    int maxHeight,
  ) {
    return '$dimensionsPrefix: $minLength-$maxLength × $minWidth-$maxWidth × $minHeight-$maxHeight';
  }

  static String weightAndCapacitySummary(
    int minWeight,
    int maxWeight,
    int drawers,
    int shelves,
  ) {
    return '$weightPrefix: $minWeight-$maxWeight · Drawers $drawers · Shelves $shelves';
  }

  static String updatedAtMessage(String timestamp) =>
      '$updatedPrefix $timestamp';

  static String storageMetaLine(
    String storageType,
    String storageEnvironment,
    String storageLayout,
  ) {
    return '$storageType · $storageEnvironment · $storageLayout';
  }

  static String chipLabelLine(String label, String value) => '$label: $value';

  static String formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
