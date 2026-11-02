# Product Catalogue App - Technical Assignment
# created this README with the assistance of AI to provide reviewers with a clear and detailed overview of the project.

Submission for the Mobile App Developer position at Analytix.

Candidate: Muhammed Sahal
Platform: Flutter (iOS and Android)
 

## Demo Video and Android APK

- Google Drive Folder (contains screen recording demonstration and release APK):
  https://drive.google.com/drive/folders/1yHqULxvU5A5RiNlqA5kpK1CE73BkHMKZ?usp=drive_link

- Demonstrations covered in the video:
  - Authentication flow, session persistence, and logout
  - Biometric authentication (Face ID and fingerprint unlock)
  - Catalogue infinite scroll pagination (20 items/page) and 500ms debounced search
  - Offline mode with "You are offline" banner and Hive cache fallback
  - Arabic language toggle with complete Right-to-Left (RTL) layout flip
  - QR code scanner with deep link navigation and simulator manual input

## How to Run the App

### Prerequisites
- Flutter SDK 3.24 or newer
- Xcode 15+ (for iOS simulator or device)
- Android Studio with Android SDK 34+ (for Android emulator or device)

### Quick Start Commands
From the project root directory:

1. Install dependencies:
```bash
flutter pub get
````

5. Launch the application:
```bash
flutter run
```

### Reviewer Testing Guide

#### 1. Authentication and Secure Storage
- Credentials: Username `emilys`, Password `emilyspass`.
- Invalid credentials test: Enter any random username or password to view error handling.
- Session persistence: Log in, restart the app (or stop and re-run); the app automatically restores the session from Keychain/Keystore directly into the catalogue without showing the login screen.
- Secure storage: Auth tokens are written to iOS Keychain and Android Keystore with `encryptedSharedPreferences: true`. Tokens are never logged or stored in plain SharedPreferences.

#### 2. Product Catalogue and Search
- Infinite Scroll: The catalogue loads 20 products per page. Scroll to the bottom to automatically trigger the next page.
- Pull-to-Refresh: Pull down on the product list to refresh catalogue data.
- Debounced Search: Type in the search bar. The API is called with a 500ms debounce once typing stops, preventing redundant API requests.
- Product Detail: Tap any product to view the images carousel, price, rating, stock count, full description, and null-safe brand display.

#### 3. Favourites
- Tap the heart icon on any product card or detail page to save it.
- Navigate to the Favourites tab to view saved items.
- Close and reopen the app; favourites are persisted locally in Hive.

#### 4. QR Scanner
- Tap the Scan button in the Products app bar.
- Camera permission is requested only upon tapping Scan.
- Physical device: Point camera at test QR codes.
- Simulator: Tap "Type code instead" in the scanner dialog and paste any test code:
  - `catalogue://product/3` - Opens product 3
  - `catalogue://product/15` - Opens product 15
  - `catalogue://product/9999` - Shows "Product not found." error
  - `https://example.com` - Shows "This QR code is not a product." error
- Torch: Tap the flash icon in the top right of the scanner to toggle camera light.

#### 5. Offline Mode
- Disconnect Wi-Fi / enable Airplane mode on your device or simulator.
- The app displays an amber "You are offline" banner at the top of the screen.
- The product catalogue falls back immediately to cached products in Hive without blank screens or crashes.
- Reconnecting to Wi-Fi dismisses the banner automatically.

#### 6. Arabic and Right-to-Left (RTL) Layout
- Open the Settings tab.
- Tap "Arabic" under Language.
- The entire application layout mirrors to RTL, including navigation bar, cards, text alignment, and icons.
- Tap "English" to revert back to LTR.

## Folder Structure

The application is structured following Clean Architecture principles with feature-first modularity under `lib/`:

```text
lib/
├── core/
│   ├── constants/       # API endpoints, storage keys, pagination size, debounce durations
│   ├── errors/          # Custom sealed AppException hierarchy (Network, Auth, NotFound, InvalidQr)
│   ├── l10n/            # ARB localization files (English and Arabic RTL)
│   ├── router/          # GoRouter configuration, bottom tab ShellRoute, auth redirect guards
│   ├── theme/           # Material 3 light and dark theme configurations
│   └── utils/           # 500ms Debouncer utility and QR code deep link parser
├── data/
│   ├── datasources/
│   │   ├── local/       # SecureStorage (Keychain/Keystore), Hive offline cache, Biometrics
│   │   └── remote/      # Dio API client with 401 automatic token refresh interceptor
│   ├── models/          # Data transfer models with fromJson and toJson serialization
│   └── repositories/    # Concrete implementations of domain repository contracts
├── domain/
│   ├── entities/        # Pure domain entities (AuthEntity, ProductEntity)
│   └── repositories/    # Abstract repository interfaces
├── features/
│   ├── auth/            # Login screen, biometric unlock button, auth StateNotifier
│   ├── products/        # Product list, infinite scroll, debounced search, product detail
│   ├── favourites/      # Favourites screen with swipe-to-delete and Hive state
│   ├── scanner/         # Mobile scanner camera view, torch toggle, manual code dialog
│   └── settings/        # Language switch (LTR/RTL), dark mode toggle, logout dialog
└── main.dart            # Hive initialization, pre-runApp token hydration, ProviderScope
```

## Libraries Used and Why

- flutter_riverpod (2.6.1): Chosen for compile-time safe state management and dependency injection without code generation. It decouples UI from business logic and allows clean, deterministic unit testing.
- go_router (14.8.1): Used for declarative navigation and deep linking. Its ShellRoute manages the bottom navigation bar state across sub-routes, and its redirect guard manages login/logout access control.
- dio (5.8.0): Chosen over standard http for its interceptor pipeline. A custom QueuedInterceptor handles Bearer token injection and automatically catches 401 Unauthorized responses to perform automatic token refresh against POST /auth/refresh before retrying the original request.
- flutter_secure_storage (9.2.4): Stores access tokens, refresh tokens, and biometric credentials in the iOS Keychain and Android Keystore (using encryptedSharedPreferences: true), satisfying the requirement that tokens are never kept in plain storage or logs.
- hive_flutter (1.1.0): High-performance, lightweight key-value database used for offline product caching, persisted favourites, and theme/locale preferences without requiring native SQLite binaries.
- mobile_scanner (6.0.4): High-performance camera plugin for fast QR code scanning on iOS and Android with built-in torch toggle and lifecycle handling.
- cached_network_image (3.4.1): Caches product images in memory and disk with fade transitions, loading indicators, and error fallbacks.
- connectivity_plus (6.1.4): Listens to network status changes in real-time to drive the offline banner and cache fallbacks.
- local_auth (3.0.2): Provides hardware-backed biometric authentication (Face ID on iOS and Fingerprint / BiometricPrompt on Android) for quick unlocking.
- intl and flutter_localizations: Flutter official internationalization framework powering English and Arabic translations with full RTL layout mirroring.
- mocktail (1.0.4): Type-safe mocking library used in unit and UI tests without requiring build_runner code generation.

## Bonus Features

- Biometric Authentication (Face ID / Fingerprint): After logging in once, users can unlock the app using Face ID or fingerprint via local_auth. Login credentials remain encrypted in hardware Keystore/Keychain.
- Automatic Token Refresh: Dio QueuedInterceptor automatically catches 401 Unauthorized errors, calls POST /auth/refresh with the stored refresh token, updates Keychain/Keystore, and seamlessly replays the original failed request without interrupting the user.
- Dark Mode: Full Material 3 dark theme support toggled from the Settings screen with theme state persisted across restarts.
- Scanner Torch Control: Torch toggle button in the scanner screen to assist scanning in low-light environments.
- Automated UI Test: Full-app widget test (test/unit/full_app_login_test.dart) verifying app launch, credential entry, form submission, and catalogue transition.

## What I Would Improve

- Multi-page Offline Cache: Currently, the first page of 20 products is cached in Hive for offline browsing. Given more time, I would expand this into a full cache database supporting offline search across all previously viewed items.
- End-to-End Integration Tests: Add integration_test suites with automated camera mock injection and a mock web server for automated CI runs.
- Filter and Sort Capabilities: Add category chips and sorting options (price low-to-high, rating high-to-low) on the catalogue screen.

## Hours Spent

- Total time spent: ~5 hours
- Breakdown:
  - Architecture setup, dependencies, routing, and themes: ~1 hour
  - API client, repositories, models, and secure storage: ~1 hour
  - UI screens (products, detail carousel, search, scanner, settings): ~1.5 hours
  - Offline caching, RTL layout, and localization: ~0.5 hours
  - Testing, bonus features (biometrics, token refresh), and documentation: ~1 hour

