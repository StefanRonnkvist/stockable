import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../texts/language/app_strings.dart';

class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.forLocale(Localizations.maybeLocaleOf(context));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HelpSection(
          title: strings.gettingStartedTitle,
          child: _BulletTextList(text: strings.gettingStartedDescription),
        ),
        if (kIsWeb) ...[
          const SizedBox(height: 16),
          _HelpSection(
            title: strings.noticeTitle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2, right: 8),
                  child: Icon(Icons.info_outline, size: 18),
                ),
                Expanded(child: Text(strings.webDatabaseWarning)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        _HelpSection(
          title: strings.limitationsTitle,
          child: _BulletTextList(text: strings.limitationsDescription),
        ),
        const SizedBox(height: 16),
        _HelpSection(
          title: strings.setupTabsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabHelpGroup(
                title: strings.helpLocationAssignmentTitle,
                description: strings.helpLocationAssignmentDescription,
              ),
              const SizedBox(height: 12),
              _TabHelpGroup(
                title: strings.helpAddStorageLocationTitle,
                description: strings.helpAddStorageLocationDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _HelpSection(
          title: strings.operationsTabsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabHelpGroup(
                title: strings.helpInventoryTitle,
                description: strings.helpInventoryDescription,
              ),
              const SizedBox(height: 12),
              _TabHelpGroup(
                title: strings.helpReportsTitle,
                description: strings.helpReportsDescription,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _HelpSection(
          title: strings.supportTabsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabHelpGroup(
                title: strings.helpSettingsTitle,
                description: strings.helpSettingsDescription,
              ),
              const SizedBox(height: 12),
              _TabHelpGroup(
                title: strings.helpInformationTitle,
                description: strings.helpInformationDescription,
              ),
              const SizedBox(height: 12),
              _TabHelpGroup(
                title: strings.helpHelpTitle,
                description: strings.helpHelpDescription,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.title, required this.child});

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

class _BulletTextList extends StatelessWidget {
  const _BulletTextList({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final items = _TabHelpGroup.toBulletItems(text);
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('\u2022 '),
              ),
              Expanded(child: Text(item)),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _TabHelpGroup extends StatelessWidget {
  const _TabHelpGroup({required this.title, required this.description});

  final String title;
  final String description;

  /// Converts prose separated by sentence punctuation into compact bullets.
  static List<String> toBulletItems(String text) {
    final normalized = text.replaceAll('\n', ' ').trim();
    if (normalized.isEmpty) {
      return const [];
    }

    final parts = normalized
        .split(RegExp(r'[.;]\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    return parts.isEmpty ? [normalized] : parts;
  }

  @override
  Widget build(BuildContext context) {
    final items = toBulletItems(description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 6),
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Text('\u2022 '),
              ),
              Expanded(child: Text(item)),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}
