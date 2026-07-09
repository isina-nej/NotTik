// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'نات‌تیک';

  @override
  String get onboardingTitle => 'به نات‌تیک خوش آمدید';

  @override
  String get onboardingDesc =>
      'برای ذخیره‌سازی آفلاین و امن نوتیفیکیشن‌ها، نیاز به دسترسی خواندن اعلانات داریم.';

  @override
  String get grantPermission => 'اعطای دسترسی';

  @override
  String get historyTitle => 'تاریخچه اعلانات';

  @override
  String get emptyHistory => 'هنوز هیچ اعلانی دریافت نشده است.';

  @override
  String get settingsTitle => 'تنظیمات';
}
