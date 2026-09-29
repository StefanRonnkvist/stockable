import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/database/app_database.dart';
import 'features/add_storage_location/add_storage_location_tab.dart';
import 'features/help/help_tab.dart';
import 'features/information/information_tab.dart';
import 'features/inventory/inventory_tab.dart';
import 'features/location_assignment/location_assignment_tab.dart';
import 'features/reports/reports_tab.dart';
import 'features/settings/settings_tab.dart';
import 'texts/language/app_strings.dart';

/// Coordinates top-level feature navigation and shared user preferences.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  static const _helpTabIndex = 5;
  static const _smallLayoutMaxWidth = 700.0;
  static const _mediumLayoutMaxWidth = 1100.0;

  late final TabController _tabController;
  int _currentTabIndex = 0;
  int _inventoryRefreshToken = 0;
  bool _useMetric = false;
  bool _showWebDatabaseWarning = true;

  /// Maps width breakpoints to drawer, scrollable-tab, or full-tab layouts.
  _TabBarLayout _tabBarLayoutForWidth(double width) {
    if (width < _smallLayoutMaxWidth) {
      return _TabBarLayout.small;
    }
    if (width < _mediumLayoutMaxWidth) {
      return _TabBarLayout.medium;
    }
    return _TabBarLayout.large;
  }

  /// Builds a tab bar whose alignment and scrolling match the active layout.
  TabBar _buildResponsiveTabBar({
    required _TabBarLayout layout,
    required List<String> tabs,
  }) {
    switch (layout) {
      case _TabBarLayout.small:
        return TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        );
      case _TabBarLayout.medium:
        return TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 18),
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        );
      case _TabBarLayout.large:
        return TabBar(
          controller: _tabController,
          isScrollable: false,
          tabAlignment: TabAlignment.fill,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    final initialTabs = AppStrings.forLocale(null).tabs;
    _tabController = TabController(length: initialTabs.length, vsync: this);
    _tabController.addListener(_handleTabControllerChanged);
    _openHelpTabIfDatabaseIsEmpty();
  }

  /// Mirrors controller changes into state for drawer selection and callbacks.
  void _handleTabControllerChanged() {
    if (!mounted) {
      return;
    }
    final nextIndex = _tabController.index;
    if (_currentTabIndex == nextIndex) {
      return;
    }
    setState(() => _currentTabIndex = nextIndex);
  }

  /// Opens Help on web, first run, or when the database cannot be inspected.
  ///
  /// Navigation waits until after the first frame and only proceeds while the
  /// user remains on the initial tab, so it never overrides an early choice.
  Future<void> _openHelpTabIfDatabaseIsEmpty() async {
    var shouldOpenHelp = kIsWeb;

    if (!kIsWeb) {
      try {
        final storageLocationCount = await AppDatabase.instance
            .storageLocationCount();
        shouldOpenHelp = storageLocationCount == 0;
      } catch (_) {
        // Treat missing/unavailable DB as first-run and send user to Help.
        shouldOpenHelp = true;
      }
    }

    if (!mounted || !shouldOpenHelp || _currentTabIndex != 0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _currentTabIndex != 0) {
        return;
      }
      _tabController.animateTo(_helpTabIndex);
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabControllerChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    final tabs = strings.tabs;
    final showWebDatabaseWarning = kIsWeb && _showWebDatabaseWarning;
    final layout = _tabBarLayoutForWidth(MediaQuery.sizeOf(context).width);
    final useDrawerNavigation = layout == _TabBarLayout.small;

    return Scaffold(
      drawer: useDrawerNavigation
          ? Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        strings.appTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            selected: _currentTabIndex == index,
                            title: Text(tabs[index]),
                            onTap: () {
                              Navigator.of(context).pop();
                              _tabController.animateTo(index);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(strings.appTitle),
        bottom: useDrawerNavigation
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(kTextTabBarHeight),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final barLayout = _tabBarLayoutForWidth(
                      constraints.maxWidth,
                    );

                    return _buildResponsiveTabBar(
                      layout: barLayout,
                      tabs: tabs,
                    );
                  },
                ),
              ),
      ),
      body: Column(
        children: [
          if (showWebDatabaseWarning)
            Material(
              color: Theme.of(context).colorScheme.error,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 56, 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.webDatabaseWarning,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        tooltip: strings.closeButton,
                        color: Theme.of(context).colorScheme.onError,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _showWebDatabaseWarning = false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const LocationAssignmentTab(),
                AddStorageLocationTab(
                  useMetric: _useMetric,
                  onLocationsChanged: () {
                    setState(() => _inventoryRefreshToken++);
                  },
                ),
                InventoryTab(
                  refreshToken: _inventoryRefreshToken,
                  useMetric: _useMetric,
                ),
                const ReportsTab(),
                SettingsTab(
                  themeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged,
                  useMetric: _useMetric,
                  onUnitSystemChanged: (value) =>
                      setState(() => _useMetric = value),
                  onLocationsCleared: () {
                    if (!mounted) {
                      return;
                    }
                    setState(() => _inventoryRefreshToken++);
                    if (_currentTabIndex != _helpTabIndex) {
                      _tabController.animateTo(_helpTabIndex);
                    }
                  },
                ),
                const HelpTab(),
                InformationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _TabBarLayout { small, medium, large }
