import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/utils/logger.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/data/providers/theme_provider.dart';
import 'package:nottik/app/data/providers/locale_provider.dart';
import 'package:nottik/app/data/providers/retention_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);
    final retention = ref.watch(retentionSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16.0,
              bottom: 8.0,
              end: 16.0,
            ),
            child: Text(
              l10n.generalSettings.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.language,
                  iconColor: Colors.blue,
                  title: l10n.language,
                  subtitle:
                      locale.languageCode == 'fa' ? l10n.persian : l10n.english,
                  onTap: () =>
                      _showLanguageDialog(context, ref, locale, l10n),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.dark_mode,
                  iconColor: Colors.deepPurple,
                  title: l10n.theme,
                  subtitle: _getThemeText(themeMode, l10n),
                  onTap: () =>
                      _showThemeDialog(context, ref, themeMode, l10n),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16.0,
              bottom: 8.0,
              end: 16.0,
            ),
            child: Text(
              l10n.dataAndStorage.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          GlassmorphismCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingsTile(
                  context: context,
                  icon: Icons.auto_delete,
                  iconColor: Colors.orange,
                  title: l10n.autoCleanup,
                  subtitle: _getRetentionText(retention, l10n),
                  onTap: () =>
                      _showRetentionDialog(context, ref, retention, l10n),
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.file_download,
                  iconColor: Colors.green,
                  title: l10n.exportTitle,
                  subtitle: l10n.exportDesc,
                  onTap: () {
                    NotificationBridge().exportData('json');
                  },
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.archive,
                  iconColor: Colors.red,
                  title: l10n.backupTitle,
                  subtitle: l10n.backupDesc,
                  onTap: () {
                    NotificationBridge().exportData('zip');
                  },
                ),
                Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.4),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.bug_report,
                  iconColor: Colors.teal,
                  title: l10n.logsTitle,
                  subtitle: l10n.logsDesc,
                  onTap: () async {
                    try {
                      final files = await AppLogger.getLogFiles();
                      if (files.isNotEmpty && context.mounted) {
                        final xFiles =
                            files.map((f) => XFile(f.path)).toList();
                        await SharePlus.instance.share(
                          ShareParams(files: xFiles, text: 'NotTik Debug Logs'),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.noLogsAvailable)),
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
              '${l10n.appVersion('1.0.0')}\n${l10n.privacyTagline}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left
            : Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  String _getThemeText(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeSystem;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguageTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text(l10n.persian),
                value: 'fa',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref
                      .read(appLocaleProvider.notifier)
                      .setLocale(Locale(value!));
                  Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<String>(
                title: Text(l10n.english),
                value: 'en',
                groupValue: currentLocale.languageCode,
                onChanged: (value) {
                  ref
                      .read(appLocaleProvider.notifier)
                      .setLocale(Locale(value!));
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
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
                  Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.light),
                value: ThemeMode.light,
                groupValue: currentMode,
                onChanged: (value) {
                  ref.read(appThemeModeProvider.notifier).setTheme(value!);
                  Navigator.pop(dialogContext);
                },
              ),
              RadioListTile<ThemeMode>(
                title: Text(l10n.dark),
                value: ThemeMode.dark,
                groupValue: currentMode,
                onChanged: (value) {
                  ref.read(appThemeModeProvider.notifier).setTheme(value!);
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getRetentionText(RetentionPeriod period, AppLocalizations l10n) {
    switch (period) {
      case RetentionPeriod.days7:
        return l10n.retentionDays7;
      case RetentionPeriod.days30:
        return l10n.retentionDays30;
      case RetentionPeriod.days90:
        return l10n.retentionDays90;
      case RetentionPeriod.forever:
        return l10n.retentionForever;
    }
  }

  void _showRetentionDialog(
    BuildContext context,
    WidgetRef ref,
    RetentionPeriod currentPeriod,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.autoCleanup),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: RetentionPeriod.values.map((period) {
              return RadioListTile<RetentionPeriod>(
                title: Text(_getRetentionText(period, l10n)),
                value: period,
                groupValue: currentPeriod,
                onChanged: (value) {
                  ref.read(retentionSettingsProvider.notifier).set(value!);
                  Navigator.pop(dialogContext);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
