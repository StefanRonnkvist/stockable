import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../add_storage_location/storage_location_record.dart';
import '../add_storage_location/storage_location_repository.dart';
import '../../texts/language/app_strings.dart';
import '../../texts/location_assignment_texts.dart';
import 'slot_content_repository.dart';
import 'slot_merge_repository.dart';

class LocationAssignmentTab extends StatefulWidget {
  const LocationAssignmentTab({super.key});

  @override
  State<LocationAssignmentTab> createState() => _LocationAssignmentTabState();
}

class _LocationAssignmentTabState extends State<LocationAssignmentTab> {
  late Future<List<StorageLocationRecord>> _locationsFuture;
  final ScrollController _selectorHorizontalScrollController =
      ScrollController();
  final ScrollController _listHorizontalScrollController = ScrollController();
  String? _selectedLocationCode;
  // At most two targets are retained because merge actions operate on pairs.
  final List<_SelectedSlotTarget> _selectedSlotTargets = [];
  // Keys identify containers; each value holds canonical "first|second" pairs.
  final Map<String, Set<String>> _mergedSlotPairsByContainer = {};
  String? _loadedMergeLocationCode;

  AppStrings get _strings =>
      AppStrings.forLocale(Localizations.maybeLocaleOf(context));

  @override
  void initState() {
    super.initState();
    _locationsFuture = StorageLocationRepository.instance.fetchAll();
  }

  @override
  void dispose() {
    _selectorHorizontalScrollController.dispose();
    _listHorizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshLocations() async {
    final future = StorageLocationRepository.instance.fetchAll();
    if (mounted) {
      setState(() {
        _locationsFuture = future;
      });
    }
    await future;
  }

  String _dimensionUnitFor(StorageLocationRecord location) {
    return LocationAssignmentTexts.dimensionUnit(location.useMetric);
  }

  String _weightUnitFor(StorageLocationRecord location) {
    return LocationAssignmentTexts.weightUnit(location.useMetric);
  }

  @override
  Widget build(BuildContext context) {
    final strings = _strings;

    return FutureBuilder<List<StorageLocationRecord>>(
      future: _locationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(strings.failedToLoadLocations),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _refreshLocations,
                    child: Text(strings.retryButton),
                  ),
                ],
              ),
            ),
          );
        }

        final locations = snapshot.data ?? const <StorageLocationRecord>[];
        final locationCodes = locations
            .map((location) => location.locationCode)
            .toList(growable: false);
        final selectedLocation = locations.where((location) {
          return location.locationCode == _selectedLocationCode;
        }).firstOrNull;
        final decodedSelectedLocation = selectedLocation == null
            ? null
            : _decodeLocationCode(selectedLocation.locationCode);

        if (locationCodes.isNotEmpty &&
            (_selectedLocationCode == null ||
                !locationCodes.contains(_selectedLocationCode))) {
          _selectedLocationCode = locationCodes.first;
          _selectedSlotTargets.clear();
          _mergedSlotPairsByContainer.clear();
          _loadedMergeLocationCode = null;
        }

        if (_selectedLocationCode != null) {
          _ensureMergedPairsLoaded(_selectedLocationCode!);
        }

        return RefreshIndicator(
          onRefresh: _refreshLocations,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.locationSelectorTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (locationCodes.isEmpty)
                        Text(strings.noLocationsFound)
                      else
                        _buildHorizontalScrollArea(
                          controller: _selectorHorizontalScrollController,
                          minWidth: 680,
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedLocationCode,
                            decoration: InputDecoration(
                              labelText: strings.allStorageLocationsLabel,
                              border: OutlineInputBorder(),
                            ),
                            items: locationCodes
                                .map(
                                  (code) => DropdownMenuItem<String>(
                                    value: code,
                                    child: Text(
                                      _dropdownDisplayLabelForLocationCode(
                                        code,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLocationCode = value;
                                _selectedSlotTargets.clear();
                                _mergedSlotPairsByContainer.clear();
                                _loadedMergeLocationCode = null;
                              });
                              if (value != null) {
                                _ensureMergedPairsLoaded(value);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.storageDetailTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (selectedLocation == null)
                        Text(strings.selectLocationForDetails)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.quickNameLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .quickNameKey] ??
                                        selectedLocation.locationCode)
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.storageLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .storageTypeKey] ??
                                        selectedLocation.storageType)
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.environmentLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .environmentKey] ??
                                        selectedLocation.storageEnvironment)
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.groupingLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .groupingKey] ??
                                        selectedLocation.storageLayout)
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.compartmentLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .compartmentKey] ??
                                        selectedLocation.compartmentType)
                                    .toString(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.drawersShelvesLabel,
                                LocationAssignmentTexts.drawersShelvesValue(
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .drawersKey] ??
                                      selectedLocation.drawers,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .shelvesKey] ??
                                      selectedLocation.shelves,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.dimensionsLabel,
                                LocationAssignmentTexts.dimensionsValue(
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .minLengthKey] ??
                                      selectedLocation.minLength,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .maxLengthKey] ??
                                      selectedLocation.maxLength,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .minWidthKey] ??
                                      selectedLocation.minWidth,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .maxWidthKey] ??
                                      selectedLocation.maxWidth,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .minHeightKey] ??
                                      selectedLocation.minHeight,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .maxHeightKey] ??
                                      selectedLocation.maxHeight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.weightLabel,
                                LocationAssignmentTexts.weightValue(
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .minWeightKey] ??
                                      selectedLocation.minWeight,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .maxWeightKey] ??
                                      selectedLocation.maxWeight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.drawerRowsColumnsLabel,
                                LocationAssignmentTexts.rowsColumnsValue(
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .drawerRowsKey] ??
                                      selectedLocation.drawerRows,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .drawerColumnsKey] ??
                                      selectedLocation.drawerColumns,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.drawerDimensionsLabel,
                                LocationAssignmentTexts.dimensionsWithUnitValue(
                                  selectedLocation.drawerLength,
                                  selectedLocation.drawerWidth,
                                  selectedLocation.drawerHeight,
                                  _dimensionUnitFor(selectedLocation),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.drawerMaxWeightLabel,
                                LocationAssignmentTexts.weightWithUnitValue(
                                  selectedLocation.drawerMaxWeight,
                                  _weightUnitFor(selectedLocation),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.shelfRowsColumnsLabel,
                                LocationAssignmentTexts.rowsColumnsValue(
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .shelfRowsKey] ??
                                      selectedLocation.shelfRows,
                                  decodedSelectedLocation?[LocationAssignmentTexts
                                          .shelfColumnsKey] ??
                                      selectedLocation.shelfColumns,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.shelfDimensionsLabel,
                                LocationAssignmentTexts.dimensionsWithUnitValue(
                                  selectedLocation.shelfLength,
                                  selectedLocation.shelfWidth,
                                  selectedLocation.shelfHeight,
                                  _dimensionUnitFor(selectedLocation),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.shelfMaxWeightLabel,
                                LocationAssignmentTexts.weightWithUnitValue(
                                  selectedLocation.shelfMaxWeight,
                                  _weightUnitFor(selectedLocation),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              LocationAssignmentTexts.detailLine(
                                strings.incrementLabel,
                                (decodedSelectedLocation?[LocationAssignmentTexts
                                            .incrementKey] ??
                                        selectedLocation.batchIndex)
                                    .toString(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.storagePictureTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.mergeInstructions,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: selectedLocation == null
                                ? null
                                : () async {
                                    await _mergeSelectedSlots(
                                      locationCode:
                                          selectedLocation.locationCode,
                                    );
                                  },
                            child: Text(strings.mergeButton),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: selectedLocation == null
                                ? null
                                : () async {
                                    await _unmergeSelectedSlots(
                                      locationCode:
                                          selectedLocation.locationCode,
                                    );
                                  },
                            child: Text(strings.unmergeButton),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (selectedLocation == null)
                        Text(strings.selectLocationToDraw)
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final drawerCount = _drawerCountFrom(
                              decodedSelectedLocation?[LocationAssignmentTexts
                                  .drawersKey],
                              selectedLocation.drawers,
                            );
                            final shelfCount = _drawerCountFrom(
                              decodedSelectedLocation?[LocationAssignmentTexts
                                  .shelvesKey],
                              selectedLocation.shelves,
                            );
                            final drawerRows = _gridDimensionFrom(
                              decodedSelectedLocation?[LocationAssignmentTexts
                                  .drawerRowsKey],
                              selectedLocation.drawerRows,
                            );
                            final drawerColumns = _gridDimensionFrom(
                              decodedSelectedLocation?[LocationAssignmentTexts
                                  .drawerColumnsKey],
                              selectedLocation.drawerColumns,
                            );
                            final shelfColumns = _gridDimensionFrom(
                              decodedSelectedLocation?[LocationAssignmentTexts
                                  .shelfColumnsKey],
                              selectedLocation.shelfColumns,
                            );
                            final shelfLocationCount = shelfColumns;

                            if (drawerCount <= 0 && shelfCount <= 0) {
                              return Text(strings.noDrawersOrShelvesConfigured);
                            }

                            final availableWidth = constraints.maxWidth;
                            final targetTileWidth = 180.0;
                            final calculatedColumns =
                                (availableWidth / targetTileWidth).floor();
                            final columns = calculatedColumns > 0
                                ? calculatedColumns
                                : 1;
                            final spacing = 12.0;
                            final shelfGap = 5.0;
                            final shelfRowHeight = 36.0;
                            final tileWidth =
                                (availableWidth - ((columns - 1) * spacing)) /
                                columns;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (drawerCount > 0) ...[
                                  Text(
                                    strings.drawersTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children: List.generate(drawerCount, (
                                      index,
                                    ) {
                                      return SizedBox(
                                        width: tileWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              LocationAssignmentTexts.drawerTitle(
                                                index + 1,
                                              ),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
                                            ),
                                            const SizedBox(height: 6),
                                            AspectRatio(
                                              aspectRatio: 1,
                                              child: LayoutBuilder(
                                                builder: (context, drawerConstraints) {
                                                  final drawerPainter = _VariableGridPainter(
                                                    rows: drawerRows,
                                                    columns: drawerColumns,
                                                    colorScheme: Theme.of(
                                                      context,
                                                    ).colorScheme,
                                                    selectedLabels:
                                                        _selectedLabelsForContainer(
                                                          _containerKeyFor(
                                                            selectedLocation
                                                                .locationCode,
                                                            LocationAssignmentTexts
                                                                .slotTypeDrawer,
                                                            LocationAssignmentTexts.drawerTitle(
                                                              index + 1,
                                                            ),
                                                          ),
                                                        ),
                                                    mergedPairs:
                                                        _mergedPairsForContainer(
                                                          _containerKeyFor(
                                                            selectedLocation
                                                                .locationCode,
                                                            LocationAssignmentTexts
                                                                .slotTypeDrawer,
                                                            LocationAssignmentTexts.drawerTitle(
                                                              index + 1,
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                  final drawerSize = Size(
                                                    drawerConstraints.maxWidth,
                                                    drawerConstraints.maxHeight,
                                                  );

                                                  return GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTapUp: (details) {
                                                      final cellLabel = drawerPainter
                                                          .cellLabelAtPosition(
                                                            details
                                                                .localPosition,
                                                            drawerSize,
                                                          );
                                                      if (cellLabel == null) {
                                                        return;
                                                      }
                                                      _toggleSlotSelection(
                                                        _SelectedSlotTarget(
                                                          locationCode:
                                                              selectedLocation
                                                                  .locationCode,
                                                          slotType:
                                                              LocationAssignmentTexts
                                                                  .slotTypeDrawer,
                                                          containerLabel:
                                                              LocationAssignmentTexts.drawerTitle(
                                                                index + 1,
                                                              ),
                                                          slotLabel: cellLabel,
                                                        ),
                                                      );
                                                    },
                                                    onLongPressStart: (details) {
                                                      final cellLabel = drawerPainter
                                                          .cellLabelAtPosition(
                                                            details
                                                                .localPosition,
                                                            drawerSize,
                                                          );
                                                      if (cellLabel == null) {
                                                        return;
                                                      }
                                                      _showStorageSlotPopup(
                                                        selectedLocation:
                                                            selectedLocation,
                                                        slotType:
                                                            LocationAssignmentTexts
                                                                .slotTypeDrawer,
                                                        slotContainerLabel:
                                                            LocationAssignmentTexts.drawerTitle(
                                                              index + 1,
                                                            ),
                                                        slotLabel: cellLabel,
                                                      );
                                                    },
                                                    child: CustomPaint(
                                                      painter: drawerPainter,
                                                      child:
                                                          const SizedBox.expand(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                                if (drawerCount > 0 && shelfCount > 0)
                                  const SizedBox(height: 10),
                                if (shelfCount > 0) ...[
                                  Text(
                                    strings.shelvesTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Column(
                                    children: List.generate(shelfCount, (
                                      index,
                                    ) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index == shelfCount - 1
                                              ? 0
                                              : shelfGap,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              LocationAssignmentTexts.shelfTitle(
                                                index + 1,
                                              ),
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelMedium,
                                            ),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: SizedBox(
                                                height: shelfRowHeight,
                                                child: LayoutBuilder(
                                                  builder: (context, shelfConstraints) {
                                                    final shelfPainter = _HorizontalShelfPainter(
                                                      slotCount:
                                                          shelfLocationCount,
                                                      colorScheme: Theme.of(
                                                        context,
                                                      ).colorScheme,
                                                      selectedLabels:
                                                          _selectedLabelsForContainer(
                                                            _containerKeyFor(
                                                              selectedLocation
                                                                  .locationCode,
                                                              LocationAssignmentTexts
                                                                  .slotTypeShelf,
                                                              LocationAssignmentTexts.shelfTitle(
                                                                index + 1,
                                                              ),
                                                            ),
                                                          ),
                                                      mergedPairs: _mergedPairsForContainer(
                                                        _containerKeyFor(
                                                          selectedLocation
                                                              .locationCode,
                                                          LocationAssignmentTexts
                                                              .slotTypeShelf,
                                                          LocationAssignmentTexts.shelfTitle(
                                                            index + 1,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    final shelfSize = Size(
                                                      shelfConstraints.maxWidth,
                                                      shelfConstraints
                                                          .maxHeight,
                                                    );

                                                    return GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTapUp: (details) {
                                                        final tappedSlot = shelfPainter
                                                            .slotIndexAtPosition(
                                                              details
                                                                  .localPosition,
                                                              shelfSize,
                                                            );
                                                        if (tappedSlot ==
                                                            null) {
                                                          return;
                                                        }
                                                        _toggleSlotSelection(
                                                          _SelectedSlotTarget(
                                                            locationCode:
                                                                selectedLocation
                                                                    .locationCode,
                                                            slotType:
                                                                LocationAssignmentTexts
                                                                    .slotTypeShelf,
                                                            containerLabel:
                                                                LocationAssignmentTexts.shelfTitle(
                                                                  index + 1,
                                                                ),
                                                            slotLabel:
                                                                LocationAssignmentTexts.slotLabelFromIndex(
                                                                  tappedSlot,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                      onLongPressStart: (details) {
                                                        final tappedSlot = shelfPainter
                                                            .slotIndexAtPosition(
                                                              details
                                                                  .localPosition,
                                                              shelfSize,
                                                            );
                                                        if (tappedSlot ==
                                                            null) {
                                                          return;
                                                        }
                                                        _showStorageSlotPopup(
                                                          selectedLocation:
                                                              selectedLocation,
                                                          slotType:
                                                              LocationAssignmentTexts
                                                                  .slotTypeShelf,
                                                          slotContainerLabel:
                                                              LocationAssignmentTexts.shelfTitle(
                                                                index + 1,
                                                              ),
                                                          slotLabel:
                                                              LocationAssignmentTexts.slotLabelFromIndex(
                                                                tappedSlot,
                                                              ),
                                                        );
                                                      },
                                                      child: CustomPaint(
                                                        painter: shelfPainter,
                                                        child:
                                                            const SizedBox.expand(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHorizontalScrollArea({
    required ScrollController controller,
    required Widget child,
    required double minWidth,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth < minWidth
            ? minWidth
            : constraints.maxWidth;

        return Scrollbar(
          controller: controller,
          thumbVisibility: true,
          trackVisibility: true,
          notificationPredicate: (notification) {
            return notification.metrics.axis == Axis.horizontal;
          },
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: contentWidth, child: child),
          ),
        );
      },
    );
  }

  String _dropdownDisplayLabelForLocationCode(String locationCode) {
    final decoded = _decodeLocationCode(locationCode);
    final quickName = decoded[LocationAssignmentTexts.quickNameKey];
    if (quickName == null || quickName.isEmpty) {
      return locationCode;
    }
    return quickName;
  }

  Map<String, String> _decodeLocationCode(String locationCode) {
    // Values may contain dashes, so known marker tokens delimit each segment.
    final decoded = <String, String>{};
    final incrementMatch = RegExp(
      LocationAssignmentTexts.incrementSuffixRegex,
    ).firstMatch(locationCode);
    final basePart = incrementMatch?.group(1) ?? locationCode;
    final increment = incrementMatch?.group(2);
    if (increment != null) {
      decoded[LocationAssignmentTexts.incrementKey] = increment;
    }

    final tokens = basePart.split(LocationAssignmentTexts.separatorDash);
    var index = 0;
    while (index < tokens.length) {
      final token = tokens[index];
      if (!LocationAssignmentTexts.identifierKnownKeys.contains(token)) {
        index++;
        continue;
      }

      final key = token;
      final valueTokens = <String>[];
      index++;

      while (index < tokens.length &&
          !LocationAssignmentTexts.identifierKnownKeys.contains(
            tokens[index],
          )) {
        valueTokens.add(tokens[index]);
        index++;
      }

      if (valueTokens.isNotEmpty) {
        decoded[key] = valueTokens.join(LocationAssignmentTexts.separatorDash);
      }
    }

    return decoded;
  }

  int _gridDimensionFrom(String? decodedValue, int fallback) {
    final parsed = int.tryParse(decodedValue ?? '');
    final resolved = parsed ?? fallback;
    return resolved > 0 ? resolved : 1;
  }

  int _drawerCountFrom(String? decodedValue, int fallback) {
    final parsed = int.tryParse(decodedValue ?? '');
    final resolved = parsed ?? fallback;
    return resolved > 0 ? resolved : 0;
  }

  String _containerKeyFor(
    String locationCode,
    String slotType,
    String containerLabel,
  ) {
    return LocationAssignmentTexts.containerKey(
      locationCode,
      slotType,
      containerLabel,
    );
  }

  Set<String> _selectedLabelsForContainer(String containerKey) {
    return _selectedSlotTargets
        .where((target) => target.containerKey == containerKey)
        .map((target) => target.slotLabel)
        .toSet();
  }

  Set<String> _mergedPairsForContainer(String containerKey) {
    return _mergedSlotPairsByContainer[containerKey] ?? const <String>{};
  }

  void _toggleSlotSelection(_SelectedSlotTarget target) {
    setState(() {
      final existingIndex = _selectedSlotTargets.indexWhere((selected) {
        return selected.sameAs(target);
      });
      if (existingIndex >= 0) {
        _selectedSlotTargets.removeAt(existingIndex);
        return;
      }

      if (_selectedSlotTargets.length == 2) {
        _selectedSlotTargets.removeAt(0);
      }
      _selectedSlotTargets.add(target);
    });
  }

  /// Starts one merge lookup per selected location until the cache is reset.
  void _ensureMergedPairsLoaded(String locationCode) {
    if (_loadedMergeLocationCode == locationCode) {
      return;
    }
    _loadedMergeLocationCode = locationCode;
    _loadMergedPairsForLocation(locationCode);
  }

  /// Loads merge pairs and discards the result if selection changed meanwhile.
  Future<void> _loadMergedPairsForLocation(String locationCode) async {
    final mergedByContainer = await SlotMergeRepository.instance
        .fetchMergedPairsForLocation(locationCode);
    if (!mounted || _selectedLocationCode != locationCode) {
      return;
    }

    setState(() {
      _mergedSlotPairsByContainer
        ..clear()
        ..addAll(mergedByContainer);
    });
  }

  /// Validates and persists a merge between two adjacent slots in one container.
  Future<void> _mergeSelectedSlots({required String locationCode}) async {
    final strings = _strings;

    if (_selectedSlotTargets.length != 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.mergeNeedTwoAdjacent)));
      return;
    }

    final first = _selectedSlotTargets[0];
    final second = _selectedSlotTargets[1];
    if (first.locationCode != locationCode ||
        second.locationCode != locationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.selectSlotsCurrentLocation)),
      );
      return;
    }
    if (first.containerKey != second.containerKey) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.selectSameContainer)));
      return;
    }
    if (!_areAdjacent(first, second)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.selectedMustBeAdjacent)));
      return;
    }

    final pairKey = _mergePairKey(
      slotType: first.slotType,
      firstLabel: first.slotLabel,
      secondLabel: second.slotLabel,
    );

    final parts = pairKey.split('|');
    if (parts.length != 2) {
      return;
    }

    await SlotMergeRepository.instance.upsertMerge(
      locationCode: first.locationCode,
      slotType: first.slotType,
      containerLabel: first.containerLabel,
      firstSlotLabel: parts[0],
      secondSlotLabel: parts[1],
    );

    if (!mounted) {
      return;
    }

    setState(() {
      final pairs = _mergedSlotPairsByContainer.putIfAbsent(
        first.containerKey,
        () => {},
      );
      pairs.add(pairKey);
      _selectedSlotTargets.clear();
    });
  }

  /// Removes a persisted merge after applying the same pair validation rules.
  Future<void> _unmergeSelectedSlots({required String locationCode}) async {
    final strings = _strings;

    if (_selectedSlotTargets.length != 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.unmergeNeedTwoMerged)));
      return;
    }

    final first = _selectedSlotTargets[0];
    final second = _selectedSlotTargets[1];
    if (first.locationCode != locationCode ||
        second.locationCode != locationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.selectSlotsCurrentLocation)),
      );
      return;
    }
    if (first.containerKey != second.containerKey) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.selectSameContainer)));
      return;
    }
    if (!_areAdjacent(first, second)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.selectedMustBeAdjacent)));
      return;
    }

    final pairKey = _mergePairKey(
      slotType: first.slotType,
      firstLabel: first.slotLabel,
      secondLabel: second.slotLabel,
    );

    final existingPairs = _mergedSlotPairsByContainer[first.containerKey];
    if (existingPairs == null || !existingPairs.contains(pairKey)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.locationsNotMerged)));
      return;
    }

    final parts = pairKey.split('|');
    if (parts.length != 2) {
      return;
    }

    await SlotMergeRepository.instance.deleteMerge(
      locationCode: first.locationCode,
      slotType: first.slotType,
      containerLabel: first.containerLabel,
      firstSlotLabel: parts[0],
      secondSlotLabel: parts[1],
    );

    if (!mounted) {
      return;
    }

    setState(() {
      existingPairs.remove(pairKey);
      if (existingPairs.isEmpty) {
        _mergedSlotPairsByContainer.remove(first.containerKey);
      }
      _selectedSlotTargets.clear();
    });
  }

  String _mergePairKey({
    required String slotType,
    required String firstLabel,
    required String secondLabel,
  }) {
    // Canonical ordering makes selection order irrelevant to lookup and delete.
    final ordered = [firstLabel, secondLabel]
      ..sort((a, b) => _compareSlotLabel(slotType, a, b));
    return LocationAssignmentTexts.joinWithPipe(ordered[0], ordered[1]);
  }

  int _compareSlotLabel(String slotType, String left, String right) {
    if (slotType == LocationAssignmentTexts.slotTypeShelf) {
      final leftValue = int.tryParse(left) ?? 0;
      final rightValue = int.tryParse(right) ?? 0;
      return leftValue.compareTo(rightValue);
    }

    final leftCell = _DrawerCell.fromLabel(left);
    final rightCell = _DrawerCell.fromLabel(right);
    if (leftCell == null || rightCell == null) {
      return left.compareTo(right);
    }

    final byColumn = leftCell.column.compareTo(rightCell.column);
    if (byColumn != 0) {
      return byColumn;
    }
    return leftCell.row.compareTo(rightCell.row);
  }

  bool _areAdjacent(_SelectedSlotTarget first, _SelectedSlotTarget second) {
    if (first.slotType != second.slotType) {
      return false;
    }

    if (first.slotType == LocationAssignmentTexts.slotTypeShelf) {
      final firstValue = int.tryParse(first.slotLabel);
      final secondValue = int.tryParse(second.slotLabel);
      if (firstValue == null || secondValue == null) {
        return false;
      }
      return (firstValue - secondValue).abs() == 1;
    }

    final firstCell = _DrawerCell.fromLabel(first.slotLabel);
    final secondCell = _DrawerCell.fromLabel(second.slotLabel);
    if (firstCell == null || secondCell == null) {
      return false;
    }

    final rowDistance = (firstCell.row - secondCell.row).abs();
    final columnDistance = (firstCell.column - secondCell.column).abs();
    return rowDistance + columnDistance == 1;
  }

  Future<void> _showStorageSlotPopup({
    required StorageLocationRecord selectedLocation,
    required String slotType,
    required String slotContainerLabel,
    required String slotLabel,
  }) async {
    final strings = _strings;

    final existingContents = await SlotContentRepository.instance.readContent(
      locationCode: selectedLocation.locationCode,
      slotType: slotType,
      containerLabel: slotContainerLabel,
      slotLabel: slotLabel,
    );
    if (!mounted) {
      return;
    }

    final controller = TextEditingController(text: existingContents ?? '');
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(LocationAssignmentTexts.slotDialogTitle(slotType)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocationAssignmentTexts.detailLine(
                  LocationAssignmentTexts.slotDialogStorageLabel,
                  selectedLocation.locationCode,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LocationAssignmentTexts.detailLine(
                  LocationAssignmentTexts.slotDialogContainerLabel,
                  slotContainerLabel,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LocationAssignmentTexts.detailLine(
                  LocationAssignmentTexts.slotDialogLocationLabel,
                  slotLabel,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: strings.slotDialogContentsLabel,
                  hintText: strings.slotDialogContentsHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(strings.closeButton),
            ),
            FilledButton(
              onPressed: () async {
                await SlotContentRepository.instance.upsertContent(
                  locationCode: selectedLocation.locationCode,
                  slotType: slotType,
                  containerLabel: slotContainerLabel,
                  slotLabel: slotLabel,
                  contents: controller.text,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(strings.saveButton),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }
}

class _VariableGridPainter extends CustomPainter {
  const _VariableGridPainter({
    required this.rows,
    required this.columns,
    required this.colorScheme,
    required this.selectedLabels,
    required this.mergedPairs,
  });

  final int rows;
  final int columns;
  final ColorScheme colorScheme;
  final Set<String> selectedLabels;
  final Set<String> mergedPairs;

  String? cellLabelAtPosition(Offset position, Size size) {
    final safeRows = rows > 0 ? rows : 1;
    final safeColumns = columns > 0 ? columns : 1;
    final squareSide = size.width < size.height ? size.width : size.height;
    final offsetX = (size.width - squareSide) / 2;
    final offsetY = (size.height - squareSide) / 2;
    final cellSize =
        squareSide / (safeColumns > safeRows ? safeColumns : safeRows);

    final localX = position.dx - offsetX;
    final localY = position.dy - offsetY;
    final occupiedWidth = safeColumns * cellSize;
    final occupiedHeight = safeRows * cellSize;

    if (localX < 0 ||
        localY < 0 ||
        localX >= occupiedWidth ||
        localY >= occupiedHeight) {
      return null;
    }

    final column = (localX / cellSize).floor();
    final row = (localY / cellSize).floor();
    final label = _columnLabelFor(column);
    return LocationAssignmentTexts.drawerCellLabel(label, row + 1);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final safeRows = rows > 0 ? rows : 1;
    final safeColumns = columns > 0 ? columns : 1;
    final borderPaint = Paint()
      ..color = colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final textStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final selectedPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final gridWidth = size.width;
    final gridHeight = size.height;
    final squareSide = gridWidth < gridHeight ? gridWidth : gridHeight;
    final offsetX = (gridWidth - squareSide) / 2;
    final offsetY = (gridHeight - squareSide) / 2;
    final cellSize =
        squareSide / (safeColumns > safeRows ? safeColumns : safeRows);
    final cellTextStyle = textStyle.copyWith(
      fontSize: cellSize < 24 ? 10 : 12,
      color: colorScheme.outline,
    );
    final hiddenLabels = _hiddenLabelsFromMergePairs();

    for (var row = 0; row < safeRows; row++) {
      for (var column = 0; column < safeColumns; column++) {
        final label = _columnLabelFor(column);
        final cellLabel = LocationAssignmentTexts.drawerCellLabel(
          label,
          row + 1,
        );
        final cellRect = Rect.fromLTWH(
          offsetX + (column * cellSize),
          offsetY + (row * cellSize),
          cellSize,
          cellSize,
        );
        if (selectedLabels.contains(cellLabel)) {
          canvas.drawRect(cellRect, selectedPaint);
        }

        if (row == 0 ||
            !_isMerged(
              cellLabel,
              LocationAssignmentTexts.drawerCellLabel(label, row),
            )) {
          canvas.drawLine(cellRect.topLeft, cellRect.topRight, borderPaint);
        }
        if (column == 0 ||
            !_isMerged(
              cellLabel,
              LocationAssignmentTexts.drawerCellLabel(
                _columnLabelFor(column - 1),
                row + 1,
              ),
            )) {
          canvas.drawLine(cellRect.topLeft, cellRect.bottomLeft, borderPaint);
        }

        if (row == safeRows - 1 ||
            !_isMerged(
              cellLabel,
              LocationAssignmentTexts.drawerCellLabel(label, row + 2),
            )) {
          canvas.drawLine(
            cellRect.bottomLeft,
            cellRect.bottomRight,
            borderPaint,
          );
        }

        if (column == safeColumns - 1 ||
            !_isMerged(
              cellLabel,
              LocationAssignmentTexts.drawerCellLabel(
                _columnLabelFor(column + 1),
                row + 1,
              ),
            )) {
          canvas.drawLine(cellRect.topRight, cellRect.bottomRight, borderPaint);
        }

        if (!hiddenLabels.contains(cellLabel)) {
          _paintCenteredText(
            canvas,
            text: cellLabel,
            center: cellRect.center,
            style: cellTextStyle,
          );
        }
      }
    }
  }

  Set<String> _hiddenLabelsFromMergePairs() {
    final hidden = <String>{};
    for (final pair in mergedPairs) {
      final parts = pair.split('|');
      if (parts.length == 2) {
        hidden.add(parts[1]);
      }
    }
    return hidden;
  }

  bool _isMerged(String first, String second) {
    return mergedPairs.contains(
          LocationAssignmentTexts.joinWithPipe(first, second),
        ) ||
        mergedPairs.contains(
          LocationAssignmentTexts.joinWithPipe(second, first),
        );
  }

  String _columnLabelFor(int index) {
    var value = index;
    var label = '';
    do {
      label = String.fromCharCode(65 + (value % 26)) + label;
      value = (value ~/ 26) - 1;
    } while (value >= 0);
    return label;
  }

  void _paintCenteredText(
    Canvas canvas, {
    required String text,
    required Offset center,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _VariableGridPainter oldDelegate) {
    return rows != oldDelegate.rows ||
        columns != oldDelegate.columns ||
        colorScheme != oldDelegate.colorScheme ||
        !_sameStringSet(selectedLabels, oldDelegate.selectedLabels) ||
        !_sameStringSet(mergedPairs, oldDelegate.mergedPairs);
  }
}

class _HorizontalShelfPainter extends CustomPainter {
  const _HorizontalShelfPainter({
    required this.slotCount,
    required this.colorScheme,
    required this.selectedLabels,
    required this.mergedPairs,
  });

  final int slotCount;
  final ColorScheme colorScheme;
  final Set<String> selectedLabels;
  final Set<String> mergedPairs;

  int? slotIndexAtPosition(Offset position, Size size) {
    final safeSlotCount = slotCount > 0 ? slotCount : 1;
    final slotSize = _slotSize(size, safeSlotCount);
    final offsetX = 0.0;
    final offsetY = (size.height - slotSize) / 2;

    final localX = position.dx - offsetX;
    final localY = position.dy - offsetY;
    if (localX < 0 || localY < 0 || localY >= slotSize) {
      return null;
    }

    final slot = (localX / slotSize).floor();
    if (slot < 0 || slot >= safeSlotCount) {
      return null;
    }

    return slot + 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final safeSlotCount = slotCount > 0 ? slotCount : 1;
    final borderPaint = Paint()
      ..color = colorScheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final selectedPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;

    final labelStyle = TextStyle(
      color: colorScheme.outline,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final slotSize = _slotSize(size, safeSlotCount);
    final offsetX = 0.0;
    final offsetY = (size.height - slotSize) / 2;
    final hiddenLabels = _hiddenLabelsFromMergePairs();

    for (var index = 0; index < safeSlotCount; index++) {
      final label = LocationAssignmentTexts.slotLabelFromIndex(index + 1);
      final cellRect = Rect.fromLTWH(
        offsetX + (index * slotSize),
        offsetY,
        slotSize,
        slotSize,
      );
      if (selectedLabels.contains(label)) {
        canvas.drawRect(cellRect, selectedPaint);
      }

      canvas.drawLine(cellRect.topLeft, cellRect.topRight, borderPaint);
      canvas.drawLine(cellRect.bottomLeft, cellRect.bottomRight, borderPaint);
      if (index == 0) {
        canvas.drawLine(cellRect.topLeft, cellRect.bottomLeft, borderPaint);
      }
      if (index == safeSlotCount - 1 ||
          !_isMerged(
            label,
            LocationAssignmentTexts.slotLabelFromIndex(index + 2),
          )) {
        canvas.drawLine(cellRect.topRight, cellRect.bottomRight, borderPaint);
      }

      if (!hiddenLabels.contains(label)) {
        _paintCenteredText(
          canvas,
          text: label,
          center: cellRect.center,
          style: labelStyle.copyWith(fontSize: slotSize < 22 ? 10 : 12),
        );
      }
    }
  }

  Set<String> _hiddenLabelsFromMergePairs() {
    final hidden = <String>{};
    for (final pair in mergedPairs) {
      final parts = pair.split('|');
      if (parts.length == 2) {
        hidden.add(parts[1]);
      }
    }
    return hidden;
  }

  bool _isMerged(String first, String second) {
    return mergedPairs.contains(
          LocationAssignmentTexts.joinWithPipe(first, second),
        ) ||
        mergedPairs.contains(
          LocationAssignmentTexts.joinWithPipe(second, first),
        );
  }

  double _slotSize(Size size, int safeSlotCount) {
    final labelStyle = TextStyle(
      color: colorScheme.outline,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    final samplePainter = TextPainter(
      text: TextSpan(
        text: LocationAssignmentTexts.slotLabelFromIndex(safeSlotCount),
        style: labelStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final textExtent = math.max(samplePainter.width, samplePainter.height);
    final desiredSlotSize = textExtent + 12;
    final maxSlotSizeByWidth = size.width / safeSlotCount;
    return math.min(math.min(size.height, maxSlotSizeByWidth), desiredSlotSize);
  }

  void _paintCenteredText(
    Canvas canvas, {
    required String text,
    required Offset center,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - (painter.width / 2), center.dy - (painter.height / 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _HorizontalShelfPainter oldDelegate) {
    return slotCount != oldDelegate.slotCount ||
        colorScheme != oldDelegate.colorScheme ||
        !_sameStringSet(selectedLabels, oldDelegate.selectedLabels) ||
        !_sameStringSet(mergedPairs, oldDelegate.mergedPairs);
  }
}

class _SelectedSlotTarget {
  const _SelectedSlotTarget({
    required this.locationCode,
    required this.slotType,
    required this.containerLabel,
    required this.slotLabel,
  });

  final String locationCode;
  final String slotType;
  final String containerLabel;
  final String slotLabel;

  String get containerKey => LocationAssignmentTexts.containerKey(
    locationCode,
    slotType,
    containerLabel,
  );

  bool sameAs(_SelectedSlotTarget other) {
    return locationCode == other.locationCode &&
        slotType == other.slotType &&
        containerLabel == other.containerLabel &&
        slotLabel == other.slotLabel;
  }
}

class _DrawerCell {
  const _DrawerCell({required this.column, required this.row});

  final int column;
  final int row;

  static _DrawerCell? fromLabel(String label) {
    final match = RegExp(
      LocationAssignmentTexts.drawerCellLabelRegex,
    ).firstMatch(label);
    if (match == null) {
      return null;
    }

    final letters = match.group(1)!;
    final row = int.tryParse(match.group(2)!);
    if (row == null) {
      return null;
    }

    var column = 0;
    for (var i = 0; i < letters.length; i++) {
      final codeUnit = letters.codeUnitAt(i) - 64;
      column = (column * 26) + codeUnit;
    }

    return _DrawerCell(column: column - 1, row: row - 1);
  }
}

bool _sameStringSet(Set<String> first, Set<String> second) {
  return first.length == second.length && first.containsAll(second);
}
