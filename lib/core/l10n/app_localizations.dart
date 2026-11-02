import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Analytix Catalogue'**
  String get appName;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// Error shown when credentials are wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get loginError;

  /// Error shown on network failure during login
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get loginErrorNetwork;

  /// Products tab label
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Search bar hint text
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get search;

  /// Scan button label
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Favourites tab label
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// Empty state title for favourites
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get noFavourites;

  /// Empty state subtitle for favourites
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on a product to save it'**
  String get noFavouritesSubtitle;

  /// Offline status banner message
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offlineBanner;

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading indicator label
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorOccurred;

  /// Error when product ID does not exist
  ///
  /// In en, this message translates to:
  /// **'Product not found.'**
  String get productNotFound;

  /// Error shown when scanned QR is not a product link
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a product.'**
  String get invalidQrCode;

  /// Option to type product code manually
  ///
  /// In en, this message translates to:
  /// **'Type code instead'**
  String get typeCodeInstead;

  /// Dialog title for manual code entry
  ///
  /// In en, this message translates to:
  /// **'Enter product code'**
  String get enterProductCode;

  /// Hint text for manual code entry field
  ///
  /// In en, this message translates to:
  /// **'e.g. catalogue://product/3'**
  String get enterProductCodeHint;

  /// Open button label
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Error when entered code format is wrong
  ///
  /// In en, this message translates to:
  /// **'Invalid code format'**
  String get invalidCode;

  /// Error title when camera permission is denied
  ///
  /// In en, this message translates to:
  /// **'Camera permission denied'**
  String get cameraPermissionDenied;

  /// Explanation message for camera permission
  ///
  /// In en, this message translates to:
  /// **'This app needs camera access to scan QR codes.'**
  String get cameraPermissionMessage;

  /// Button to open device settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Brand label on product detail
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// Category label on product detail
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Rating label on product detail
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Price label on product detail
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Stock availability label
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get stock;

  /// Button to add product to favourites
  ///
  /// In en, this message translates to:
  /// **'Add to Favourites'**
  String get addToFavourites;

  /// Button to remove product from favourites
  ///
  /// In en, this message translates to:
  /// **'Remove from Favourites'**
  String get removeFromFavourites;

  /// Empty state message for products list
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// Pull to refresh hint label
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// Title for the scanner screen
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scannerTitle;

  /// Instruction text on scanner screen
  ///
  /// In en, this message translates to:
  /// **'Point the camera at a QR code'**
  String get pointCamera;

  /// Fallback text when product has no brand
  ///
  /// In en, this message translates to:
  /// **'No brand'**
  String get noBrand;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
