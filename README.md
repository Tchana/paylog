# Paylog

Paylog is a Flutter application that helps churches, schools, and community programs track tuition-style payments across multiple programs, courses, and members. It provides an offline-first experience powered by Hive, supports CSV/JSON export/import, generates PDF reports, and runs on Android, iOS, web, and desktop.

---

## Table of Contents

1. [Features](#features)
2. [Architecture Overview](#architecture-overview)
3. [Screens](#screens)
4. [Data Model](#data-model)
5. [Platform Services](#platform-services)
6. [Internationalization](#internationalization)
7. [Getting Started](#getting-started)
8. [Environment & Tooling](#environment--tooling)
9. [Running & Testing](#running--testing)
10. [Troubleshooting](#troubleshooting)
11. [Roadmap](#roadmap)
12. [License](#license)

---

## Features

- **Programs & Courses**
  - Create and manage programs (e.g., Bible School) and their courses.
  - Track course fees, descriptions, and enrollment counts.

- **Members & Enrollments**
  - Add members, assign them to programs/courses.
  - Track contact info, balances, and per-course payments.

- **Payments & Allocations**
  - Record payments once; the `PaymentAllocator` automatically spreads amounts across the member’s enrolled courses (FIFO by course creation date).
  - View detailed payment history, including auto-assigned course breakdowns.

- **Dashboards**
  - Key metrics: total programs, members, collected funds, pending balances.
  - Recent payments list with quick access to member context.
  - FAB-driven creation flow, inline link to the program directory.

- **Data Export / Import**
  - JSON export/import for full data backups.
  - CSV export with proper column separation for payments (mobile & web).
  - Platform-specific storage/share flows (Path Provider + Share on mobile, Blob downloads on web).

- **Reports**
  - Member payment PDF report (per-member history and per-course summary).
  - Global summary PDF report covering all payments, totals, and stats.

- **Settings**
  - Language and currency selectors (defaults to device locale).
  - Dark mode toggle (defaults to device theme).
  - Data management actions (export/import/report).

- **Internationalization**
  - English (`en_US`) and French (`fr_FR`) translations via GetX.

- **Testing**
  - Payment allocation logic with deterministic Hive setup & mocking.

---

## Architecture Overview

- **State Management**: [GetX](https://pub.dev/packages/get) provides DI, routing, reactivity.
- **Persistence**: [Hive](https://pub.dev/packages/hive) for offline storage, with repositories wrapping each box.
- **UI Layer**: `lib/core/presentation` uses GetX controllers per feature and Material widgets.
- **Platform Abstraction**: `platform_service_factory.dart` uses conditional imports to select web vs mobile service implementations at compile time.
- **PDF/CSV Generation**: [pdf](https://pub.dev/packages/pdf) + [printing](https://pub.dev/packages/printing) for documents; manual CSV formatting ensures Excel/Sheets compatibility.
- **File Access**: `path_provider`, `share_plus`, and `file_picker` for storage & sharing.

Directory highlights:

```
lib/
 ├── core/
 │    ├── app/                 # Routes, theme, bindings
 │    ├── presentation/        # Controllers, views, widgets
 │    ├── services/            # Domain services & platform abstractions
 │    └── translations/        # i18n keys
 ├── data/
 │    ├── models/              # Hive data classes
 │    └── repositories/        # CRUD wrappers
 └── main.dart                 # App entrypoint
```

---

## Screens

| Screen | Highlights |
| --- | --- |
| Dashboard | Metrics cards, recent payments, quick links/FAB |
| Program list/detail | Manage programs, view course lineup, edit/delete |
| Member list/detail | Member profile, balances, per-course summary, payment history, record payment |
| Record payment | Single form that returns control to detail view after allocation |
| Settings | Language, currency, theme, export/import/report actions |

Key navigation flows are defined in `lib/core/app/routes/app_pages.dart`.

---

## Data Model

All entities are Hive objects with generated adapters:

- `Program` → holds metadata and acts as the parent scope.
- `Course` → linked to a program; stores fee and descriptions.
- `Member` → belongs to a program; tracks balance/debt.
- `Enrollment` → member-course relationship; tracks amount paid per course.
- `Payment` → records transaction metadata plus `autoAssignedCourses` for allocation audit.
- `AllocationEntry` → embedded inside `Payment` to capture per-course allocation.

Repositories provide async CRUD APIs per entity and are injected wherever needed (Get.put in controllers/services).

---

## Platform Services

Located in `lib/core/services/platform`:

- `DataExportServiceInterface` + mobile/web implementations (`saveAndShareFile` vs Blob downloads).
- `DataImportServiceInterface` + mobile/web implementations (`file_picker` vs `FileUploadInputElement`).
- `ReportServiceInterface` + PDF logic for member & summary reports (mobile saves/share, web downloads).
- `UnifiedServiceInterface` consolidates export/import/report tasks for Settings.
- `PlatformServiceFactory` uses conditional imports so only the relevant implementation gets compiled (mobile or web), avoiding `dart:html` issues on mobile.

---

## Internationalization

Translations live in `assets/translations/en_US.json` and `fr_FR.json`, wired up via `GetMaterialApp.translations` (`AppTranslations`). Use `key.tr` throughout the UI.

---

## Getting Started

### Prerequisites

- Flutter 3.x with Dart 3.x SDK (`>=3.0.0 <4.0.0` per `pubspec.yaml`).
- Android Studio / Xcode / VS Code for platforms you target.
- Hive requires build_runner for adapter generation (already committed).

### Installation

```bash
flutter pub get
# If you need to regenerate Hive adapters:
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Running

```bash
# Mobile/Desktop
flutter run

# Web
flutter run -d chrome
```

Use `flutter run --release` for production builds.

---

## Environment & Tooling

- **State**: GetX reactive controllers.
- **Storage**: Hive boxes initialized via `HiveService.initialize()` (called in `main.dart`).
- **Theming**: Defined in `AppTheme` with light/dark variants.
- **Routing**: `AppPages.routes` with named routes (e.g., `/dashboard`, `/programs`, `/settings`).
- **Tests**: Stored in `test/`, currently covering payment allocation behavior.

---

## Running & Testing

```bash
# Analyze
flutter analyze

# Widget/unit tests
flutter test
```

Tests use `TestWidgetsFlutterBinding.ensureInitialized()` and mock `path_provider` for Hive to avoid MissingPluginExceptions.

---

## Troubleshooting

| Issue | Fix |
| --- | --- |
| `MissingPluginException (path_provider)` during tests | Already mocked in tests; if adding new ones, ensure `ServicesBinding` is initialized + mock channel handlers. |
| `dart:html not available` on mobile | Conditional imports already guard this; avoid referencing web-only services outside platform-specific files. |
| “Lost connection to device / DevFSException” | Restart `flutter run`, reconnect device/emulator, or run `flutter clean`. |
| CSV columns merged | Export services now quote each field; ensure your spreadsheet tool uses comma delimiter. |

---

## Roadmap

- ✅ Dashboard refresh after navigation.
- ✅ Device-aware settings defaults.
- ✅ Proper CSV column export.
- ⏳ Potential enhancements:
  - Search/filter for members and payments.
  - Cloud sync or remote backup option.
  - Additional analytics widgets.

---

## License

This project is distributed privately (no explicit license). Update this section if you plan to open-source or distribute Paylog.

---

For questions or contributions, please open an issue or contact the maintainer. Happy tracking! 🚀
