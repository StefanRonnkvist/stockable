import 'package:flutter/material.dart';

import '../../texts/language/app_strings.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));
    return Center(child: Text(strings.reportsPageTitle));
  }
}
