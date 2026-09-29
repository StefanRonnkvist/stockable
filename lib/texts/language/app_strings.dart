import 'package:flutter/material.dart';

import 'en.dart';

/// Abstract base for all app-level localised strings.
///
/// The app currently ships with English strings only.
abstract class AppStrings {
  static AppStrings forLocale(Locale? locale) {
    return AppStringsEN();
  }

  // ── Common / Shared ────────────────────────────────────────────────────────

  String get cancelButton;
  String get closeButton;
  String get saveButton;
  String get deleteButton;
  String get retryButton;
  String get editTooltip;
  String get deleteTooltip;
  String get savingButton;
  String get loadingText;
  String get metricLabel;
  String get imperialLabel;
  String get centimetresAndKilograms;
  String get inchesAndPounds;
  String get lengthLabel;
  String get widthLabel;
  String get heightLabel;
  String get weightLabel;
  String get numberOfDrawersLabel;
  String get numberOfShelvesLabel;
  String get drawersTitle;
  String get shelvesTitle;
  String get compartmentDrawer;
  String get compartmentShelf;
  String get compartmentBoth;
  String get compartmentNone;
  String get storageTypeCabinet;
  String get storageTypeFloor;
  String get storageTypeRack;
  String get storageLayoutBulk;
  String get environmentIndoor;
  String get environmentOutdoor;

  // ── App / Home ─────────────────────────────────────────────────────────────

  String get appTitle;
  String get webDatabaseWarning;
  List<String> get tabs;
  String get informationContactTab;
  String get informationSubmissionsTab;

  // ── Add Storage Location ───────────────────────────────────────────────────

  String get identifierTitle;
  String get quickNameLabel;
  String get quickNameHint;
  String get generatedIdentifierLabel;
  String get identifierHelpText;
  String get storageTitle;
  String get environmentTitle;
  String get compartmentTitle;
  String get maxWeightLabel;
  String get createMultipleLabel;
  String get createLocationsButton;
  String savedLocationsMessage(int count);
  String saveLocationsFailedMessage(Object error);

  // ── Help ───────────────────────────────────────────────────────────────────

  String get gettingStartedTitle;
  String get gettingStartedDescription;
  String get setupTabsTitle;
  String get operationsTabsTitle;
  String get supportTabsTitle;
  String get helpLocationAssignmentTitle;
  String get helpLocationAssignmentDescription;
  String get helpAddStorageLocationTitle;
  String get helpAddStorageLocationDescription;
  String get helpInventoryTitle;
  String get helpInventoryDescription;
  String get helpReportsTitle;
  String get helpReportsDescription;
  String get helpSettingsTitle;
  String get helpSettingsDescription;
  String get helpInformationTitle;
  String get helpInformationDescription;
  String get helpHelpTitle;
  String get helpHelpDescription;
  String get limitationsTitle;
  String get limitationsDescription;
  String get noticeTitle;

  // ── Inventory ──────────────────────────────────────────────────────────────

  String get addSparePartTitle;
  String get oemPartNumberLabel;
  String get localPartNumberLabel;
  String get descriptionLabel;
  String get storageLocationLabel;
  String get minimumOrderQuantityLabel;
  String get failedToLoadLocations;
  String get compartmentLabel;
  String get unitsLabel;
  String get batchLabel;
  String get deleteStorageLocationTitle;
  String get dimensionsPrefix;
  String get weightPrefix;
  String get updatedPrefix;
  String get editStorageLocationTitle;
  String get locationIdentifierLabel;
  String get drawerLengthLabel;
  String get drawerWidthLabel;
  String get drawerHeightLabel;
  String get drawerMaxWeightLabel;
  String get shelfLengthLabel;
  String get shelfWidthLabel;
  String get shelfHeightLabel;
  String get shelfMaxWeightLabel;
  String get saveChangesButton;
  String get locationIdentifierEmptyError;
  String get locationIdentifierDuplicateError;
  String updatedLocationMessage(String code);
  String failedToUpdateLocationMessage(Object error);
  String deleteLocationPrompt(String code);
  String deletedLocationMessage(String code);
  String failedToDeleteLocationMessage(Object error);

  // ── Location Assignment ────────────────────────────────────────────────────

  String get locationSelectorTitle;
  String get noLocationsFound;
  String get allStorageLocationsLabel;
  String get storageDetailTitle;
  String get selectLocationForDetails;
  String get storagePictureTitle;
  String get mergeInstructions;
  String get mergeButton;
  String get unmergeButton;
  String get selectLocationToDraw;
  String get noDrawersOrShelvesConfigured;
  String get storageLabel;
  String get environmentLabel;
  String get groupingLabel;
  String get drawersShelvesLabel;
  String get dimensionsLabel;
  String get drawerRowsColumnsLabel;
  String get drawerDimensionsLabel;
  String get shelfRowsColumnsLabel;
  String get shelfDimensionsLabel;
  String get incrementLabel;
  String get mergeNeedTwoAdjacent;
  String get unmergeNeedTwoMerged;
  String get selectSlotsCurrentLocation;
  String get selectSameContainer;
  String get selectedMustBeAdjacent;
  String get locationsNotMerged;
  String get slotDialogContentsLabel;
  String get slotDialogContentsHint;
  String drawerTitle(int index);
  String shelfTitle(int index);

  // ── Reports ────────────────────────────────────────────────────────────────

  String get reportsPageTitle;

  // ── Settings ───────────────────────────────────────────────────────────────

  String get appearanceTitle;
  String get systemLabel;
  String get lightLabel;
  String get darkLabel;
  String get systemAppearanceNote;
  String get languageTitle;
  String get languageSystemLabel;
  String get languageSystemNote;
  String get unitsTitle;
  String get metricUnits;
  String get imperialUnits;
  String get dbControlTitle;
  String get dbDiagnosticsTitle;
  String get exportImportTitle;
  String get showDbPathButton;
  String get integrityCheckButton;
  String get optimizeDbButton;
  String get rebuildIndexesButton;
  String get clearLocationDataButton;
  String get exportJsonButton;
  String get importXmlButton;
  String get exportJsonSuccess;
  String get exportLocationsWithInventoryButton;
  String get exportLocationsWithInventorySuccess;
  String get importXmlSuccess;
  String get importXmlDialogTitle;
  String get importXmlDialogContent;
  String get importXmlConfirmButton;
  String get templatesSectionTitle;
  String get csvTemplatesHeaderOnlyNote;
  String get generateLocationsXmlTemplateButton;
  String get generateInventoryXmlTemplateButton;
  String get generateLocationsCsvTemplateButton;
  String get generateInventoryCsvTemplateButton;
  String get templateSavedSuccess;
  String get diagnosticsSectionTitle;
  String get runDiagnosticsButton;
  String get copyResultsButton;
  String get latestReportTitle;
  String get latestReportSubtitle;
  String get diagnosticsReportCopied;
  String get databasePathDialogTitle;
  String get clearLocationDataDialogTitle;
  String get deleteAllButton;
  String get databaseTitle;
  String get databaseDisabledOnWeb;
  String get diagnosticsAllPassed;
  String get databaseOptimized;
  String get indexesRebuilt;
  String get allStorageLocationDataCleared;
  String get diagnosticsLabelOpenDatabase;
  String get diagnosticsLabelIntegrityCheck;
  String get diagnosticsLabelStorageLocationCount;
  String get diagnosticsLabelDatabasePathRead;
  String get diagnosticsOpenDatabaseSuccess;
  String get diagnosticsReportHeader;
  String get diagnosticsRuntimeLabel;
  String get diagnosticsLastRunLabel;
  String get diagnosticsPassLabel;
  String get diagnosticsFailLabel;
  String get diagnosticsTotalLabel;
  String get diagnosticsResultsLabel;
  String passFailMessage(int passCount, int failCount);
  String diagnosticsResultSummary(int passCount, int failCount);
  String clearLocationDataPrompt(int count);
  String databaseActionFailed(Object error);
  String integrityCheckResultMessage(String result);
  String runtimeLabel(bool isWeb);
  String diagnosticsStatus(bool passed);
  String diagnosticsResultLine(String status, String label, String detail);
}
