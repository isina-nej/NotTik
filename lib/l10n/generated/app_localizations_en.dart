// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NotTik';

  @override
  String get onboardingTitle => 'Welcome to NotTik';

  @override
  String get onboardingDesc =>
      'To securely save notifications offline, we need Notification Access permission.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get historyTitle => 'History';

  @override
  String get emptyHistory => 'No notifications found.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get searchHint => 'Search...';

  @override
  String get all => 'All';

  @override
  String get apps => 'Apps';

  @override
  String get people => 'People';

  @override
  String get loadMore => 'Load More';

  @override
  String get retry => 'Retry';

  @override
  String get appsTitle => 'Apps';

  @override
  String get emptyApps => 'No apps registered yet.';

  @override
  String get generalSettings => 'General';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get autoCleanup => 'Auto Cleanup';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportDesc => 'Get JSON file';

  @override
  String get backupTitle => 'Backup & Restore';

  @override
  String get backupDesc => 'Save DB as ZIP';

  @override
  String get logsTitle => 'Get Log Files';

  @override
  String get logsDesc => 'Share system error reports';

  @override
  String get noLogsAvailable => 'No logs available.';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get persian => 'Persian';

  @override
  String get english => 'English';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get emptyFilteredHistory =>
      'No matching notifications in this category.';

  @override
  String get noRevisionsFound => 'No revisions found.';

  @override
  String get error => 'Error';

  @override
  String get senderLabel => 'Sender';

  @override
  String get groupLabel => 'Group';

  @override
  String get historyLoadError => 'Failed to load data';

  @override
  String get privacyTagline => 'Privacy-first and fully offline';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get unknownApp => 'Unknown';

  @override
  String get retentionDays7 => '7 days';

  @override
  String get retentionDays30 => '30 days';

  @override
  String get retentionDays90 => '90 days';

  @override
  String get retentionForever => 'Forever';
}
