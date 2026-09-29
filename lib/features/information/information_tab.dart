import 'package:flutter/material.dart';

import '../../contact/contact_page.dart';
import '../../contact/submissions_csv_page.dart';
import '../../texts/language/app_strings.dart';

class InformationTab extends StatelessWidget {
  const InformationTab({super.key});

  static final Uri _contactUri = Uri.parse(
    'https://stefanronnkvist.com/contact.php',
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TabBar(
              tabs: [
                Tab(text: strings.informationContactTab),
                Tab(text: strings.informationSubmissionsTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ContactPage(serverUri: _contactUri, showAppBar: false),
                const SubmissionsCsvCardsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
