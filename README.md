# Shuffle Master

A premium Flutter application for randomizing lists with a beautiful Material 3 interface and full offline support.

## Features

- **Add Names** - Single, bulk paste, or import with comma/semicolon/newline separation
- **Multiple Groups** - Organize names into reusable groups
- **Random Shuffle** - Cryptographically secure shuffling with animated results
- **Duplicate Detection** - Warns before adding duplicate names
- **Favorites** - Pin favorite names within groups
- **Search** - Instant search within groups
- **Drag & Drop** - Reorder names manually
- **History** - Track all past shuffle results
- **Statistics** - View shuffle counts and usage stats
- **Theme** - Light, Dark, and System theme support
- **Export/Import** - Backup and restore all data as JSON
- **Share & Copy** - Share results or copy to clipboard
- **Responsive** - Works on phones, tablets, and foldables
- **Offline-First** - All data stored locally with Hive

## Tech Stack

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Declarative routing |
| hive + hive_flutter | Local NoSQL database |
| google_fonts | Typography (Inter) |
| flutter_animate | Smooth UI animations |
| share_plus | Native share sheet |
| intl | Date formatting |
| uuid | Unique ID generation |
| collection | Collection utilities |
| lottie | Animation support |

## Getting Started

### Prerequisites

- Flutter SDK >= 3.13.2
- Dart SDK >= 3.13.2

### Setup

```bash
# Clone the repository
git clone <repo-url>

# Navigate to project
cd shuffle_master

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Run Tests

```bash
flutter test
```

### Analyze Code

```bash
flutter analyze
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants/app_constants.dart   # App-wide constants
│   ├── routes/app_router.dart         # GoRouter configuration
│   ├── theme/
│   │   ├── app_colors.dart            # Material 3 color palette
│   │   ├── app_theme.dart             # Light/Dark theme builders
│   │   └── app_typography.dart        # Google Fonts text theme
│   ├── utils/
│   │   ├── extensions.dart            # BuildContext, String, List extensions
│   │   └── responsive.dart            # Responsive layout utilities
│   ├── widgets/app_widgets.dart       # Shared widgets (AppCard, EmptyState, etc.)
│   └── services/database_service.dart # Hive wrapper
├── models/
│   ├── name_entry.dart                # Individual name model
│   ├── group.dart                     # Group of names model
│   ├── history_entry.dart             # Shuffle history model
│   └── app_settings.dart              # User preferences model
├── database/
│   └── app_repository.dart            # Local data access layer
├── providers/
│   ├── repository_provider.dart       # Repository singleton
│   ├── settings_provider.dart         # Theme & settings state
│   ├── groups_provider.dart           # Groups CRUD state
│   ├── history_provider.dart          # History state
│   └── shuffle_provider.dart          # Shuffle logic service
└── features/
    ├── splash/splash_screen.dart      # Animated splash
    ├── home/home_screen.dart          # Dashboard with stats
    ├── groups/groups_screen.dart      # Groups list + create/rename/delete
    ├── group_detail/group_detail_screen.dart  # Names list + add/edit/search
    ├── shuffle/shuffle_screen.dart    # Shuffle animation + results
    ├── history/history_screen.dart    # Grouped history view
    └── settings/settings_screen.dart  # Theme, data management, about
```

## Architecture

- **Clean Architecture** - Separated models, providers (business logic), and UI
- **Riverpod** - Reactive state management with typed providers
- **Repository Pattern** - Single data access layer via `AppRepository`
- **Feature-Based Structure** - Each feature is self-contained
- **Offline-First** - Hive for persistent local storage

## Edge Cases Handled

- Empty name validation
- Duplicate name detection with confirmation
- Very long name support
- Empty list shuffle prevention
- Rapid repeated tap protection
- Device rotation responsive layout
- Theme persistence across restarts
- Data export/import for portability

## License

MIT
