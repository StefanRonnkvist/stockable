import 'package:flutter/material.dart';

import '../add_storage_location/storage_location_record.dart';
import '../add_storage_location/storage_location_repository.dart';
import '../../texts/language/app_strings.dart';
import '../../texts/inventory_texts.dart';
import 'storage_location_editor_dialog.dart';

/// Displays stored locations and refreshes when another tab changes them.
class InventoryTab extends StatefulWidget {
  const InventoryTab({
    super.key,
    required this.refreshToken,
    required this.useMetric,
  });

  final int refreshToken;
  final bool useMetric;

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  late Future<List<StorageLocationRecord>> _locationsFuture;
  List<StorageLocationRecord> _locations = [];
  String? _selectedLocationCode;
  final _oemController = TextEditingController();
  final _localPartController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _moqController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _locationsFuture = _fetchLocations();
    _locationsFuture.then((list) {
      if (mounted) setState(() => _locations = list);
    });
  }

  @override
  void dispose() {
    _oemController.dispose();
    _localPartController.dispose();
    _descriptionController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _moqController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InventoryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent increments this token after create, delete, or bulk clear.
    if (oldWidget.refreshToken != widget.refreshToken) {
      _refreshLocations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Text(
                    strings.addSparePartTitle,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _oemController,
                        decoration: InputDecoration(
                          labelText: strings.oemPartNumberLabel,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _localPartController,
                        decoration: InputDecoration(
                          labelText: strings.localPartNumberLabel,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: strings.descriptionLabel,
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLocationCode,
                        decoration: InputDecoration(
                          labelText: strings.storageLocationLabel,
                          border: OutlineInputBorder(),
                        ),
                        items: _locations
                            .map(
                              (loc) => DropdownMenuItem(
                                value: loc.locationCode,
                                child: Text(loc.locationCode),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedLocationCode = value),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _moqController,
                        decoration: InputDecoration(
                          labelText: strings.minimumOrderQuantityLabel,
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      Builder(
                        builder: (context) {
                          final dimUnit = widget.useMetric
                              ? InventoryTexts.unitCentimetre
                              : InventoryTexts.unitInch;
                          final wgtUnit = widget.useMetric
                              ? InventoryTexts.unitKilogram
                              : InventoryTexts.unitPound;
                          return Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _lengthController,
                                  decoration: InputDecoration(
                                    labelText:
                                        '${strings.lengthLabel} ($dimUnit)',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _widthController,
                                  decoration: InputDecoration(
                                    labelText:
                                        '${strings.widthLabel} ($dimUnit)',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _heightController,
                                  decoration: InputDecoration(
                                    labelText:
                                        '${strings.heightLabel} ($dimUnit)',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _weightController,
                                  decoration: InputDecoration(
                                    labelText:
                                        '${strings.weightLabel} ($wgtUnit)',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<StorageLocationRecord>>(
            future: _locationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _InventoryMessageView(
                  message: strings.failedToLoadLocations,
                  actionLabel: strings.retryButton,
                  onAction: _refreshLocations,
                );
              }

              final locations =
                  snapshot.data ?? const <StorageLocationRecord>[];

              return RefreshIndicator(
                onRefresh: _refreshLocations,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: locations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final location = locations[index];
                    return _StorageLocationCard(
                      location: location,
                      onEdit: () => _editLocation(location),
                      onDelete: () => _deleteLocation(location),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<List<StorageLocationRecord>> _fetchLocations() {
    return StorageLocationRepository.instance.fetchAll();
  }

  /// Replaces the FutureBuilder input and synchronizes dropdown locations.
  Future<void> _refreshLocations() async {
    final future = _fetchLocations();
    if (mounted) {
      setState(() {
        _locationsFuture = future;
      });
    }
    final list = await future;
    if (mounted) setState(() => _locations = list);
  }

  Future<void> _editLocation(StorageLocationRecord location) async {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final updatedRecord = await showStorageLocationEditorDialog(
      context,
      record: location,
    );
    if (updatedRecord == null) {
      return;
    }

    try {
      await StorageLocationRepository.instance.update(updatedRecord);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.updatedLocationMessage(updatedRecord.locationCode),
          ),
        ),
      );
      await _refreshLocations();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.failedToUpdateLocationMessage(error))),
      );
    }
  }

  Future<void> _deleteLocation(StorageLocationRecord location) async {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));

    final locationId = location.id;
    if (locationId == null) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(strings.deleteStorageLocationTitle),
          content: Text(strings.deleteLocationPrompt(location.locationCode)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(strings.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(strings.deleteButton),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await StorageLocationRepository.instance.delete(locationId);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.deletedLocationMessage(location.locationCode)),
        ),
      );
      await _refreshLocations();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.failedToDeleteLocationMessage(error))),
      );
    }
  }
}

class _StorageLocationCard extends StatelessWidget {
  const _StorageLocationCard({
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  final StorageLocationRecord location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final unitLabel = location.useMetric
        ? strings.metricLabel
        : strings.imperialLabel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.locationCode,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        InventoryTexts.storageMetaLine(
                          location.storageType,
                          location.storageEnvironment,
                          location.storageLayout,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: strings.editTooltip,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: strings.deleteTooltip,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LocationChip(
                  label: strings.compartmentLabel,
                  value: location.compartmentType,
                ),
                _LocationChip(label: strings.unitsLabel, value: unitLabel),
                _LocationChip(
                  label: strings.batchLabel,
                  value: InventoryTexts.batchValue(
                    location.batchIndex,
                    location.batchSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${strings.dimensionsPrefix}: '
              '${location.minLength}-${location.maxLength} × '
              '${location.minWidth}-${location.maxWidth} × '
              '${location.minHeight}-${location.maxHeight}',
            ),
            const SizedBox(height: 4),
            Text(
              '${strings.weightPrefix}: ${location.minWeight}-${location.maxWeight} '
              '· ${strings.drawersTitle} ${location.drawers} '
              '· ${strings.shelvesTitle} ${location.shelves}',
            ),
            const SizedBox(height: 4),
            Text(
              '${strings.updatedPrefix} ${InventoryTexts.formatTimestamp(location.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}

class _InventoryMessageView extends StatelessWidget {
  const _InventoryMessageView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
