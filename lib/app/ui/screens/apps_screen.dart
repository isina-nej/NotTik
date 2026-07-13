import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/data/providers/apps_provider.dart';
import 'package:nottik/app/ui/screens/history_screen.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';

class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsManagementProvider);
    final iconsDir = ref.watch(appIconsDirProvider).asData?.value;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.appsTitle)),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const DepthEmptyIcon(icon: Icons.apps_rounded, size: 88),
                    const SizedBox(height: 20),
                    Text(
                      l10n.emptyApps,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = [...apps]
            ..sort((a, b) {
              final an = (a.appName ?? a.packageName ?? '').toLowerCase();
              final bn = (b.appName ?? b.packageName ?? '').toLowerCase();
              return an.compareTo(bn);
            });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(appsManagementProvider);
              await ref.read(appsManagementProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 100),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final app = sorted[index];
                final package = app.packageName ?? '';
                final iconPath = (iconsDir != null && package.isNotEmpty)
                    ? '${iconsDir.path}/${package.replaceAll('.', '_')}.png'
                    : null;
                return _AppTile(app: app, l10n: l10n, iconPath: iconPath);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.error}: $err')),
      ),
    );
  }
}

class _AppTile extends ConsumerWidget {
  final NativeAppMetadata app;
  final AppLocalizations l10n;
  final String? iconPath;

  const _AppTile({
    required this.app,
    required this.l10n,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final name = app.appName ?? app.packageName ?? l10n.unknownApp;
    final firstLetter = name.isNotEmpty
        ? name.characters.first.toUpperCase()
        : '?';
    final package = app.packageName ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DepthListCard(
        padding: const EdgeInsets.all(4),
        child: SwitchListTile(
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            package,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          value: app.isLoggingEnabled ?? true,
          onChanged: package.isEmpty
              ? null
              : (_) {
                  ref
                      .read(appsManagementProvider.notifier)
                      .toggleLogging(package, app.isLoggingEnabled ?? true);
                },
          secondary: DepthAppBadge(
            path: iconPath,
            letter: firstLetter,
            size: 44,
            accent: scheme.secondary,
          ),
        ),
      ),
    );
  }
}
