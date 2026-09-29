class SettingsTexts {
  const SettingsTexts._();

  static const appearanceTitle = 'Appearance';
  static const systemLabel = 'System';
  static const lightLabel = 'Light';
  static const darkLabel = 'Dark';
  static const systemAppearanceNote =
      'System uses the device default appearance.';

  static const languageTitle = 'Language';
  static const languageSystemLabel = 'System';
  static const languageEnglishLabel = 'English';
  static const languageGermanLabel = 'Deutsch';
  static const languageSpanishLabel = 'Español';
  static const languageFrenchLabel = 'Français';
  static const languageItalianLabel = 'Italiano';
  static const languageSystemNote = 'System uses the device default language.';

  static const unitsTitle = 'Units';
  static const metricLabel = 'Metric';
  static const imperialLabel = 'Imperial';
  static const metricUnits = 'Centimetres & kilograms';
  static const imperialUnits = 'Inches & pounds';

  static const dbControlTitle = 'DB Control';
  static const dbDiagnosticsTitle = 'Diagnostics';
  static const exportImportTitle = 'Export / Import';
  static const showDbPathButton = 'Show DB Path';
  static const integrityCheckButton = 'Integrity Check';
  static const optimizeDbButton = 'Optimize DB';
  static const rebuildIndexesButton = 'Rebuild Indexes';
  static const clearLocationDataButton = 'Clear Location Data';

  static const diagnosticsSectionTitle = 'Database Diagnostics';
  static const runDiagnosticsButton = 'Run Diagnostics';
  static const copyResultsButton = 'Copy Results';
  static const latestReportTitle = 'Latest Report';
  static const latestReportSubtitle = 'Tap to view full diagnostics output';

  static const diagnosticsReportCopied = 'Diagnostics report copied.';
  static const databaseActionFailedPrefix = 'Database action failed:';
  static const databasePathDialogTitle = 'Database Path';
  static const closeButton = 'Close';
  static const clearLocationDataDialogTitle = 'Clear Location Data';
  static const cancelButton = 'Cancel';
  static const deleteAllButton = 'Delete All';

  static const databaseTitle = 'Database';
  static const databaseDisabledOnWeb =
      'Database controls are disabled in Web/PWA builds.';

  static const diagnosticsLabelOpenDatabase = 'Open Database';
  static const diagnosticsLabelIntegrityCheck = 'Integrity Check';
  static const diagnosticsLabelStorageLocationCount =
      'Storage Location Count Query';
  static const diagnosticsLabelDatabasePathRead = 'Database Path Read';

  static const diagnosticsOpenDatabaseSuccess = 'Database opened successfully';
  static const diagnosticsDatabasePathEmpty = 'Database path is empty';
  static const integrityOk = 'ok';
  static const runtimeWeb = 'Web';
  static const runtimeNative = 'Native';
  static const diagnosticsStatusPass = 'PASS';
  static const diagnosticsStatusFail = 'FAIL';

  static const diagnosticsReportHeader = 'Database Diagnostics Report';
  static const diagnosticsRuntimeLabel = 'Runtime';
  static const diagnosticsLastRunLabel = 'Last run';
  static const diagnosticsPassLabel = 'Pass';
  static const diagnosticsFailLabel = 'Fail';
  static const diagnosticsTotalLabel = 'Total';
  static const diagnosticsResultsLabel = 'Results:';

  static const diagnosticsAllPassed =
      'Diagnostics complete: all checks passed.';
  static const databaseOptimized = 'Database optimized.';
  static const indexesRebuilt = 'Indexes rebuilt.';
  static const allStorageLocationDataCleared =
      'All storage location data cleared.';
  static const exportJsonButton = 'Export JSON';
  static const importXmlButton = 'Import XML';
  static const exportJsonSuccess = 'Database exported to JSON.';
  static const exportLocationsWithInventoryButton =
      'Export Locations + Inventory';
  static const exportLocationsWithInventorySuccess =
      'Storage locations and inventory exported.';
  static const importXmlSuccess = 'Database imported from XML.';
  static const importXmlDialogTitle = 'Import from XML';
  static const importXmlDialogContent =
      'This will replace ALL existing data with the contents of the selected XML file. This cannot be undone.';
  static const importXmlConfirmButton = 'Import';

  static const templatesSectionTitle = 'CSV Templates';
  static const generateLocationsCsvTemplateButton =
      'Generate Locations CSV Template';
  static const generateInventoryCsvTemplateButton =
      'Generate Inventory CSV Templates';
  static const templateSavedSuccess = 'Template saved.';
  static const locationsCsvTemplateOutputFileName =
      'stockable_locations_template.csv';
  static const inventoryContentsCsvTemplateOutputFileName =
      'stockable_inventory_contents_template.csv';
  static const inventoryMergesCsvTemplateOutputFileName =
      'stockable_inventory_merges_template.csv';

  static const locationsCsvTemplate =
      '''id,location_code,batch_id,batch_index,batch_size,use_metric,storage_type,storage_environment,storage_layout,compartment_type,drawers,shelves,drawer_rows,drawer_columns,shelf_rows,shelf_columns,min_length,max_length,min_width,max_width,min_height,max_height,min_weight,max_weight,drawer_length,drawer_width,drawer_height,drawer_max_weight,shelf_length,shelf_width,shelf_height,shelf_max_weight,created_at,updated_at
''';

  static const inventoryContentsCsvTemplate =
      '''id,location_code,slot_type,container_label,slot_label,contents,updated_at
''';

  static const inventoryMergesCsvTemplate =
      '''id,location_code,slot_type,container_label,first_slot_label,second_slot_label,updated_at
''';

  static String unitTitle(bool useMetric) =>
      useMetric ? metricLabel : imperialLabel;

  static String unitSubtitle(bool useMetric) =>
      useMetric ? metricUnits : imperialUnits;

  static String lastRunMessage(String timestamp) =>
      '$diagnosticsLastRunLabel: $timestamp';

  static String passFailMessage(int passCount, int failCount) =>
      'Passed: $passCount  Failed: $failCount';

  static String diagnosticsResultSummary(int passCount, int failCount) =>
      'Diagnostics complete: $passCount passed, $failCount failed.';

  static String diagnosticsIntegrityResult(String result) => 'Result: $result';

  static String diagnosticsIntegrityError(String result) =>
      'PRAGMA integrity_check returned "$result"';

  static String diagnosticsStorageLocationCountRows(int count) =>
      'Rows counted: $count';

  static String databaseActionFailed(Object error) =>
      '$databaseActionFailedPrefix $error';

  static String integrityCheckResultMessage(String result) =>
      'Integrity check: $result';

  static String clearLocationDataPrompt(int count) =>
      'Delete all $count storage location records?';

  static String runtimeLabel(bool isWeb) => isWeb ? runtimeWeb : runtimeNative;

  static String diagnosticsStatus(bool passed) =>
      passed ? diagnosticsStatusPass : diagnosticsStatusFail;

  static String diagnosticsResultLine(
    String status,
    String label,
    String detail,
  ) {
    return '- [$status] $label: $detail';
  }
}
