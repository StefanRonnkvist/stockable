class LocationAssignmentTexts {
  const LocationAssignmentTexts._();

  static const locationSelectorTitle = 'Storage Location';
  static const noLocationsFound = 'No storage locations found.';
  static const allStorageLocationsLabel = 'All storage locations';

  static const storageDetailTitle = 'Storage Detail';
  static const selectLocationForDetails =
      'Select a storage location to view details.';

  static const storagePictureTitle = 'Storage Picture';
  static const mergeInstructions =
      'Tap two adjacent locations, then select Merge or Unmerge. Long-press a location to edit contents.';
  static const mergeButton = 'Merge';
  static const unmergeButton = 'Unmerge';
  static const selectLocationToDraw =
      'Select a storage location to draw picture.';
  static const noDrawersOrShelvesConfigured =
      'No drawers or shelves configured.';
  static const drawersTitle = 'Drawers';
  static const shelvesTitle = 'Shelves';

  static const quickNameLabel = 'Quick Name';
  static const storageLabel = 'Storage';
  static const environmentLabel = 'Environment';
  static const groupingLabel = 'Grouping';
  static const compartmentLabel = 'Compartment';
  static const drawersShelvesLabel = 'Drawers/Shelves';
  static const dimensionsLabel = 'Dimensions (LxWxH)';
  static const weightLabel = 'Weight';
  static const drawerRowsColumnsLabel = 'Drawer Rows/Columns';
  static const drawerDimensionsLabel = 'Drawer Dimensions (LxWxH)';
  static const drawerMaxWeightLabel = 'Drawer Max Weight';
  static const shelfRowsColumnsLabel = 'Shelf Rows/Columns';
  static const shelfDimensionsLabel = 'Shelf Dimensions (LxWxH)';
  static const shelfMaxWeightLabel = 'Shelf Max Weight';
  static const incrementLabel = 'Increment';

  static const failedToLoadLocations = 'Failed to load storage locations.';
  static const retryButton = 'Retry';

  static const mergeNeedTwoAdjacent = 'Select two adjacent locations to merge.';
  static const unmergeNeedTwoMerged = 'Select two merged locations to unmerge.';
  static const selectSlotsCurrentLocation =
      'Select slots from the current location.';
  static const selectSameContainer =
      'Select both locations in the same drawer/shelf.';
  static const selectedMustBeAdjacent = 'Selected locations must be adjacent.';
  static const locationsNotMerged = 'These locations are not merged.';

  static const slotTypeDrawer = 'Drawer';
  static const slotTypeShelf = 'Shelf';

  static const separatorDash = '-';
  static const separatorPipe = '|';
  static const unitCentimetre = 'cm';
  static const unitInch = 'in';
  static const unitKilogram = 'kg';
  static const unitPounds = 'lbs';

  static const incrementKey = 'INCREMENT';
  static const quickNameKey = 'QN';
  static const storageTypeKey = 'ST';
  static const environmentKey = 'ENV';
  static const groupingKey = 'GRP';
  static const compartmentKey = 'CMP';
  static const drawersKey = 'DRW';
  static const drawerRowsKey = 'DRR';
  static const drawerColumnsKey = 'DRC';
  static const shelvesKey = 'SHF';
  static const shelfRowsKey = 'SHR';
  static const shelfColumnsKey = 'SHC';
  static const minLengthKey = 'MINL';
  static const maxLengthKey = 'MAXL';
  static const minWidthKey = 'MINW';
  static const maxWidthKey = 'MAXW';
  static const minHeightKey = 'MINH';
  static const maxHeightKey = 'MAXH';
  static const minWeightKey = 'MINWT';
  static const maxWeightKey = 'MAXWT';

  static const incrementSuffixRegex = r'^(.*)-(\d+)$';
  static const drawerCellLabelRegex = r'^([A-Z]+)(\d+)$';

  static const identifierKnownKeys = {
    quickNameKey,
    storageTypeKey,
    environmentKey,
    groupingKey,
    compartmentKey,
    drawersKey,
    drawerRowsKey,
    drawerColumnsKey,
    shelvesKey,
    shelfRowsKey,
    shelfColumnsKey,
    minLengthKey,
    maxLengthKey,
    minWidthKey,
    maxWidthKey,
    minHeightKey,
    maxHeightKey,
    minWeightKey,
    maxWeightKey,
  };

  static const slotDialogSuffix = 'Location';
  static const slotDialogStorageLabel = 'Storage';
  static const slotDialogContainerLabel = 'Container';
  static const slotDialogLocationLabel = 'Location';
  static const slotDialogContentsLabel = 'Contents';
  static const slotDialogContentsHint = 'Enter item contents';
  static const closeButton = 'Close';
  static const saveButton = 'Save';

  static String detailLine(String label, String value) => '$label: $value';

  static String drawersShelvesValue(Object drawers, Object shelves) =>
      '$drawers / $shelves';

  static String dimensionsValue(
    Object minLength,
    Object maxLength,
    Object minWidth,
    Object maxWidth,
    Object minHeight,
    Object maxHeight,
  ) {
    return '$minLength-$maxLength x $minWidth-$maxWidth x $minHeight-$maxHeight';
  }

  static String weightValue(Object minWeight, Object maxWeight) {
    return '$minWeight-$maxWeight';
  }

  static String rowsColumnsValue(Object rows, Object columns) {
    return '$rows / $columns';
  }

  static String dimensionsWithUnitValue(
    Object length,
    Object width,
    Object height,
    String unit,
  ) {
    return '$length x $width x $height $unit';
  }

  static String weightWithUnitValue(Object weight, String unit) {
    return '$weight $unit';
  }

  static String drawerTitle(int index) => 'Drawer $index';

  static String shelfTitle(int index) => 'Shelf $index';

  static String slotDialogTitle(String slotType) =>
      '$slotType $slotDialogSuffix';

  static String dimensionUnit(bool useMetric) {
    return useMetric ? unitCentimetre : unitInch;
  }

  static String weightUnit(bool useMetric) {
    return useMetric ? unitKilogram : unitPounds;
  }

  static String slotLabelFromIndex(int index) => '$index';

  static String drawerCellLabel(String columnLabel, int rowNumber) {
    return '$columnLabel$rowNumber';
  }

  static String joinWithPipe(String first, String second) {
    return '$first$separatorPipe$second';
  }

  static String containerKey(
    String locationCode,
    String slotType,
    String containerLabel,
  ) {
    return '$locationCode$separatorPipe$slotType$separatorPipe$containerLabel';
  }
}
