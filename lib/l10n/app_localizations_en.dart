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
  String get historyTitle => 'Notification History';

  @override
  String get emptyHistory => 'No notifications captured yet.';

  @override
  String get settingsTitle => 'Settings';
}
