# Stockable

Stockable is a Flutter app for mapping physical storage locations into a digital layout. Create cabinets, racks, or floor areas, define supported drawers and shelves, and record text descriptions of what is stored in each slot. On supported native platforms, working data is stored locally in SQLite; there is no cloud synchronization.

## Features

- Create cabinet, rack, and floor locations with generated quick names and unique identifiers.
- Configure indoor or outdoor use, dimensions, weight limits, and supported drawer or shelf layouts.
- Create numbered batches of locations that share the same configuration.
- View drawer and shelf layouts, and add or edit text contents on individual slots.
- Merge or unmerge adjacent slots within the same drawer or shelf.
- Review, edit, refresh, and delete saved storage-location records.
- Choose metric or imperial units and system, light, or dark appearance. The interface is currently available in English.
- Run SQLite integrity checks and diagnostics, optimize the database, and rebuild indexes.
- Export the database as JSON, import XML, or export locations, slot contents, and merges together as XML.
- Save XML and header-only CSV templates for location and inventory data.
- Use online Contact and Submissions features from the Information tab.
- Read built-in workflow guidance and current limitations in the Help tab, which opens automatically on first run, when the local database cannot be inspected, and on web builds.

## Getting Started

1. Open **Add Storage Location** and choose a cabinet, floor area, or rack.
2. Set indoor or outdoor use, dimensions, weight limits, and any supported drawer or shelf layout. **Create Multiple Locations** makes a numbered batch with the same layout.
3. Open **Location Assignment**, choose the saved location, and review its details.
4. Long-press a drawer or shelf slot to add or edit its text contents.
5. Tap two adjacent slots in the same drawer or shelf, then choose **Merge** or **Unmerge** to reflect the physical compartments.
6. Use **Inventory** to review, edit, or delete storage-location records. The Add Spare Part form is only a preview and does not save records.
7. Use **Settings** to select units and appearance, and export data before importing or clearing anything.

## Current Limitations

- The **Add Spare Part** form in Inventory is a preview and does not save spare-part records. Inventory currently manages storage-location records.
- **Reports** is a placeholder; this release does not generate reports or analytics.
- Web/PWA builds do not have a persistent database or database/file tools. The app displays a warning, and data lasts only for the current browser session.
- The interface is currently available in English.
- Contact and Submissions require an internet connection.

## Data and Platforms

On supported native Android, iOS, Windows, macOS, and Linux builds, Stockable stores working data in a local SQLite database. Database controls and file import/export are available on non-web builds. Keep your own exports before importing (which replaces existing data), clearing location data, or replacing an installation. Web/PWA builds do not provide a persistent database or database/file tools; data lasts only for the current browser session. There is no cloud synchronization.

The project includes Flutter targets for Android, iOS, Windows, macOS, Linux, and web. Platform availability still depends on the Flutter toolchain and plugins installed on the build host.

## Development

Requirements:

- Flutter SDK compatible with Dart `^3.11.4`
- A configured toolchain for the target platform

Install dependencies and run the app:

```console
flutter pub get
flutter run
```

Run static analysis:

```console
flutter analyze
```

Build a release target, for example:

```console
flutter build apk --release
flutter build windows --release
flutter build web --release
```

The app version is defined in `pubspec.yaml`. Release scripts and VS Code tasks are available in `scripts/`, `tool/`, and `.vscode/tasks.json` where applicable.

## Project Structure

- `lib/features/` contains the tab-level product features.
- `lib/core/database/` contains local database setup and maintenance.
- `lib/texts/` contains the English UI copy and formatting helpers.
- `templates/` contains XML import templates bundled with the app.
- `store_listing/` contains release-facing store copy and the product synopsis.