import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/data/providers/apps_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';

class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsManagementProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('برنامه‌ها'), // Localize later
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Text('هنوز هیچ برنامه‌ای ثبت نشده است.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassmorphismCard(
                  padding: const EdgeInsets.all(4),
                  child: SwitchListTile(
                    title: Text(app.appName ?? app.packageName ?? 'Unknown'),
                    subtitle: Text(app.packageName ?? ''),
                    value: app.isLoggingEnabled ?? true,
                    onChanged: (val) {
                      ref
                          .read(appsManagementProvider.notifier)
                          .toggleLogging(
                            app.packageName!,
                            app.isLoggingEnabled ?? true,
                          );
                    },
                    secondary: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      child: Icon(
                        Icons.android,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطا: $err')),
      ),
    );
  }
}
