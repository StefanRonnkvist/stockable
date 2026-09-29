import 'app_strings.dart';

class AppStringsEN extends AppStrings {
  // ── Common / Shared ────────────────────────────────────────────────────────

  @override
  String get cancelButton => 'Cancel';
  @override
  String get closeButton => 'Close';
  @override
  String get saveButton => 'Save';
  @override
  String get deleteButton => 'Delete';
  @override
  String get retryButton => 'Retry';
  @override
  String get editTooltip => 'Edit';
  @override
  String get deleteTooltip => 'Delete';
  @override
  String get savingButton => 'Saving...';
  @override
  String get loadingText => 'Loading...';
  @override
  String get metricLabel => 'Metric';
  @override
  String get imperialLabel => 'Imperial';
  @override
  String get centimetresAndKilograms => 'Centimetres & kilograms';
  @override
  String get inchesAndPounds => 'Inches & pounds';
  @override
  String get lengthLabel => 'Length';
  @override
  String get widthLabel => 'Width';
  @override
  String get heightLabel => 'Height';
  @override
  String get weightLabel => 'Weight';
  @override
  String get numberOfDrawersLabel => 'Number of Drawers';
  @override
  String get numberOfShelvesLabel => 'Number of Shelves';
  @override
  String get drawersTitle => 'Drawers';
  @override
  String get shelvesTitle => 'Shelves';
  @override
  String get compartmentDrawer => 'Drawer';
  @override
  String get compartmentShelf => 'Shelf';
  @override
  String get compartmentBoth => 'Both';
  @override
  String get compartmentNone => 'None';
  @override
  String get storageTypeCabinet => 'Cabinet';
  @override
  String get storageTypeFloor => 'Floor';
  @override
  String get storageTypeRack => 'Rack';
  @override
  String get storageLayoutBulk => 'Bulk';
  @override
  String get environmentIndoor => 'Indoor';
  @override
  String get environmentOutdoor => 'Outdoor';

  // ── App / Home ─────────────────────────────────────────────────────────────

  @override
  String get appTitle => 'Stockable';
  @override
  String get webDatabaseWarning =>
      'PWA notice: database functions are not available on web builds. '
      'Data is temporary for this browser session only.';
  @override
  List<String> get tabs => const [
    'Location Assignment',
    'Add Storage Location',
    'Inventory',
    'Reports',
    'Settings',
    'Help',
    'Information',
  ];
  @override
  String get informationContactTab => 'Contact';
  @override
  String get informationSubmissionsTab => 'Submissions';

  // ── Add Storage Location ───────────────────────────────────────────────────

  @override
  String get identifierTitle => 'Identifier';
  @override
  String get quickNameLabel => 'Quick Name';
  @override
  String get quickNameHint => 'Auto: STORAGE-N';
  @override
  String get generatedIdentifierLabel => 'Generated Identifier';
  @override
  String get identifierHelpText =>
      'Quick Name is auto-generated from storage type with an incrementing '
      'number. Generated Identifier is auto-built from current selections and '
      'field values, with duplicate-safe final numbering.';
  @override
  String get storageTitle => 'Storage';
  @override
  String get environmentTitle => 'Environment';
  @override
  String get compartmentTitle => 'Compartment';
  @override
  String get maxWeightLabel => 'Max Weight';
  @override
  String get createMultipleLabel => 'Create Multiple Locations';
  @override
  String get createLocationsButton => 'Create Locations';
  @override
  String savedLocationsMessage(int count) =>
      count == 1 ? 'Saved 1 location' : 'Saved $count locations';
  @override
  String saveLocationsFailedMessage(Object error) =>
      'Failed to save locations: $error';

  // ── Help ───────────────────────────────────────────────────────────────────

  @override
  String get gettingStartedTitle => 'Getting Started';
  @override
  String get gettingStartedDescription =>
      'Create your first cabinet, floor area, or rack in Add Storage Location. '
      'Open Location Assignment to select the location, long-press a slot to '
      'name its contents, or select two adjacent slots to merge them. '
      'Use Inventory to review, edit, or delete location records. '
      'Use Settings to choose units, maintain the local database, and export '
      'your data.';
  @override
  String get setupTabsTitle => 'Setup Tabs';
  @override
  String get operationsTabsTitle => 'Operations Tabs';
  @override
  String get supportTabsTitle => 'Support Tabs';
  @override
  String get helpLocationAssignmentTitle => 'Location Assignment';
  @override
  String get helpLocationAssignmentDescription =>
      'Choose a saved location and review its decoded layout and dimensions. '
      'Long-press a drawer or shelf slot to add or edit its contents. '
      'Tap two adjacent slots, then use Merge or Unmerge to match the physical '
      'compartment layout.';
  @override
  String get helpAddStorageLocationTitle => 'Add Storage Location';
  @override
  String get helpAddStorageLocationDescription =>
      'Create cabinet, floor, or rack locations with auto-generated quick names '
      'and unique identifiers. Choose indoor or outdoor use, set dimensions '
      'and weight limits, and configure drawers or shelves where supported. '
      'Create Multiple Locations saves a numbered batch with the same layout.';
  @override
  String get helpInventoryTitle => 'Inventory';
  @override
  String get helpInventoryDescription =>
      'Review saved storage locations and pull down to refresh the list. '
      'Use the edit and delete actions to maintain location records. '
      'The Add Spare Part fields are a preview in this release and do not yet '
      'save inventory items.';
  @override
  String get helpReportsTitle => 'Reports';
  @override
  String get helpReportsDescription =>
      'Reports is reserved for future summaries and analytics. No reports are '
      'generated in this release.';
  @override
  String get helpSettingsTitle => 'Settings';
  @override
  String get helpSettingsDescription =>
      'Choose system, light, or dark appearance and metric or imperial units. '
      'On supported desktop and mobile builds, DB Control can inspect and '
      'maintain the local database, clear location data, export JSON, import '
      'XML, export locations with inventory to XML, and save XML or CSV '
      'templates. Export before clearing or replacing important data.';
  @override
  String get helpInformationTitle => 'Information';
  @override
  String get helpInformationDescription =>
      'Use Contact to send a support question through the online form. '
      'Submissions shows entries associated with Stockable. These features '
      'require a network connection.';
  @override
  String get helpHelpTitle => 'Help';
  @override
  String get helpHelpDescription =>
      'Help opens automatically when no saved locations are found. Return here '
      'for the recommended workflow, interaction tips, and current feature '
      'limitations.';
  @override
  String get limitationsTitle => 'Current Limitations';
  @override
  String get limitationsDescription =>
      'The Add Spare Part fields in Inventory are a preview and do not save '
      'items yet. Reports is a placeholder and generates no output. Web and '
      'PWA builds have no persistent database, so data lasts only for the '
      'browser session. The interface is currently available in English. '
      'Contact and Submissions require a network connection.';
  @override
  String get noticeTitle => 'Notice';

  // ── Inventory ──────────────────────────────────────────────────────────────

  @override
  String get addSparePartTitle => 'Add Spare Part';
  @override
  String get oemPartNumberLabel => 'OEM Part Number';
  @override
  String get localPartNumberLabel => 'Local Part Number';
  @override
  String get descriptionLabel => 'Description';
  @override
  String get storageLocationLabel => 'Storage Location';
  @override
  String get minimumOrderQuantityLabel => 'Minimum Order Quantity (MOQ)';
  @override
  String get failedToLoadLocations => 'Failed to load storage locations.';
  @override
  String get compartmentLabel => 'Compartment';
  @override
  String get unitsLabel => 'Units';
  @override
  String get batchLabel => 'Batch';
  @override
  String get deleteStorageLocationTitle => 'Delete Storage Location';
  @override
  String get dimensionsPrefix => 'Dimensions';
  @override
  String get weightPrefix => 'Weight';
  @override
  String get updatedPrefix => 'Updated';
  @override
  String get editStorageLocationTitle => 'Edit Storage Location';
  @override
  String get locationIdentifierLabel => 'Location Identifier';
  @override
  String get drawerLengthLabel => 'Drawer Length';
  @override
  String get drawerWidthLabel => 'Drawer Width';
  @override
  String get drawerHeightLabel => 'Drawer Height';
  @override
  String get drawerMaxWeightLabel => 'Drawer Max Weight';
  @override
  String get shelfLengthLabel => 'Shelf Length';
  @override
  String get shelfWidthLabel => 'Shelf Width';
  @override
  String get shelfHeightLabel => 'Shelf Height';
  @override
  String get shelfMaxWeightLabel => 'Shelf Max Weight';
  @override
  String get saveChangesButton => 'Save Changes';
  @override
  String get locationIdentifierEmptyError =>
      'Location identifier cannot be empty.';
  @override
  String get locationIdentifierDuplicateError =>
      'This identifier is already in use.';
  @override
  String updatedLocationMessage(String code) => 'Updated $code';
  @override
  String failedToUpdateLocationMessage(Object error) =>
      'Failed to update location: $error';
  @override
  String deleteLocationPrompt(String code) => 'Delete $code?';
  @override
  String deletedLocationMessage(String code) => 'Deleted $code';
  @override
  String failedToDeleteLocationMessage(Object error) =>
      'Failed to delete location: $error';

  // ── Location Assignment ────────────────────────────────────────────────────

  @override
  String get locationSelectorTitle => 'Storage Location';
  @override
  String get noLocationsFound => 'No storage locations found.';
  @override
  String get allStorageLocationsLabel => 'All storage locations';
  @override
  String get storageDetailTitle => 'Storage Detail';
  @override
  String get selectLocationForDetails =>
      'Select a storage location to view details.';
  @override
  String get storagePictureTitle => 'Storage Picture';
  @override
  String get mergeInstructions =>
      'Tap two adjacent locations, then select Merge or Unmerge. '
      'Long-press a location to edit contents.';
  @override
  String get mergeButton => 'Merge';
  @override
  String get unmergeButton => 'Unmerge';
  @override
  String get selectLocationToDraw =>
      'Select a storage location to draw picture.';
  @override
  String get noDrawersOrShelvesConfigured =>
      'No drawers or shelves configured.';
  @override
  String get storageLabel => 'Storage';
  @override
  String get environmentLabel => 'Environment';
  @override
  String get groupingLabel => 'Grouping';
  @override
  String get drawersShelvesLabel => 'Drawers/Shelves';
  @override
  String get dimensionsLabel => 'Dimensions (LxWxH)';
  @override
  String get drawerRowsColumnsLabel => 'Drawer Rows/Columns';
  @override
  String get drawerDimensionsLabel => 'Drawer Dimensions (LxWxH)';
  @override
  String get shelfRowsColumnsLabel => 'Shelf Rows/Columns';
  @override
  String get shelfDimensionsLabel => 'Shelf Dimensions (LxWxH)';
  @override
  String get incrementLabel => 'Increment';
  @override
  String get mergeNeedTwoAdjacent => 'Select two adjacent locations to merge.';
  @override
  String get unmergeNeedTwoMerged => 'Select two merged locations to unmerge.';
  @override
  String get selectSlotsCurrentLocation =>
      'Select slots from the current location.';
  @override
  String get selectSameContainer =>
      'Select both locations in the same drawer/shelf.';
  @override
  String get selectedMustBeAdjacent => 'Selected locations must be adjacent.';
  @override
  String get locationsNotMerged => 'These locations are not merged.';
  @override
  String get slotDialogContentsLabel => 'Contents';
  @override
  String get slotDialogContentsHint => 'Enter item contents';
  @override
  String drawerTitle(int index) => 'Drawer $index';
  @override
  String shelfTitle(int index) => 'Shelf $index';

  // ── Reports ────────────────────────────────────────────────────────────────

  @override
  String get reportsPageTitle => 'Reports Page';

  // ── Settings ───────────────────────────────────────────────────────────────

  @override
  String get appearanceTitle => 'Appearance';
  @override
  String get systemLabel => 'System';
  @override
  String get lightLabel => 'Light';
  @override
  String get darkLabel => 'Dark';
  @override
  String get systemAppearanceNote =>
      'System uses the device default appearance.';
  @override
  String get languageTitle => 'Language';
  @override
  String get languageSystemLabel => 'System';
  @override
  String get languageSystemNote => 'System uses the device default language.';
  @override
  String get unitsTitle => 'Units';
  @override
  String get metricUnits => 'Centimetres & kilograms';
  @override
  String get imperialUnits => 'Inches & pounds';
  @override
  String get dbControlTitle => 'DB Control';
  @override
  String get dbDiagnosticsTitle => 'Diagnostics';
  @override
  String get exportImportTitle => 'Export / Import';
  @override
  String get showDbPathButton => 'Show DB Path';
  @override
  String get integrityCheckButton => 'Integrity Check';
  @override
  String get optimizeDbButton => 'Optimize DB';
  @override
  String get rebuildIndexesButton => 'Rebuild Indexes';
  @override
  String get clearLocationDataButton => 'Clear Location Data';
  @override
  String get exportJsonButton => 'Export JSON';
  @override
  String get importXmlButton => 'Import XML';
  @override
  String get exportJsonSuccess => 'Database exported to JSON.';
  @override
  String get exportLocationsWithInventoryButton =>
      'Export Locations + Inventory';
  @override
  String get exportLocationsWithInventorySuccess =>
      'Storage locations and inventory exported.';
  @override
  String get importXmlSuccess => 'Database imported from XML.';
  @override
  String get importXmlDialogTitle => 'Import from XML';
  @override
  String get importXmlDialogContent =>
      'This will replace ALL existing data with the contents of the selected XML file. This cannot be undone.';
  @override
  String get importXmlConfirmButton => 'Import';
  @override
  String get templatesSectionTitle => 'Templates';
  @override
  String get csvTemplatesHeaderOnlyNote =>
      'CSV templates include headers only.';
  @override
  String get generateLocationsXmlTemplateButton =>
      'Save Locations XML Template';
  @override
  String get generateInventoryXmlTemplateButton =>
      'Save Inventory XML Template';
  @override
  String get generateLocationsCsvTemplateButton =>
      'Generate Locations CSV Template';
  @override
  String get generateInventoryCsvTemplateButton =>
      'Generate Inventory CSV Templates';
  @override
  String get templateSavedSuccess => 'Template saved.';
  @override
  String get diagnosticsSectionTitle => 'Database Diagnostics';
  @override
  String get runDiagnosticsButton => 'Run Diagnostics';
  @override
  String get copyResultsButton => 'Copy Results';
  @override
  String get latestReportTitle => 'Latest Report';
  @override
  String get latestReportSubtitle => 'Tap to view full diagnostics output';
  @override
  String get diagnosticsReportCopied => 'Diagnostics report copied.';
  @override
  String get databasePathDialogTitle => 'Database Path';
  @override
  String get clearLocationDataDialogTitle => 'Clear Location Data';
  @override
  String get deleteAllButton => 'Delete All';
  @override
  String get databaseTitle => 'Database';
  @override
  String get databaseDisabledOnWeb =>
      'Database controls are disabled in Web/PWA builds.';
  @override
  String get diagnosticsAllPassed => 'Diagnostics complete: all checks passed.';
  @override
  String get databaseOptimized => 'Database optimized.';
  @override
  String get indexesRebuilt => 'Indexes rebuilt.';
  @override
  String get allStorageLocationDataCleared =>
      'All storage location data cleared.';
  @override
  String get diagnosticsLabelOpenDatabase => 'Open Database';
  @override
  String get diagnosticsLabelIntegrityCheck => 'Integrity Check';
  @override
  String get diagnosticsLabelStorageLocationCount =>
      'Storage Location Count Query';
  @override
  String get diagnosticsLabelDatabasePathRead => 'Database Path Read';
  @override
  String get diagnosticsOpenDatabaseSuccess => 'Database opened successfully';
  @override
  String get diagnosticsReportHeader => 'Database Diagnostics Report';
  @override
  String get diagnosticsRuntimeLabel => 'Runtime';
  @override
  String get diagnosticsLastRunLabel => 'Last run';
  @override
  String get diagnosticsPassLabel => 'Pass';
  @override
  String get diagnosticsFailLabel => 'Fail';
  @override
  String get diagnosticsTotalLabel => 'Total';
  @override
  String get diagnosticsResultsLabel => 'Results:';
  @override
  String passFailMessage(int passCount, int failCount) =>
      'Passed: $passCount  Failed: $failCount';
  @override
  String diagnosticsResultSummary(int passCount, int failCount) =>
      'Diagnostics complete: $passCount passed, $failCount failed.';
  @override
  String clearLocationDataPrompt(int count) =>
      'Delete all $count storage location records?';
  @override
  String databaseActionFailed(Object error) => 'Database action failed: $error';
  @override
  String integrityCheckResultMessage(String result) =>
      'Integrity check: $result';
  @override
  String runtimeLabel(bool isWeb) => isWeb ? 'Web' : 'Native';
  @override
  String diagnosticsStatus(bool passed) => passed ? 'PASS' : 'FAIL';
  @override
  String diagnosticsResultLine(String status, String label, String detail) =>
      '- [$status] $label: $detail';
}
