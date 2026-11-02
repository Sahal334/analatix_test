# Product Catalogue App

Technical assignment for the Mobile App Developer role at Analytix.

This is a mobile product catalogue application for iOS and Android built using Flutter and the DummyJSON API.

## Requirements Checklist

- Authentication: Login with username/password (`emilys` / `emilyspass`), error handling, session persistence across app restarts, and logout confirmation.
- Secure Storage: Auth tokens stored in iOS Keychain and Android Keystore using flutter_secure_storage with encrypted shared preferences enabled.
- Product List: Paginated list loading 20 products at a time on scroll, displaying thumbnail, title, price, and rating.
- Pull to Refresh: RefreshIndicator on the product catalogue.
- Search: Live search debounced by 500ms so API is only called after the user stops typing.
- Product Detail: Image carousel with indicators, price, rating, category, stock count, and full description. Null-safe brand handling for items without a brand.
- Favourites: Save and remove products from favourites, persisted locally via Hive so data remains after closing the app.
- QR Scanner: Scans `catalogue://product/{id}` codes, validates format, requests camera permission only when opening the scanner, and includes a "Type code instead" dialog for simulator testing.
- Offline Mode: Automatically loads cached products and displays an offline banner when internet is unavailable.
- Arabic / RTL Support: In-app language toggle in Settings that switches the app to Arabic and flips the entire layout to Right-to-Left (RTL).
- UI States: Loading, empty, and error states with retry buttons on all screens.
- Testing: Unit test suite covering authentication, pagination, caching, favourites, debouncing, and QR parsing.
- Bonus features: Dark mode support and torch toggle in scanner.

## Tech Stack & Libraries

- Flutter 3.47 / Dart 3.13
- State Management: flutter_riverpod (Provider, StateNotifierProvider, StreamProvider, FutureProvider)
- Navigation: go_router (ShellRoute for bottom navigation, nested sub-routes, auth redirect guard)
- Networking: dio (Base options, auth interceptor for Bearer token injection)
- Local Cache: hive_flutter (Fast NoSQL storage for offline products, favourites, and settings)
- Secure Storage: flutter_secure_storage (Keychain / Keystore token persistence)
- QR Scanner: mobile_scanner (Camera-based code detection with torch control)
- Image Caching: cached_network_image (Network image caching with placeholders and error widgets)
- Connectivity: connectivity_plus (Live connectivity state stream)
- Localization: flutter_localizations and intl (English and Arabic ARB files)
- Testing: mocktail, fake_async, and flutter_test

## Project Structure

```
lib/
├── core/
│   ├── constants/        # API endpoints, storage keys, page size
│   ├── errors/           # Custom exception classes
│   ├── extensions/       # Context helpers for theme and localization
│   ├── l10n/             # ARB localization files and generated classes
│   ├── router/           # GoRouter setup and bottom navigation shell
│   ├── theme/            # Material 3 light and dark theme configuration
│   └── utils/            # Debouncer utility and QR deep link parser
├── data/
│   ├── datasources/
│   │   ├── local/        # HiveService and SecureStorageService
│   │   └── remote/       # ApiClient with Dio
│   ├── models/           # JSON data models (ProductModel, AuthModel, etc.)
│   └── repositories/     # Repository implementations
├── domain/
│   ├── entities/         # Domain entities (ProductEntity, AuthEntity)
│   └── repositories/     # Abstract repository interfaces
├── features/
│   ├── auth/             # Login screen and auth provider
│   ├── products/         # Product list, detail screen, and providers
│   ├── favourites/       # Favourites screen and provider
│   ├── scanner/          # QR scanner screen and manual input dialog
│   └── settings/         # Settings screen (language toggle, logout)
└── main.dart             # App entry point, Hive initialization, ProviderScope
```

## How to Run

1. Make sure Flutter SDK is installed and configured:
```bash
flutter --version
```

2. Get dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run static analysis:
```bash
flutter analyze
```

5. Run unit tests:
```bash
flutter test
```

6. Run the app:
```bash
flutter run
```

## Test QR Codes

For testing the scanner on a physical device or simulator (using the "Type code instead" button):

- `catalogue://product/3` -> Opens product 3
- `catalogue://product/15` -> Opens product 15
- `catalogue://product/9999` -> Shows "Product not found."
- `https://example.com` -> Shows "This QR code is not a product."

## Hours Spent & Potential Improvements

- Total time spent: ~5 hours
- Potential future improvements:
  - Add biometric authentication (Face ID / fingerprint) for faster login.
  - Full cache pagination across all browsed pages.
  - End-to-end integration tests using integration_test package.
