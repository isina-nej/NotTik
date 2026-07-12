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
  String get historyTitle => 'تاریخچه';

  @override
  String get emptyHistory => 'هیچ نوتیفیکیشنی یافت نشد.';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get searchHint => 'جستجو...';

  @override
  String get all => 'همه';

  @override
  String get apps => 'برنامه‌ها';

  @override
  String get people => 'اشخاص';

  @override
  String get loadMore => 'بارگذاری بیشتر';

  @override
  String get retry => 'تلاش مجدد';

  @override
  String get appsTitle => 'برنامه‌ها';

  @override
  String get emptyApps => 'هنوز هیچ برنامه‌ای ثبت نشده است.';

  @override
  String get generalSettings => 'عمومی';

  @override
  String get language => 'زبان';

  @override
  String get theme => 'پوسته';

  @override
  String get themeSystem => 'سیستم';

  @override
  String get dataAndStorage => 'داده‌ها و حافظه';

  @override
  String get autoCleanup => 'پاکسازی خودکار';

  @override
  String get exportTitle => 'خروجی گرفتن';

  @override
  String get exportDesc => 'دریافت فایل جیسون';

  @override
  String get backupTitle => 'پشتیبان و بازگردانی';

  @override
  String get backupDesc => 'ذخیره پایگاه داده در فایل زیپ';

  @override
  String get logsTitle => 'دریافت فایل‌های لاگ';

  @override
  String get logsDesc => 'اشتراک‌گذاری گزارش خطاهای سیستم';

  @override
  String get noLogsAvailable => 'هیچ لاگی ثبت نشده است.';

  @override
  String get selectLanguageTitle => 'انتخاب زبان';

  @override
  String get persian => 'فارسی';

  @override
  String get english => 'English';

  @override
  String get light => 'روشن';

  @override
  String get dark => 'تاریک';

  @override
  String get emptyFilteredHistory =>
      'هیچ نوتیفیکیشنی در این دسته‌بندی یافت نشد.';

  @override
  String get noRevisionsFound => 'هیچ تغییراتی یافت نشد.';

  @override
  String get error => 'خطا';

  @override
  String get senderLabel => 'فرستنده';

  @override
  String get groupLabel => 'گروه';

  @override
  String get historyLoadError => 'خطا در دریافت اطلاعات';

  @override
  String get privacyTagline => 'مبتنی بر حریم خصوصی و کاملاً آفلاین';

  @override
  String appVersion(String version) {
    return 'نسخه $version';
  }

  @override
  String get unknownApp => 'ناشناس';

  @override
  String get retentionDays7 => '۷ روز';

  @override
  String get retentionDays30 => '۳۰ روز';

  @override
  String get retentionDays90 => '۹۰ روز';

  @override
  String get retentionForever => 'برای همیشه';
}
