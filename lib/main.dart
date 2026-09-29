import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/database/app_database.dart';

/// Initializes platform services and opens SQLite before rendering native UI.
///
/// Web skips database initialization because the configured SQLite backend is
/// native-only; web-specific screens communicate that limitation to the user.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await AppDatabase.instance.initialize();
  }
  runApp(const MainApp());
}
