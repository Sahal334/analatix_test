// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'كتالوج أناليتيكس';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get loginError => 'اسم المستخدم أو كلمة المرور غير صحيحة';

  @override
  String get loginErrorNetwork => 'خطأ في الشبكة. يرجى المحاولة مرة أخرى.';

  @override
  String get products => 'المنتجات';

  @override
  String get search => 'البحث في المنتجات...';

  @override
  String get scan => 'مسح';

  @override
  String get favourites => 'المفضلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get noFavourites => 'لا توجد مفضلات بعد';

  @override
  String get noFavouritesSubtitle => 'اضغط على أيقونة القلب لحفظ منتج';

  @override
  String get offlineBanner => 'أنت غير متصل بالإنترنت';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get errorOccurred => 'حدث خطأ ما';

  @override
  String get productNotFound => 'المنتج غير موجود.';

  @override
  String get invalidQrCode => 'رمز الاستجابة السريعة هذا ليس منتجاً.';

  @override
  String get typeCodeInstead => 'أدخل الرمز يدوياً';

  @override
  String get enterProductCode => 'أدخل رمز المنتج';

  @override
  String get enterProductCodeHint => 'مثال: catalogue://product/3';

  @override
  String get open => 'فتح';

  @override
  String get invalidCode => 'صيغة رمز غير صالحة';

  @override
  String get cameraPermissionDenied => 'تم رفض إذن الكاميرا';

  @override
  String get cameraPermissionMessage =>
      'يحتاج هذا التطبيق إلى الوصول إلى الكاميرا لمسح رموز الاستجابة السريعة.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get brand => 'العلامة التجارية';

  @override
  String get category => 'الفئة';

  @override
  String get rating => 'التقييم';

  @override
  String get price => 'السعر';

  @override
  String get stock => 'متوفر';

  @override
  String get addToFavourites => 'إضافة إلى المفضلة';

  @override
  String get removeFromFavourites => 'إزالة من المفضلة';

  @override
  String get noProducts => 'لم يتم العثور على منتجات';

  @override
  String get pullToRefresh => 'اسحب للتحديث';

  @override
  String get scannerTitle => 'مسح رمز QR';

  @override
  String get pointCamera => 'وجّه الكاميرا نحو رمز QR';

  @override
  String get noBrand => 'لا توجد علامة تجارية';
}
