import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('fa'),
    Locale('en'),
  ];

  /// نام اپلیکیشن
  ///
  /// In fa, this message translates to:
  /// **'نات‌تیک'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In fa, this message translates to:
  /// **'به نات‌تیک خوش آمدید'**
  String get onboardingTitle;

  /// No description provided for @onboardingDesc.
  ///
  /// In fa, this message translates to:
  /// **'برای ذخیره‌سازی آفلاین و امن نوتیفیکیشن‌ها، نیاز به دسترسی خواندن اعلانات داریم.'**
  String get onboardingDesc;

  /// No description provided for @grantPermission.
  ///
  /// In fa, this message translates to:
  /// **'اعطای دسترسی'**
  String get grantPermission;

  /// No description provided for @onboardingReturnHint.
  ///
  /// In fa, this message translates to:
  /// **'بعد از فعال‌سازی دسترسی، به برنامه برگردید.'**
  String get onboardingReturnHint;

  /// No description provided for @historyTitle.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه'**
  String get historyTitle;

  /// No description provided for @emptyHistory.
  ///
  /// In fa, this message translates to:
  /// **'هیچ نوتیفیکیشنی یافت نشد.'**
  String get emptyHistory;

  /// No description provided for @settingsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settingsTitle;

  /// No description provided for @searchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجو...'**
  String get searchHint;

  /// No description provided for @all.
  ///
  /// In fa, this message translates to:
  /// **'همه'**
  String get all;

  /// No description provided for @apps.
  ///
  /// In fa, this message translates to:
  /// **'برنامه‌ها'**
  String get apps;

  /// No description provided for @people.
  ///
  /// In fa, this message translates to:
  /// **'اشخاص'**
  String get people;

  /// No description provided for @loadMore.
  ///
  /// In fa, this message translates to:
  /// **'بارگذاری بیشتر'**
  String get loadMore;

  /// No description provided for @retry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش مجدد'**
  String get retry;

  /// No description provided for @appsTitle.
  ///
  /// In fa, this message translates to:
  /// **'برنامه‌ها'**
  String get appsTitle;

  /// No description provided for @emptyApps.
  ///
  /// In fa, this message translates to:
  /// **'هنوز هیچ برنامه‌ای ثبت نشده است.'**
  String get emptyApps;

  /// No description provided for @generalSettings.
  ///
  /// In fa, this message translates to:
  /// **'عمومی'**
  String get generalSettings;

  /// No description provided for @language.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In fa, this message translates to:
  /// **'پوسته'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In fa, this message translates to:
  /// **'سیستم'**
  String get themeSystem;

  /// No description provided for @dataAndStorage.
  ///
  /// In fa, this message translates to:
  /// **'داده‌ها و حافظه'**
  String get dataAndStorage;

  /// No description provided for @autoCleanup.
  ///
  /// In fa, this message translates to:
  /// **'پاکسازی خودکار'**
  String get autoCleanup;

  /// No description provided for @exportTitle.
  ///
  /// In fa, this message translates to:
  /// **'خروجی گرفتن'**
  String get exportTitle;

  /// No description provided for @exportDesc.
  ///
  /// In fa, this message translates to:
  /// **'دریافت فایل جیسون'**
  String get exportDesc;

  /// No description provided for @backupTitle.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبان و بازگردانی'**
  String get backupTitle;

  /// No description provided for @backupDesc.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره پایگاه داده در فایل زیپ'**
  String get backupDesc;

  /// No description provided for @logsTitle.
  ///
  /// In fa, this message translates to:
  /// **'دریافت فایل‌های لاگ'**
  String get logsTitle;

  /// No description provided for @logsDesc.
  ///
  /// In fa, this message translates to:
  /// **'اشتراک‌گذاری گزارش خطاهای سیستم'**
  String get logsDesc;

  /// No description provided for @noLogsAvailable.
  ///
  /// In fa, this message translates to:
  /// **'هیچ لاگی ثبت نشده است.'**
  String get noLogsAvailable;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب زبان'**
  String get selectLanguageTitle;

  /// No description provided for @persian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get persian;

  /// No description provided for @english.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @light.
  ///
  /// In fa, this message translates to:
  /// **'روشن'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In fa, this message translates to:
  /// **'تاریک'**
  String get dark;

  /// No description provided for @emptyFilteredHistory.
  ///
  /// In fa, this message translates to:
  /// **'هیچ نوتیفیکیشنی در این دسته‌بندی یافت نشد.'**
  String get emptyFilteredHistory;

  /// No description provided for @noRevisionsFound.
  ///
  /// In fa, this message translates to:
  /// **'هیچ تغییراتی یافت نشد.'**
  String get noRevisionsFound;

  /// No description provided for @error.
  ///
  /// In fa, this message translates to:
  /// **'خطا'**
  String get error;

  /// No description provided for @senderLabel.
  ///
  /// In fa, this message translates to:
  /// **'فرستنده'**
  String get senderLabel;

  /// No description provided for @groupLabel.
  ///
  /// In fa, this message translates to:
  /// **'گروه'**
  String get groupLabel;

  /// No description provided for @historyLoadError.
  ///
  /// In fa, this message translates to:
  /// **'خطا در دریافت اطلاعات'**
  String get historyLoadError;

  /// No description provided for @privacyTagline.
  ///
  /// In fa, this message translates to:
  /// **'مبتنی بر حریم خصوصی و کاملاً آفلاین'**
  String get privacyTagline;

  /// No description provided for @appVersion.
  ///
  /// In fa, this message translates to:
  /// **'نسخه {version}'**
  String appVersion(String version);

  /// No description provided for @unknownApp.
  ///
  /// In fa, this message translates to:
  /// **'ناشناس'**
  String get unknownApp;

  /// No description provided for @hasImageBadge.
  ///
  /// In fa, this message translates to:
  /// **'تصویر'**
  String get hasImageBadge;

  /// No description provided for @notificationImage.
  ///
  /// In fa, this message translates to:
  /// **'تصویر اعلان'**
  String get notificationImage;

  /// No description provided for @retentionDays7.
  ///
  /// In fa, this message translates to:
  /// **'۷ روز'**
  String get retentionDays7;

  /// No description provided for @retentionDays30.
  ///
  /// In fa, this message translates to:
  /// **'۳۰ روز'**
  String get retentionDays30;

  /// No description provided for @retentionDays90.
  ///
  /// In fa, this message translates to:
  /// **'۹۰ روز'**
  String get retentionDays90;

  /// No description provided for @retentionForever.
  ///
  /// In fa, this message translates to:
  /// **'برای همیشه'**
  String get retentionForever;

  /// No description provided for @aboutTitle.
  ///
  /// In fa, this message translates to:
  /// **'درباره نات‌تیک'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'حریم خصوصی، سایت و کد منبع'**
  String get aboutSubtitle;

  /// No description provided for @aboutHeroTitle.
  ///
  /// In fa, this message translates to:
  /// **'نات‌تیک'**
  String get aboutHeroTitle;

  /// No description provided for @aboutHeroBody.
  ///
  /// In fa, this message translates to:
  /// **'نات‌تیک تاریخچه اعلان‌ها را فقط روی دستگاه شما ذخیره می‌کند؛ بدون اینترنت، بدون سرور و بدون تحلیل‌گر.'**
  String get aboutHeroBody;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In fa, this message translates to:
  /// **'حریم خصوصی'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyBody.
  ///
  /// In fa, this message translates to:
  /// **'برنامه فقط اعلان‌هایی را نگه می‌دارد که اندروید بعد از فعال شدن دسترسی اعلان در اختیارش بگذارد. اعلان‌های قبلی یا موارد پنهان‌شده توسط سیستم بازیابی نمی‌شوند.'**
  String get aboutPrivacyBody;

  /// No description provided for @website.
  ///
  /// In fa, this message translates to:
  /// **'سایت'**
  String get website;

  /// No description provided for @github.
  ///
  /// In fa, this message translates to:
  /// **'گیت‌هاب'**
  String get github;

  /// No description provided for @openLinkError.
  ///
  /// In fa, this message translates to:
  /// **'باز کردن لینک ممکن نبود.'**
  String get openLinkError;
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
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
