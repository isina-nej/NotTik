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
        title: Text(l10n.settingsTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
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
                  subtitle: locale.languageCode == 'fa' ? 'فارسی' : 'English',
                  onTap: () => _showLanguageDialog(context, ref, locale),
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.dark_mode,
                  iconColor: Colors.deepPurple,
                  title: l10n.theme,
                  subtitle: _getThemeText(themeMode, l10n),
                  onTap: () => _showThemeDialog(context, ref, themeMode, l10n),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
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
                  subtitle: '۳۰ روز',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.file_download,
                  iconColor: Colors.green,
                  title: l10n.exportTitle,
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('json');
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.archive,
                  iconColor: Colors.red,
                  title: l10n.backupTitle,
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('zip');
                  },
                ),
                const Divider(height: 1, indent: 56),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.bug_report,
                  iconColor: Colors.teal,
                  title: l10n.logsTitle,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
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
