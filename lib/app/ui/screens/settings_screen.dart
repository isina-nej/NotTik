import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/utils/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/data/providers/theme_provider.dart';
import 'package:nottik/app/data/providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GlassmorphismCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.generalSettings,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  subtitle: Text(locale.languageCode == 'fa' ? 'فارسی' : 'English'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showLanguageDialog(context, ref, locale);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: Text(l10n.theme),
                  subtitle: Text(_getThemeText(themeMode, l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showThemeDialog(context, ref, themeMode, l10n);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          GlassmorphismCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dataAndStorage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.auto_delete_outlined),
                  title: Text(l10n.autoCleanup),
                  subtitle: const Text('۳۰ روز'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Retention days dialog
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l10n.exportTitle),
                  subtitle: Text(l10n.exportDesc),
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('json');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(l10n.backupTitle),
                  subtitle: Text(l10n.backupDesc),
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('zip');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(l10n.logsTitle),
                  subtitle: Text(l10n.logsDesc),
                  onTap: () async {
                    try {
                      final files = await AppLogger.getLogFiles();
                      if (files.isNotEmpty && context.mounted) {
                        final xFiles = files.map((f) => XFile(f.path)).toList();
                        await SharePlus.instance.share(ShareParams(files: xFiles, text: 'NotTik Debug Logs'));
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('هیچ لاگی ثبت نشده است.')),
                        );
                      }
                    } catch (e) {
                      AppLogger.error('Share logs error', error: e);
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Center(
            child: Text(
              'NotTik v1.0.0\nمبتنی بر حریم خصوصی و کاملاً آفلاین',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeText(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return 'روشن';
      case ThemeMode.dark:
        return 'تاریک';
    }
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('انتخاب زبان / Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('فارسی'),
                value: 'fa',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref.read(appLocaleProvider.notifier).setLocale(Locale(value!));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref.read(appLocaleProvider.notifier).setLocale(Locale(value!));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode currentMode, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.theme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: Text(l10n.themeSystem),
                value: ThemeMode.system,
                groupValue: currentMode,
                onChanged: (value) {
                  ref.read(appThemeModeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('روشن'),
                value: ThemeMode.light,
                groupValue: currentMode,
                onChanged: (value) {
                  ref.read(appThemeModeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('تاریک'),
                value: ThemeMode.dark,
                groupValue: currentMode,
                onChanged: (value) {
                  ref.read(appThemeModeProvider.notifier).setTheme(value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
