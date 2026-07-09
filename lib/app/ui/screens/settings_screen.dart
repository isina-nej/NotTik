import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/utils/logger.dart';
import 'package:share_plus/share_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'), // Localize later
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GlassmorphismCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عمومی', // Localize
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('زبان'),
                  subtitle: const Text('فارسی'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Language switcher dialog
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('پوسته (تم)'),
                  subtitle: const Text('سیستم'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Theme switcher dialog
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
                  'داده‌ها و حافظه', // Localize
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.auto_delete_outlined),
                  title: const Text('پاکسازی خودکار (Retention)'),
                  subtitle: const Text('۳۰ روز'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Retention days dialog
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('خروجی گرفتن (Export)'),
                  subtitle: const Text('دریافت فایل JSON/CSV'),
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('json');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('بکاپ و بازگردانی'),
                  subtitle: const Text('ذخیره دیتابیس در فایل ZIP'),
                  onTap: () {
                    final bridge = NotificationBridge();
                    bridge.exportData('zip');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('دریافت فایل‌های لاگ'),
                  subtitle: const Text('اشتراک‌گذاری گزارش خطاهای سیستم'),
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
}
