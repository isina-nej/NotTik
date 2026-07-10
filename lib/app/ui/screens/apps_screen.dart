import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/data/providers/apps_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';

class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsManagementProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appsTitle),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(child: Text(l10n.emptyApps));
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
                      ref.read(appsManagementProvider.notifier)
                          .toggleLogging(app.packageName!, app.isLoggingEnabled ?? true);
                    },
                    secondary: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Icon(Icons.android, 
                          color: Theme.of(context).colorScheme.onSecondaryContainer),
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
