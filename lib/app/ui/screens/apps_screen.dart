import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import 'package:nottik/app/data/providers/apps_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';

class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsManagementProvider);
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appsTitle),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apps_outlined,
                    size: 48,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.emptyApps,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              final name =
                  app.appName ?? app.packageName ?? l10n.unknownApp;
              final firstLetter =
                  name.isNotEmpty ? name[0].toUpperCase() : '?';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassmorphismCard(
                  blur: 10,
                  padding: const EdgeInsets.all(4),
                  child: SwitchListTile(
                    title: Text(name),
                    subtitle: Text(
                      app.packageName ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    value: app.isLoggingEnabled ?? true,
                    onChanged: (val) {
                      ref
                          .read(appsManagementProvider.notifier)
                          .toggleLogging(
                            app.packageName!,
                            app.isLoggingEnabled ?? true,
                          );
                    },
                    secondary: FutureBuilder<Application?>(
                      future: app.packageName != null
                          ? DeviceApps.getApp(app.packageName!, true)
                          : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data is ApplicationWithIcon) {
                          return CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: MemoryImage(
                              (snapshot.data as ApplicationWithIcon).icon,
                            ),
                          );
                        }
                        return CircleAvatar(
                          backgroundColor: scheme.secondaryContainer,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.error}: $err')),
      ),
    );
  }
}
