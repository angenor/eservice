# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application called "eservicev1" that appears to be an e-service platform with banking/financial service features based on the directory structure.

## Development Commands

### Running the Application
```bash
flutter run                  # Run app on connected device/emulator
flutter run -d chrome        # Run in web browser
flutter run -d ios           # Run on iOS simulator
flutter run -d android       # Run on Android emulator
```

### Building
```bash
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app
flutter build web            # Build for web
```

### Testing
```bash
flutter test                 # Run all tests
flutter test test/widget_test.dart  # Run specific test file
```

### Code Quality
```bash
flutter analyze              # Analyze code for issues
flutter format .             # Format all Dart files
```

### Dependencies
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade dependencies
flutter pub outdated         # Check for outdated packages
```

## Project Structure

The application follows standard Flutter project structure with:
- `lib/main.dart` - Entry point containing MyApp and MyHomePage widgets
- `test/` - Contains widget tests
- `bank/` - Custom directory containing:
  - `documentations/client_app_categories/` - Project documentation organized by categories
  - `mode_de_donnees/` - Database schema and SQL files (schema.sql, functions.sql, policies.sql)

## Database Architecture

**IMPORTANT**: For any data implementation, widgets that interact with data, or database-related functionality, you MUST refer to `bank/mode_de_donnees/README.md` which contains links to all essential database files and comprehensive documentation.

The project includes SQL schema definitions in `bank/mode_de_donnees/` suggesting a backend database integration using Supabase service:
- `schema.sql` - Complete table definitions, types and indexes
- `functions.sql` - Utility functions, triggers and CRON jobs
- `policies.sql` - Row Level Security (RLS) policies
- `README.md` - **PRIMARY REFERENCE** for all database architecture and implementation guidance

### Migration Scripts
All database migration scripts must be organized in: `bank/mode_de_donnees/migration_script/`

## Flutter Configuration

- **SDK Version**: ^3.9.2
- **Linting**: Uses flutter_lints package with standard Flutter analysis options
- **Material Design**: Enabled with uses-material-design: true
- **State Management**: Provider pattern for theme and localization
- **Localization**: Supports French and English with flutter_localizations
- **Theme System**: Centralized color palette with light/dark mode support

## Application Features

### Theme Configuration
- **Location**: `lib/core/theme/`
  - `app_colors.dart` - Centralized color palette for light and dark modes
  - `app_theme.dart` - Complete theme definitions for both modes
- **Provider**: `lib/providers/theme_provider.dart` - Manages theme state with persistence

### Localization
- **Supported Languages**: English (en) and French (fr)
- **ARB Files**: `lib/l10n/app_en.arb` and `lib/l10n/app_fr.arb`
- **Provider**: `lib/providers/locale_provider.dart` - Manages language state with persistence
- **Configuration**: `l10n.yaml` defines localization generation settings

### Settings Screen
- **Location**: `lib/screens/settings/settings_screen.dart`
- **Features**:
  - Theme mode selection (Light/Dark/System)
  - Language selection (English/French)
  - About section with version info
  - Help and contact options

## Key Dependencies

- `provider: ^6.1.1` - State management
- `shared_preferences: ^2.2.2` - Local storage for user preferences
- `intl: ^0.20.2` - Internationalization support
- `flutter_localizations` - Flutter's localization framework