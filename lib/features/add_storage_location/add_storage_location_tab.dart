import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'add_storage_location_form_controllers.dart';
import 'storage_location_record.dart';
import 'storage_location_repository.dart';
import '../../texts/language/app_strings.dart';
import '../../texts/add_storage_location_texts.dart';

class AddStorageLocationTab extends StatefulWidget {
  const AddStorageLocationTab({
    super.key,
    required this.useMetric,
    this.onLocationsChanged,
  });

  final bool useMetric;
  final VoidCallback? onLocationsChanged;

  @override
  State<AddStorageLocationTab> createState() => _AddStorageLocationTabState();
}

class _AddStorageLocationTabState extends State<AddStorageLocationTab> {
  late final AddStorageLocationFormControllers _controllers;

  bool _isSaving = false;
  bool _isOutdoor = false;
  // Request IDs ensure slower database lookups cannot overwrite newer input.
  int _identifierRefreshRequestId = 0;
  int _quickNameRefreshRequestId = 0;
  String _generatedLocationCode = '';
  String _locationCodeError = '';
  String _storageType = AddStorageLocationTexts.storageTypeCabinet;
  final String _storageLayout = AddStorageLocationTexts.storageLayoutBulk;
  String _compartmentType = AddStorageLocationTexts.compartmentNone;

  String get _dimensionUnit =>
      AddStorageLocationTexts.dimensionUnit(widget.useMetric);
  String get _weightUnit =>
      AddStorageLocationTexts.weightUnit(widget.useMetric);
  String get _storageEnvironment => _isOutdoor
      ? AddStorageLocationTexts.environmentOutdoor
      : AddStorageLocationTexts.environmentIndoor;

  AppStrings get _strings =>
      AppStrings.forLocale(Localizations.maybeLocaleOf(context));

  @override
  void initState() {
    super.initState();
    _controllers = AddStorageLocationFormControllers.create();
    _attachIdentifierInputListeners();
    _updateQuickNameAuto();
  }

  @override
  void dispose() {
    _detachIdentifierInputListeners();
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildIdentifierSection(),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const minGroupWidth = 320.0;
            const groupSpacing = 16.0;
            final maxWidth = constraints.maxWidth;
            final columnCount =
                (((maxWidth + groupSpacing) / (minGroupWidth + groupSpacing))
                        .floor())
                    .clamp(1, 2);
            final groupWidth =
                (maxWidth - (groupSpacing * (columnCount - 1))) / columnCount;

            return Wrap(
              spacing: groupSpacing,
              runSpacing: groupSpacing,
              children: [
                _buildStorageSection(context, groupWidth),
                _buildEnvironmentSection(context, groupWidth),
                _buildCompartmentSection(context, groupWidth),
                if (_compartmentType ==
                        AddStorageLocationTexts.compartmentDrawer ||
                    _compartmentType == AddStorageLocationTexts.compartmentBoth)
                  _buildCompartmentGroupSection(
                    context,
                    width: groupWidth,
                    title: strings.drawersTitle,
                    children: _buildDrawerFields(),
                  ),
                if (_compartmentType ==
                        AddStorageLocationTexts.compartmentShelf ||
                    _compartmentType == AddStorageLocationTexts.compartmentBoth)
                  _buildCompartmentGroupSection(
                    context,
                    width: groupWidth,
                    title: strings.shelvesTitle,
                    children: _buildShelfFields(),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _buildCreateActions(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildIdentifierSection() {
    final strings = _strings;

    return _FormSection(
      title: strings.identifierTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controllers.locationCode,
            onChanged: (_) {
              if (_locationCodeError.isNotEmpty) {
                setState(() => _locationCodeError = '');
              }
            },
            readOnly: true,
            decoration: InputDecoration(
              labelText: strings.quickNameLabel,
              border: const OutlineInputBorder(),
              hintText: strings.quickNameHint,
              errorText: _locationCodeError.isEmpty ? null : _locationCodeError,
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              labelText: strings.generatedIdentifierLabel,
              border: OutlineInputBorder(),
            ),
            child: Text(
              _generatedLocationCode.isEmpty
                  ? strings.loadingText
                  : _generatedLocationCode,
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.identifierHelpText),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context, double width) {
    final strings = _strings;

    return SizedBox(
      width: width,
      child: _FormSection(
        title: strings.storageTitle,
        child: RadioGroup<String>(
          groupValue: _storageType,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _storageType = value;
              if (value == AddStorageLocationTexts.storageTypeFloor) {
                _compartmentType = AddStorageLocationTexts.compartmentNone;
              }
            });
            _updateQuickNameAuto();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DenseRadioTile(
                label: strings.storageTypeCabinet,
                value: AddStorageLocationTexts.storageTypeCabinet,
              ),
              _DenseRadioTile(
                label: strings.storageTypeFloor,
                value: AddStorageLocationTexts.storageTypeFloor,
              ),
              _DenseRadioTile(
                label: strings.storageTypeRack,
                value: AddStorageLocationTexts.storageTypeRack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentSection(BuildContext context, double width) {
    final strings = _strings;

    return SizedBox(
      width: width,
      child: _FormSection(
        title: strings.environmentTitle,
        child: RadioGroup<String>(
          groupValue: _storageEnvironment,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _isOutdoor = value == AddStorageLocationTexts.environmentOutdoor;
            });
            _updateGeneratedIdentifier();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DenseRadioTile(
                label: strings.environmentIndoor,
                value: AddStorageLocationTexts.environmentIndoor,
              ),
              _DenseRadioTile(
                label: strings.environmentOutdoor,
                value: AddStorageLocationTexts.environmentOutdoor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompartmentSection(BuildContext context, double width) {
    final strings = _strings;

    return SizedBox(
      width: width,
      child: _FormSection(
        title: strings.compartmentTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<String>(
              groupValue: _compartmentType,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _compartmentType = value;
                });
                _updateGeneratedIdentifier();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Floor has no compartments; racks support shelves only.
                  _DenseRadioTile(
                    label: strings.compartmentNone,
                    value: AddStorageLocationTexts.compartmentNone,
                  ),
                  if (_storageType !=
                          AddStorageLocationTexts.storageTypeFloor &&
                      _storageType != AddStorageLocationTexts.storageTypeRack)
                    _DenseRadioTile(
                      label: strings.compartmentDrawer,
                      value: AddStorageLocationTexts.compartmentDrawer,
                    ),
                  if (_storageType != AddStorageLocationTexts.storageTypeFloor)
                    _DenseRadioTile(
                      label: strings.compartmentShelf,
                      value: AddStorageLocationTexts.compartmentShelf,
                    ),
                  if (_storageType !=
                          AddStorageLocationTexts.storageTypeFloor &&
                      _storageType != AddStorageLocationTexts.storageTypeRack)
                    _DenseRadioTile(
                      label: strings.compartmentBoth,
                      value: AddStorageLocationTexts.compartmentBoth,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompartmentGroupSection(
    BuildContext context, {
    required double width,
    required String title,
    required List<Widget> children,
  }) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerFields() {
    final strings = _strings;

    return [
      _buildNumberField(_controllers.drawers, strings.numberOfDrawersLabel),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildNumberField(
              _controllers.drawerLength,
              strings.lengthLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.drawerWidth,
              strings.widthLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.drawerHeight,
              strings.heightLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.drawerMaxWeight,
              strings.maxWeightLabel,
              suffixText: _weightUnit,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildShelfFields() {
    final strings = _strings;

    return [
      _buildNumberField(_controllers.shelves, strings.numberOfShelvesLabel),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildNumberField(
              _controllers.shelfLength,
              strings.lengthLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.shelfWidth,
              strings.widthLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.shelfHeight,
              strings.heightLabel,
              suffixText: _dimensionUnit,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildNumberField(
              _controllers.shelfMaxWeight,
              strings.maxWeightLabel,
              suffixText: _weightUnit,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildCreateActions(BuildContext context) {
    final strings = _strings;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 160,
          child: _buildNumberField(
            _controllers.createMultiple,
            strings.createMultipleLabel,
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _isSaving ? null : _saveLocations,
          icon: Icon(_isSaving ? Icons.save : Icons.add),
          label: Text(
            _isSaving ? strings.savingButton : strings.createLocationsButton,
          ),
        ),
      ],
    );
  }

  Future<void> _saveLocations() async {
    final count = _normalizedCreateMultipleCount;
    final batchId = DateTime.now().toUtc().microsecondsSinceEpoch.toString();
    final storageBase = _storageType.toUpperCase().replaceAll(
      AddStorageLocationTexts.whitespace,
      AddStorageLocationTexts.separatorDash,
    );
    final quickNameStart = await StorageLocationRepository.instance
        .nextQuickNameSequenceForStorage(storageBase);
    final records = await _buildStorageLocationRecords(
      count,
      batchId,
      quickNameStart,
    );

    setState(() => _isSaving = true);

    try {
      await StorageLocationRepository.instance.insertAll(records);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.savedLocationsMessage(records.length))),
      );
      await _updateQuickNameAuto();
      widget.onLocationsChanged?.call();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_strings.saveLocationsFailedMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<List<StorageLocationRecord>> _buildStorageLocationRecords(
    int count,
    String batchId,
    int quickNameStart,
  ) async {
    final createdAt = DateTime.now().toUtc();
    final storageBase = _storageType.toUpperCase().replaceAll(
      AddStorageLocationTexts.whitespace,
      AddStorageLocationTexts.separatorDash,
    );
    final records = <StorageLocationRecord>[];

    for (var index = 0; index < count; index++) {
      final quickName = AddStorageLocationTexts.appendSequence(
        storageBase,
        quickNameStart + index,
      );
      final locationCodeBase = _generatedIdentifierBase(
        quickNameOverride: quickName,
      );
      final sequence = await StorageLocationRepository.instance
          .nextIdentifierSequence(locationCodeBase);

      records.add(
        StorageLocationRecord(
          locationCode: _locationCodeForIndex(locationCodeBase, sequence),
          batchId: batchId,
          batchIndex: index + 1,
          batchSize: count,
          useMetric: widget.useMetric,
          storageType: _storageType,
          storageEnvironment: _storageEnvironment,
          storageLayout: _storageLayout,
          compartmentType: _compartmentType,
          drawers: _savedDrawerCount,
          shelves: _savedShelfCount,
          drawerRows: _derivedDrawerRowCount,
          drawerColumns: _derivedDrawerColumnCount,
          shelfRows: _derivedShelfRowCount,
          shelfColumns: _derivedShelfColumnCount,
          minLength: _parseInteger(_controllers.length),
          maxLength: _parseInteger(_controllers.length),
          minWidth: _parseInteger(_controllers.width),
          maxWidth: _parseInteger(_controllers.width),
          minHeight: _parseInteger(_controllers.height),
          maxHeight: _parseInteger(_controllers.height),
          minWeight: _parseInteger(_controllers.weight),
          maxWeight: _parseInteger(_controllers.weight),
          drawerLength: _savedDrawerLength,
          drawerWidth: _savedDrawerWidth,
          drawerHeight: _savedDrawerHeight,
          drawerMaxWeight: _savedDrawerMaxWeight,
          shelfLength: _savedShelfLength,
          shelfWidth: _savedShelfWidth,
          shelfHeight: _savedShelfHeight,
          shelfMaxWeight: _savedShelfMaxWeight,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );
    }

    return records;
  }

  /// Encodes the current form state into a stable, normalized identifier.
  ///
  /// [quickNameOverride] lets batch creation generate one base per location
  /// without mutating the quick-name field shown in the form.
  String _generatedIdentifierBase({String? quickNameOverride}) {
    final quickNameValue =
        quickNameOverride ?? _controllers.locationCode.text.trim();
    return AddStorageLocationTexts.hyphenJoin([
      AddStorageLocationTexts.identifierPrefixQuickName,
      _normalizeIdentifierSegment(
        quickNameValue,
        fallback: AddStorageLocationTexts.identifierAutoFallback,
      ),
      AddStorageLocationTexts.identifierPrefixStorageType,
      _normalizeIdentifierSegment(_storageType),
      AddStorageLocationTexts.identifierPrefixEnvironment,
      _normalizeIdentifierSegment(_storageEnvironment),
      AddStorageLocationTexts.identifierPrefixGrouping,
      _normalizeIdentifierSegment(_storageLayout),
      AddStorageLocationTexts.identifierPrefixCompartment,
      _normalizeIdentifierSegment(_compartmentType),
      AddStorageLocationTexts.identifierPrefixDrawers,
      _normalizeIdentifierSegment(
        _savedDrawerCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixDrawerRows,
      _normalizeIdentifierSegment(
        _derivedDrawerRowCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixDrawerColumns,
      _normalizeIdentifierSegment(
        _derivedDrawerColumnCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixShelves,
      _normalizeIdentifierSegment(
        _savedShelfCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixShelfRows,
      _normalizeIdentifierSegment(
        _derivedShelfRowCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixShelfColumns,
      _normalizeIdentifierSegment(
        _derivedShelfColumnCount.toString(),
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixLength,
      _normalizeIdentifierSegment(
        _controllers.length.text,
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixWidth,
      _normalizeIdentifierSegment(
        _controllers.width.text,
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixHeight,
      _normalizeIdentifierSegment(
        _controllers.height.text,
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
      AddStorageLocationTexts.identifierPrefixWeight,
      _normalizeIdentifierSegment(
        _controllers.weight.text,
        fallback: AddStorageLocationTexts.identifierZeroFallback,
      ),
    ]);
  }

  String _locationCodeForIndex(String base, int sequence) {
    return AddStorageLocationTexts.appendSequence(base, sequence);
  }

  int get _normalizedCreateMultipleCount {
    final count = int.tryParse(_controllers.createMultiple.text) ?? 1;
    return count < 1 ? 1 : count;
  }

  int _parseInteger(TextEditingController controller) {
    return int.tryParse(controller.text) ?? 0;
  }

  int get _savedDrawerCount =>
      _hasDrawerCompartments ? _parseInteger(_controllers.drawers) : 0;

  int get _savedShelfCount =>
      _hasShelfCompartments ? _parseInteger(_controllers.shelves) : 0;

  int get _savedDrawerLength =>
      _hasDrawerCompartments ? _parseInteger(_controllers.drawerLength) : 0;

  int get _savedDrawerWidth =>
      _hasDrawerCompartments ? _parseInteger(_controllers.drawerWidth) : 0;

  int get _savedDrawerHeight =>
      _hasDrawerCompartments ? _parseInteger(_controllers.drawerHeight) : 0;

  int get _savedDrawerMaxWeight =>
      _hasDrawerCompartments ? _parseInteger(_controllers.drawerMaxWeight) : 0;

  int get _savedShelfLength =>
      _hasShelfCompartments ? _parseInteger(_controllers.shelfLength) : 0;

  int get _savedShelfWidth =>
      _hasShelfCompartments ? _parseInteger(_controllers.shelfWidth) : 0;

  int get _savedShelfHeight =>
      _hasShelfCompartments ? _parseInteger(_controllers.shelfHeight) : 0;

  int get _savedShelfMaxWeight =>
      _hasShelfCompartments ? _parseInteger(_controllers.shelfMaxWeight) : 0;

  int get _derivedDrawerRowCount => _hasDrawerCompartments ? 1 : 0;

  int get _derivedDrawerColumnCount => _hasDrawerCompartments ? 1 : 0;

  int get _derivedShelfRowCount => _hasShelfCompartments ? 1 : 0;

  int get _derivedShelfColumnCount => _hasShelfCompartments ? 1 : 0;

  bool get _hasDrawerCompartments =>
      (_compartmentType == AddStorageLocationTexts.compartmentDrawer ||
          _compartmentType == AddStorageLocationTexts.compartmentBoth) &&
      _parseInteger(_controllers.drawers) > 0;

  bool get _hasShelfCompartments =>
      (_compartmentType == AddStorageLocationTexts.compartmentShelf ||
          _compartmentType == AddStorageLocationTexts.compartmentBoth) &&
      _parseInteger(_controllers.shelves) > 0;

  String _normalizeIdentifierSegment(
    String value, {
    String fallback = AddStorageLocationTexts.identifierNotAvailableFallback,
  }) {
    final normalized = value
        .trim()
        .toUpperCase()
        .replaceAll(
          RegExp(AddStorageLocationTexts.identifierNonAlphaNumericPattern),
          AddStorageLocationTexts.separatorDash,
        )
        .replaceAll(
          RegExp(AddStorageLocationTexts.identifierRepeatedDashPattern),
          AddStorageLocationTexts.separatorDash,
        )
        .replaceAll(
          RegExp(AddStorageLocationTexts.identifierTrimEdgeDashPattern),
          '',
        );

    return normalized.isEmpty ? fallback : normalized;
  }

  void _attachIdentifierInputListeners() {
    for (final controller in _controllers.all) {
      controller.addListener(_handleIdentifierSourceChanged);
    }
  }

  void _detachIdentifierInputListeners() {
    for (final controller in _controllers.all) {
      controller.removeListener(_handleIdentifierSourceChanged);
    }
  }

  void _handleIdentifierSourceChanged() {
    _updateGeneratedIdentifier();
  }

  /// Refreshes the suggested quick name for the selected storage type.
  ///
  /// A request ID discards results from an older storage-type selection, then
  /// the generated full identifier is refreshed from the accepted quick name.
  Future<void> _updateQuickNameAuto() async {
    final requestId = ++_quickNameRefreshRequestId;
    final storageBase = _storageType.toUpperCase().replaceAll(
      AddStorageLocationTexts.whitespace,
      AddStorageLocationTexts.separatorDash,
    );
    final nextSequence = await StorageLocationRepository.instance
        .nextQuickNameSequenceForStorage(storageBase);

    if (!mounted || requestId != _quickNameRefreshRequestId) {
      return;
    }

    final nextQuickName = AddStorageLocationTexts.appendSequence(
      storageBase,
      nextSequence,
    );
    if (_controllers.locationCode.text != nextQuickName) {
      _controllers.locationCode.value = TextEditingValue(
        text: nextQuickName,
        selection: TextSelection.collapsed(offset: nextQuickName.length),
      );
    }

    await _updateGeneratedIdentifier();
  }

  /// Rebuilds the identifier and appends its next available database suffix.
  ///
  /// The request ID prevents rapid form edits from displaying an older async
  /// sequence lookup after a newer one has already started.
  Future<void> _updateGeneratedIdentifier() async {
    final requestId = ++_identifierRefreshRequestId;
    final base = _generatedIdentifierBase();
    final nextSequence = await StorageLocationRepository.instance
        .nextIdentifierSequence(base);

    if (!mounted || requestId != _identifierRefreshRequestId) {
      return;
    }

    final nextValue = _locationCodeForIndex(base, nextSequence);
    if (_generatedLocationCode == nextValue) {
      return;
    }

    setState(() {
      _generatedLocationCode = nextValue;
    });
  }

  Widget _buildNumberField(
    TextEditingController controller,
    String label, {
    String? suffixText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixText: suffixText,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _DenseRadioTile extends StatelessWidget {
  const _DenseRadioTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
