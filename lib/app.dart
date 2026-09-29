import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home_screen.dart';
import 'splash_screen.dart';

/// Root application widget that owns theme selection and splash visibility.
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showSplash = true;

  /// Applies a theme choice received from the settings screen.
  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  /// Replaces the splash with the main navigation after its animation ends.
  void _finishSplash() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: _showSplash
          ? SplashScreen(onFinished: _finishSplash)
          : HomeScreen(
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
            ),
    );
  }
}
