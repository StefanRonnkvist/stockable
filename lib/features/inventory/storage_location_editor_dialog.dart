import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../add_storage_location/add_storage_location_form_controllers.dart';
import '../add_storage_location/storage_location_record.dart';
import '../add_storage_location/storage_location_repository.dart';
import '../../texts/language/app_strings.dart';
import '../../texts/inventory_texts.dart';

Future<StorageLocationRecord?> showStorageLocationEditorDialog(
  BuildContext context, {
  required StorageLocationRecord record,
}) {
  return showDialog<StorageLocationRecord>(
    context: context,
    builder: (context) => _StorageLocationEditorDialog(record: record),
  );
}

class _StorageLocationEditorDialog extends StatefulWidget {
  const _StorageLocationEditorDialog({required this.record});

  final StorageLocationRecord record;

  @override
  State<_StorageLocationEditorDialog> createState() =>
      _StorageLocationEditorDialogState();
}

class _StorageLocationEditorDialogState
    extends State<_StorageLocationEditorDialog> {
  late final AddStorageLocationFormControllers _controllers;
  late bool _useMetric;
  late String _storageType;
  late String _storageEnvironment;
  late String _storageLayout;
  late String _compartmentType;
  String _locationCodeError = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = AddStorageLocationFormControllers.fromRecord(widget.record);
    _useMetric = widget.record.useMetric;
    _storageType = widget.record.storageType;
    _storageEnvironment = widget.record.storageEnvironment;
    _storageLayout = widget.record.storageLayout;
    _compartmentType = widget.record.compartmentType;
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final dimensionUnit = _useMetric
        ? InventoryTexts.unitCentimetre
        : InventoryTexts.unitInch;
    final weightUnit = _useMetric
        ? InventoryTexts.unitKilogram
        : InventoryTexts.unitPound;

    return AlertDialog(
      title: Text(strings.editStorageLocationTitle),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controllers.locationCode,
                onChanged: (_) {
                  if (_locationCodeError.isNotEmpty) {
                    setState(() => _locationCodeError = '');
                  }
                },
                decoration: InputDecoration(
                  labelText: strings.locationIdentifierLabel,
                  border: const OutlineInputBorder(),
                  errorText: _locationCodeError.isEmpty
                      ? null
                      : _locationCodeError,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _useMetric ? strings.metricLabel : strings.imperialLabel,
                ),
                subtitle: Text(
                  _useMetric ? strings.metricUnits : strings.imperialUnits,
                ),
                value: _useMetric,
                onChanged: (value) => setState(() => _useMetric = value),
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                _controllers.drawers,
                strings.numberOfDrawersLabel,
              ),
              const SizedBox(height: 12),
              _buildNumberField(
                _controllers.shelves,
                strings.numberOfShelvesLabel,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _controllers.drawerLength,
                      strings.drawerLengthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.drawerWidth,
                      strings.drawerWidthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.drawerHeight,
                      strings.drawerHeightLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.drawerMaxWeight,
                      strings.drawerMaxWeightLabel,
                      suffixText: weightUnit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _controllers.shelfLength,
                      strings.shelfLengthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.shelfWidth,
                      strings.shelfWidthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.shelfHeight,
                      strings.shelfHeightLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.shelfMaxWeight,
                      strings.shelfMaxWeightLabel,
                      suffixText: weightUnit,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _controllers.length,
                      strings.lengthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.width,
                      strings.widthLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.height,
                      strings.heightLabel,
                      suffixText: dimensionUnit,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _controllers.weight,
                      strings.weightLabel,
                      suffixText: weightUnit,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(strings.cancelButton),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _validateAndSave,
          child: Text(
            _isSaving ? strings.savingButton : strings.saveChangesButton,
          ),
        ),
      ],
    );
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

  Future<void> _validateAndSave() async {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final locationCode = _controllers.locationCode.text.trim();

    if (locationCode.isEmpty) {
      setState(() => _locationCodeError = strings.locationIdentifierEmptyError);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final isDuplicate = await StorageLocationRepository.instance
          .existsWithCode(locationCode, excludeId: widget.record.id);
      if (isDuplicate) {
        if (mounted) {
          setState(() {
            _locationCodeError = strings.locationIdentifierDuplicateError;
            _isSaving = false;
          });
        }
        return;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(_buildUpdatedRecord());
  }

  StorageLocationRecord _buildUpdatedRecord() {
    final now = DateTime.now().toUtc();
    return widget.record.copyWith(
      locationCode: _controllers.locationCode.text.trim(),
      useMetric: _useMetric,
      storageType: _storageType,
      storageEnvironment: _storageEnvironment,
      storageLayout: _storageLayout,
      compartmentType: _compartmentType,
      drawers: _parseInteger(_controllers.drawers),
      shelves: _parseInteger(_controllers.shelves),
      drawerRows: _updatedDrawerRowCount,
      drawerColumns: _updatedDrawerColumnCount,
      shelfRows: _updatedShelfRowCount,
      shelfColumns: _updatedShelfColumnCount,
      minLength: _parseInteger(_controllers.length),
      maxLength: _parseInteger(_controllers.length),
      minWidth: _parseInteger(_controllers.width),
      maxWidth: _parseInteger(_controllers.width),
      minHeight: _parseInteger(_controllers.height),
      maxHeight: _parseInteger(_controllers.height),
      minWeight: _parseInteger(_controllers.weight),
      maxWeight: _parseInteger(_controllers.weight),
      drawerLength: _parseInteger(_controllers.drawerLength),
      drawerWidth: _parseInteger(_controllers.drawerWidth),
      drawerHeight: _parseInteger(_controllers.drawerHeight),
      drawerMaxWeight: _parseInteger(_controllers.drawerMaxWeight),
      shelfLength: _parseInteger(_controllers.shelfLength),
      shelfWidth: _parseInteger(_controllers.shelfWidth),
      shelfHeight: _parseInteger(_controllers.shelfHeight),
      shelfMaxWeight: _parseInteger(_controllers.shelfMaxWeight),
      updatedAt: now,
    );
  }

  int _parseInteger(TextEditingController controller) {
    return int.tryParse(controller.text) ?? 0;
  }

  int get _updatedDrawerRowCount => _preservedOrDefaultGridValue(
    widget.record.drawerRows,
    _hasDrawerCompartments,
  );

  int get _updatedDrawerColumnCount => _preservedOrDefaultGridValue(
    widget.record.drawerColumns,
    _hasDrawerCompartments,
  );

  int get _updatedShelfRowCount => _preservedOrDefaultGridValue(
    widget.record.shelfRows,
    _hasShelfCompartments,
  );

  int get _updatedShelfColumnCount => _preservedOrDefaultGridValue(
    widget.record.shelfColumns,
    _hasShelfCompartments,
  );

  bool get _hasDrawerCompartments =>
      (_compartmentType == InventoryTexts.compartmentDrawer ||
          _compartmentType == InventoryTexts.compartmentBoth) &&
      _parseInteger(_controllers.drawers) > 0;

  bool get _hasShelfCompartments =>
      (_compartmentType == InventoryTexts.compartmentShelf ||
          _compartmentType == InventoryTexts.compartmentBoth) &&
      _parseInteger(_controllers.shelves) > 0;

  int _preservedOrDefaultGridValue(int existingValue, bool isEnabled) {
    if (!isEnabled) {
      return 0;
    }

    return existingValue > 0 ? existingValue : 1;
  }
}
