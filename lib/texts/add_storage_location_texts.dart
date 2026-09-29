class AddStorageLocationTexts {
  const AddStorageLocationTexts._();

  static const storageTypeCabinet = 'Cabinet';
  static const storageTypeFloor = 'Floor';
  static const storageTypeRack = 'Rack';

  static const storageLayoutBulk = 'Bulk';

  static const environmentIndoor = 'Indoor';
  static const environmentOutdoor = 'Outdoor';

  static const compartmentNone = 'None';
  static const compartmentDrawer = 'Drawer';
  static const compartmentShelf = 'Shelf';
  static const compartmentBoth = 'Both';

  static const drawersTitle = 'Drawers';
  static const shelvesTitle = 'Shelves';

  static const identifierTitle = 'Identifier';
  static const quickNameLabel = 'Quick Name';
  static const quickNameHint = 'Auto: STORAGE-N';
  static const generatedIdentifierLabel = 'Generated Identifier';
  static const loadingText = 'Loading...';
  static const identifierHelpText =
      'Quick Name auto-generates from storage type with an incrementing number. Generated Identifier auto-builds from current selections and field values, with duplicate-safe final numbering.';

  static const storageTitle = 'Storage';
  static const environmentTitle = 'Environment';
  static const compartmentTitle = 'Compartment';

  static const numberOfDrawersLabel = 'Number of Drawers';
  static const numberOfShelvesLabel = 'Number of Shelves';
  static const lengthLabel = 'Length';
  static const widthLabel = 'Width';
  static const heightLabel = 'Height';
  static const maxWeightLabel = 'Max Weight';
  static const createMultipleLabel = 'Create Multiple';
  static const savingButton = 'Saving...';
  static const createLocationsButton = 'Create Locations';

  static const identifierPrefixQuickName = 'QN';
  static const identifierPrefixStorageType = 'ST';
  static const identifierPrefixEnvironment = 'ENV';
  static const identifierPrefixGrouping = 'GRP';
  static const identifierPrefixCompartment = 'CMP';
  static const identifierPrefixDrawers = 'DRW';
  static const identifierPrefixDrawerRows = 'DRR';
  static const identifierPrefixDrawerColumns = 'DRC';
  static const identifierPrefixShelves = 'SHF';
  static const identifierPrefixShelfRows = 'SHR';
  static const identifierPrefixShelfColumns = 'SHC';
  static const identifierPrefixLength = 'L';
  static const identifierPrefixWidth = 'W';
  static const identifierPrefixHeight = 'H';
  static const identifierPrefixWeight = 'WT';

  static const identifierAutoFallback = 'AUTO';
  static const identifierZeroFallback = '0';
  static const identifierNotAvailableFallback = 'NA';
  static const separatorDash = '-';
  static const whitespace = ' ';

  static const unitCentimetre = 'cm';
  static const unitInch = 'in';
  static const unitKilogram = 'kg';
  static const unitPounds = 'lbs';

  static const identifierNonAlphaNumericPattern = r'[^A-Z0-9]+';
  static const identifierRepeatedDashPattern = r'-+';
  static const identifierTrimEdgeDashPattern = r'^-+|-+$';

  static String savedLocationsMessage(int count) {
    return count == 1 ? 'Saved 1 location' : 'Saved $count locations';
  }

  static String saveLocationsFailedMessage(Object error) {
    return 'Failed to save locations: $error';
  }

  static String dimensionUnit(bool useMetric) {
    return useMetric ? unitCentimetre : unitInch;
  }

  static String weightUnit(bool useMetric) {
    return useMetric ? unitKilogram : unitPounds;
  }

  static String hyphenJoin(List<String> parts) {
    return parts.join(separatorDash);
  }

  static String appendSequence(String base, int sequence) {
    return '$base$separatorDash$sequence';
  }
}
