import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../../core/database/app_database.dart';
import '../../texts/language/app_strings.dart';
import '../../texts/repository_texts.dart';
import '../../texts/settings_texts.dart';

/// Manages presentation preferences, database maintenance, and data transfer.
class SettingsTab extends StatefulWidget {
  const SettingsTab({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.useMetric,
    required this.onUnitSystemChanged,
    this.onLocationsCleared,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final bool useMetric;
  final ValueChanged<bool> onUnitSystemChanged;
  final VoidCallback? onLocationsCleared;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  static const _locationsXmlTemplateAsset = 'templates/locations_template.xml';
  static const _inventoryXmlTemplateAsset = 'templates/inventory_template.xml';
  static const _locationsXmlTemplateFileName =
      'stockable_locations_template.xml';
  static const _inventoryXmlTemplateFileName =
      'stockable_inventory_template.xml';

  // Acts as a UI mutex so database and file actions cannot overlap.
  bool _isRunningDbAction = false;
  String? _dbDiagnosticsReport;
  DateTime? _dbDiagnosticsLastRun;
  int _dbDiagnosticsPassCount = 0;
  int _dbDiagnosticsFailCount = 0;

  AppStrings get _strings =>
      AppStrings.forLocale(Localizations.maybeLocaleOf(context));

  @override
  Widget build(BuildContext context) {
    final strings = _strings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsSection(
          title: strings.appearanceTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.system,
                    label: Text(strings.systemLabel),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.light,
                    label: Text(strings.lightLabel),
                  ),
                  ButtonSegment<ThemeMode>(
                    value: ThemeMode.dark,
                    label: Text(strings.darkLabel),
                  ),
                ],
                selected: {widget.themeMode},
                onSelectionChanged: (selection) {
                  widget.onThemeModeChanged(selection.first);
                },
              ),
              const SizedBox(height: 8),
              Text(strings.systemAppearanceNote),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SettingsSection(
          title: strings.unitsTitle,
          child: SwitchListTile(
            title: Text(
              widget.useMetric ? strings.metricLabel : strings.imperialLabel,
            ),
            subtitle: Text(
              widget.useMetric ? strings.metricUnits : strings.imperialUnits,
            ),
            value: widget.useMetric,
            onChanged: widget.onUnitSystemChanged,
          ),
        ),
        const SizedBox(height: 16),
        if (!kIsWeb) ...[
          _SettingsSection(
            title: strings.dbControlTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    strings.dbDiagnosticsTitle,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isRunningDbAction ? null : _showDbPath,
                      icon: const Icon(Icons.folder_open),
                      label: Text(strings.showDbPathButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction ? null : _runIntegrityCheck,
                      icon: const Icon(Icons.health_and_safety_outlined),
                      label: Text(strings.integrityCheckButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction ? null : _optimizeDatabase,
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: Text(strings.optimizeDbButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction ? null : _rebuildIndexes,
                      icon: const Icon(Icons.build_circle_outlined),
                      label: Text(strings.rebuildIndexesButton),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _confirmAndClearLocations,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(strings.clearLocationDataButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _runDatabaseDiagnostics,
                      icon: const Icon(Icons.play_arrow_outlined),
                      label: Text(strings.runDiagnosticsButton),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _isRunningDbAction || _dbDiagnosticsReport == null
                          ? null
                          : _copyDatabaseDiagnosticsReport,
                      icon: const Icon(Icons.content_copy_outlined),
                      label: Text(strings.copyResultsButton),
                    ),
                  ],
                ),
                if (_dbDiagnosticsLastRun != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${strings.diagnosticsLastRunLabel}: ${_formatTimestamp(_dbDiagnosticsLastRun!)}',
                  ),
                  Text(
                    strings.passFailMessage(
                      _dbDiagnosticsPassCount,
                      _dbDiagnosticsFailCount,
                    ),
                  ),
                ],
                if (_dbDiagnosticsReport != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      title: Text(strings.latestReportTitle),
                      subtitle: Text(strings.latestReportSubtitle),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: SelectableText(_dbDiagnosticsReport!),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    strings.exportImportTitle,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isRunningDbAction ? null : _exportJson,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(strings.exportJsonButton),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isRunningDbAction ? null : _importXml,
                      icon: const Icon(Icons.download_outlined),
                      label: Text(strings.importXmlButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _exportLocationsWithInventory,
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: Text(strings.exportLocationsWithInventoryButton),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.templatesSectionTitle,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.csvTemplatesHeaderOnlyNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _generateLocationsXmlTemplate,
                      icon: const Icon(Icons.description_outlined),
                      label: Text(strings.generateLocationsXmlTemplateButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _generateInventoryXmlTemplate,
                      icon: const Icon(Icons.description_outlined),
                      label: Text(strings.generateInventoryXmlTemplateButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _generateLocationsCsvTemplate,
                      icon: const Icon(Icons.table_view_outlined),
                      label: Text(strings.generateLocationsCsvTemplateButton),
                    ),
                    FilledButton.icon(
                      onPressed: _isRunningDbAction
                          ? null
                          : _generateInventoryCsvTemplate,
                      icon: const Icon(Icons.table_view_outlined),
                      label: Text(strings.generateInventoryCsvTemplateButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ] else
          _SettingsSection(
            title: strings.databaseTitle,
            child: Text(strings.databaseDisabledOnWeb),
          ),
      ],
    );
  }

  Future<void> _runDatabaseDiagnostics() async {
    final strings = _strings;

    setState(() => _isRunningDbAction = true);

    final now = DateTime.now();
    final results = <_DbDiagnosticResult>[];

    await _runDiagnosticCheck(
      label: strings.diagnosticsLabelOpenDatabase,
      action: () async {
        await AppDatabase.instance.database;
        return strings.diagnosticsOpenDatabaseSuccess;
      },
      sink: results,
    );

    await _runDiagnosticCheck(
      label: strings.diagnosticsLabelIntegrityCheck,
      action: () async {
        final result = await AppDatabase.instance.integrityCheck();
        if (result.toLowerCase() != SettingsTexts.integrityOk) {
          throw Exception(SettingsTexts.diagnosticsIntegrityError(result));
        }
        return SettingsTexts.diagnosticsIntegrityResult(result);
      },
      sink: results,
    );

    await _runDiagnosticCheck(
      label: strings.diagnosticsLabelStorageLocationCount,
      action: () async {
        final count = await AppDatabase.instance.storageLocationCount();
        return SettingsTexts.diagnosticsStorageLocationCountRows(count);
      },
      sink: results,
    );

    await _runDiagnosticCheck(
      label: strings.diagnosticsLabelDatabasePathRead,
      action: () async {
        final path = await AppDatabase.instance.databasePath();
        if (path.isEmpty) {
          throw Exception(SettingsTexts.diagnosticsDatabasePathEmpty);
        }
        return path;
      },
      sink: results,
    );

    final passCount = results.where((result) => result.passed).length;
    final failCount = results.length - passCount;
    final report = _buildDiagnosticsReport(
      lastRun: now,
      passCount: passCount,
      failCount: failCount,
      results: results,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _dbDiagnosticsLastRun = now;
      _dbDiagnosticsPassCount = passCount;
      _dbDiagnosticsFailCount = failCount;
      _dbDiagnosticsReport = report;
      _isRunningDbAction = false;
    });

    final statusMessage = failCount == 0
        ? strings.diagnosticsAllPassed
        : strings.diagnosticsResultSummary(passCount, failCount);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(statusMessage)));
  }

  /// Runs one diagnostic without aborting the remaining checks on failure.
  Future<void> _runDiagnosticCheck({
    required String label,
    required Future<String> Function() action,
    required List<_DbDiagnosticResult> sink,
  }) async {
    try {
      final detail = await action();
      sink.add(_DbDiagnosticResult(label: label, passed: true, detail: detail));
    } catch (error) {
      sink.add(
        _DbDiagnosticResult(
          label: label,
          passed: false,
          detail: error.toString(),
        ),
      );
    }
  }

  String _buildDiagnosticsReport({
    required DateTime lastRun,
    required int passCount,
    required int failCount,
    required List<_DbDiagnosticResult> results,
  }) {
    final strings = _strings;
    final runtimeType = strings.runtimeLabel(kIsWeb);
    final buffer = StringBuffer()
      ..writeln(strings.diagnosticsReportHeader)
      ..writeln("${strings.diagnosticsRuntimeLabel}: $runtimeType")
      ..writeln(
        "${strings.diagnosticsLastRunLabel}: ${_formatTimestamp(lastRun)}",
      )
      ..writeln("${strings.diagnosticsPassLabel}: $passCount")
      ..writeln("${strings.diagnosticsFailLabel}: $failCount")
      ..writeln("${strings.diagnosticsTotalLabel}: ${results.length}")
      ..writeln(strings.diagnosticsResultsLabel);

    for (final result in results) {
      final status = strings.diagnosticsStatus(result.passed);
      buffer.writeln(
        strings.diagnosticsResultLine(status, result.label, result.detail),
      );
    }

    return buffer.toString().trimRight();
  }

  String _formatTimestamp(DateTime timestamp) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return "${timestamp.year}-${twoDigits(timestamp.month)}-${twoDigits(timestamp.day)} "
        "${twoDigits(timestamp.hour)}:${twoDigits(timestamp.minute)}:${twoDigits(timestamp.second)}";
  }

  Future<void> _copyDatabaseDiagnosticsReport() async {
    final strings = _strings;

    final report = _dbDiagnosticsReport;
    if (report == null) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: report));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.diagnosticsReportCopied)));
  }

  /// Runs a maintenance action with shared busy state and user feedback.
  Future<bool> _runDbAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() => _isRunningDbAction = true);

    try {
      await action();
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      final strings = _strings;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
      return false;
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }

  Future<void> _showDbPath() async {
    final strings = _strings;

    final dbPath = await AppDatabase.instance.databasePath();
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.databasePathDialogTitle),
          content: SelectableText(dbPath),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.closeButton),
            ),
          ],
        );
      },
    );
  }

  Future<void> _runIntegrityCheck() async {
    final strings = _strings;

    setState(() => _isRunningDbAction = true);
    try {
      final result = await AppDatabase.instance.integrityCheck();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.integrityCheckResultMessage(result))),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }

  Future<void> _optimizeDatabase() async {
    final strings = _strings;

    await _runDbAction(
      action: () => AppDatabase.instance.optimize(),
      successMessage: strings.databaseOptimized,
    );
  }

  Future<void> _rebuildIndexes() async {
    final strings = _strings;

    await _runDbAction(
      action: () => AppDatabase.instance.rebuildIndexes(),
      successMessage: strings.indexesRebuilt,
    );
  }

  /// Confirms and clears all locations, then notifies dependent feature tabs.
  Future<void> _confirmAndClearLocations() async {
    final strings = _strings;

    final count = await AppDatabase.instance.storageLocationCount();
    if (!mounted) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.clearLocationDataDialogTitle),
          content: Text(strings.clearLocationDataPrompt(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.deleteAllButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final cleared = await _runDbAction(
      action: () => AppDatabase.instance.clearStorageLocations(),
      successMessage: strings.allStorageLocationDataCleared,
    );
    if (cleared && mounted) {
      widget.onLocationsCleared?.call();
    }
  }

  /// Saves generated bytes through the platform file picker.
  Future<void> _saveTemplateFile({
    required Uint8List bytes,
    required String fileName,
    required String extension,
  }) async {
    final strings = _strings;
    setState(() => _isRunningDbAction = true);
    try {
      final savePath = await FilePicker.saveFile(
        dialogTitle: strings.templatesSectionTitle,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [extension],
        bytes: bytes,
      );
      if (savePath == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.templateSavedSuccess)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }

  Future<void> _saveCsvTemplate({
    required String content,
    required String fileName,
  }) => _saveTemplateFile(
    bytes: Uint8List.fromList(utf8.encode(content)),
    fileName: fileName,
    extension: 'csv',
  );

  Future<void> _saveXmlTemplateAsset({
    required String assetPath,
    required String fileName,
  }) async {
    final content = await rootBundle.loadString(assetPath);
    await _saveTemplateFile(
      bytes: Uint8List.fromList(utf8.encode(content)),
      fileName: fileName,
      extension: 'xml',
    );
  }

  Future<void> _generateLocationsXmlTemplate() => _saveXmlTemplateAsset(
    assetPath: _locationsXmlTemplateAsset,
    fileName: _locationsXmlTemplateFileName,
  );

  Future<void> _generateInventoryXmlTemplate() => _saveXmlTemplateAsset(
    assetPath: _inventoryXmlTemplateAsset,
    fileName: _inventoryXmlTemplateFileName,
  );

  Future<void> _generateLocationsCsvTemplate() => _saveCsvTemplate(
    content: SettingsTexts.locationsCsvTemplate,
    fileName: SettingsTexts.locationsCsvTemplateOutputFileName,
  );

  Future<void> _generateInventoryCsvTemplate() async {
    await _saveCsvTemplate(
      content: SettingsTexts.inventoryContentsCsvTemplate,
      fileName: SettingsTexts.inventoryContentsCsvTemplateOutputFileName,
    );
    await _saveCsvTemplate(
      content: SettingsTexts.inventoryMergesCsvTemplate,
      fileName: SettingsTexts.inventoryMergesCsvTemplateOutputFileName,
    );
  }

  /// Exports locations, slot contents, and merges as one escaped XML document.
  Future<void> _exportLocationsWithInventory() async {
    final strings = _strings;
    setState(() => _isRunningDbAction = true);

    try {
      final db = await AppDatabase.instance.database;

      // Query all locations, slot contents, and merges
      final locations = await db.query(RepositoryTexts.storageLocationsTable);
      final slotContents = await db.query(RepositoryTexts.slotContentsTable);
      final slotMerges = await db.query(RepositoryTexts.slotMergesTable);

      // Build XML string
      final buffer = StringBuffer()
        ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
        ..writeln(
          '<!-- Stockable — Storage Locations with Inventory Export -->',
        )
        ..writeln('<stockable>')
        ..writeln()
        ..writeln('  <storage_locations>');

      for (final loc in locations) {
        buffer.writeln('    <row');
        for (final key in loc.keys) {
          final value = loc[key];
          buffer.writeln('      $key="${_xmlEscape(value)}"');
        }
        buffer.writeln('    />');
      }

      buffer.writeln('  </storage_locations>');
      buffer.writeln();
      buffer.writeln('  <location_slot_contents>');

      for (final slot in slotContents) {
        buffer.writeln('    <row');
        for (final key in slot.keys) {
          final value = slot[key];
          buffer.writeln('      $key="${_xmlEscape(value)}"');
        }
        buffer.writeln('    />');
      }

      buffer.writeln('  </location_slot_contents>');
      buffer.writeln();
      buffer.writeln('  <location_slot_merges>');

      for (final merge in slotMerges) {
        buffer.writeln('    <row');
        for (final key in merge.keys) {
          final value = merge[key];
          buffer.writeln('      $key="${_xmlEscape(value)}"');
        }
        buffer.writeln('    />');
      }

      buffer.writeln('  </location_slot_merges>');
      buffer.writeln();
      buffer.writeln('</stockable>');

      final xmlString = buffer.toString();

      // Save to file
      final savePath = await FilePicker.saveFile(
        dialogTitle: strings.exportLocationsWithInventoryButton,
        fileName:
            'stockable_locations_inventory_${DateTime.now().toIso8601String().split('T')[0]}.xml',
        type: FileType.custom,
        allowedExtensions: ['xml'],
        bytes: Uint8List.fromList(utf8.encode(xmlString)),
      );

      if (savePath == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.exportLocationsWithInventorySuccess)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }

  /// Escapes a database value for safe use in an XML attribute.
  String _xmlEscape(Object? value) {
    final str = value?.toString() ?? '';
    return str
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  Future<void> _exportJson() async {
    final strings = _strings;
    setState(() => _isRunningDbAction = true);
    try {
      final jsonString = await AppDatabase.instance.exportToJson();
      final savePath = await FilePicker.saveFile(
        dialogTitle: strings.exportJsonButton,
        fileName: 'stockable_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );
      if (savePath == null) {
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.exportJsonSuccess)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }

  /// Replaces database table contents from a user-confirmed XML file.
  Future<void> _importXml() async {
    final strings = _strings;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.importXmlDialogTitle),
          content: Text(strings.importXmlDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.importXmlConfirmButton),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }

    final pickedFile = await FilePicker.pickFile(
      dialogTitle: strings.importXmlButton,
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (pickedFile == null) {
      return;
    }
    final pickedPath = pickedFile.path;
    if (pickedPath == null) {
      return;
    }

    setState(() => _isRunningDbAction = true);
    try {
      final xmlString = await File(pickedPath).readAsString(encoding: utf8);
      await AppDatabase.instance.importFromXml(xmlString);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.importXmlSuccess)));
      widget.onLocationsCleared?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.databaseActionFailed(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isRunningDbAction = false);
      }
    }
  }
}

class _DbDiagnosticResult {
  const _DbDiagnosticResult({
    required this.label,
    required this.passed,
    required this.detail,
  });

  final String label;
  final bool passed;
  final String detail;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }
}
