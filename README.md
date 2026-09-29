# Stockable

Stockable is a Flutter application for mapping physical storage locations into a digital layout. It is designed around cabinets, racks, floor areas, drawers, shelves, and their individual slots.

## Features

- Create cabinet, rack, and floor storage locations.
- Generate readable quick names and unique location identifiers.
- Configure indoor or outdoor locations, dimensions, weight limits, drawers, and shelves.
- Create multiple similarly configured locations as a numbered batch.
- View a location as a drawer or shelf layout.
- Add and edit text stored against individual slots.
- Merge and unmerge adjacent slots to match physical compartments.
- Review, edit, refresh, and delete saved location records.
- Switch between metric and imperial units and system, light, or dark themes.
- Run SQLite integrity checks, diagnostics, optimization, and index rebuilding.
- Export database data as JSON or XML and import supported XML data.
- Generate XML and CSV templates for location and inventory data.
- Contact support and review Stockable submissions from the Information tab.
- Read a built-in Help tab with per-tab guidance, first-run onboarding, and current limitations.

## Getting Started

1. Open **Add Storage Location** and choose a cabinet, floor area, or rack.
2. Configure its environment, size, weight limits, and compartment layout.
3. Create the location, then open **Location Assignment**.
4. Select the location and long-press a slot to name its contents.
5. Select two adjacent slots and use **Merge** or **Unmerge** when the physical compartment spans more than one slot.
6. Use **Inventory** to review and maintain the saved location records.
7. Use **Settings** to export data before destructive maintenance or major changes.

Help opens automatically when the app cannot find any saved locations, on the first run, and on web builds. It also lists the current release limitations.

## Current Limitations

- The **Add Spare Part** fields in Inventory are a UI preview and do not save inventory items yet.
- **Reports** is a placeholder; this release does not generate reports or analytics.
- Web/PWA builds do not provide persistent local database features. The app displays a warning and data is temporary for the browser session.
- The interface is currently available in English.
- Contact and submission features require network access.

## Data and Platforms

On Android, iOS, Windows, macOS, and Linux, Stockable stores its working data in a local SQLite database. Database controls and file import/export are available only on supported non-web builds. The app does not advertise cloud synchronization; export important data before clearing locations or replacing an installation.

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