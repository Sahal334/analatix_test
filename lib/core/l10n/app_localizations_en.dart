// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Analytix Catalogue';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginError => 'Invalid username or password';

  @override
  String get loginErrorNetwork => 'Network error. Please try again.';

  @override
  String get products => 'Products';

  @override
  String get search => 'Search products...';

  @override
  String get scan => 'Scan';

  @override
  String get favourites => 'Favourites';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get noFavourites => 'No favourites yet';

  @override
  String get noFavouritesSubtitle =>
      'Tap the heart icon on a product to save it';

  @override
  String get offlineBanner => 'You are offline';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'Something went wrong';

  @override
  String get productNotFound => 'Product not found.';

  @override
  String get invalidQrCode => 'This QR code is not a product.';

  @override
  String get typeCodeInstead => 'Type code instead';

  @override
  String get enterProductCode => 'Enter product code';

  @override
  String get enterProductCodeHint => 'e.g. catalogue://product/3';

  @override
  String get open => 'Open';

  @override
  String get invalidCode => 'Invalid code format';

  @override
  String get cameraPermissionDenied => 'Camera permission denied';

  @override
  String get cameraPermissionMessage =>
      'This app needs camera access to scan QR codes.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get brand => 'Brand';

  @override
  String get category => 'Category';

  @override
  String get rating => 'Rating';

  @override
  String get price => 'Price';

  @override
  String get stock => 'In Stock';

  @override
  String get addToFavourites => 'Add to Favourites';

  @override
  String get removeFromFavourites => 'Remove from Favourites';

  @override
  String get noProducts => 'No products found';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get scannerTitle => 'Scan QR Code';

  @override
  String get pointCamera => 'Point the camera at a QR code';

  @override
  String get noBrand => 'No brand';
}
