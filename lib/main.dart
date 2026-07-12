import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/data/providers/locale_provider.dart';
import 'package:nottik/app/data/providers/theme_provider.dart';
import 'package:nottik/app/routing/app_router.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/app/utils/logger.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/l10n/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.init();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Flutter UI Error',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Unhandled Async Error', error: error, stackTrace: stack);
    return true;
  };

  runApp(const ProviderScope(child: NotTikApp()));
}

class NotTikApp extends ConsumerWidget {
  const NotTikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    // Initialize l10n
    initL10n(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
