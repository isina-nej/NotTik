import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_apps/device_apps.dart';
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/data/providers/detail_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart' hide TextDirection;

class DetailScreen extends ConsumerWidget {
  final NativeNotificationRecord record;

  const DetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final revisionsAsync = ref.watch(
      notificationDetailProvider(record.id ?? 0),
    );
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record.packageName != null)
              FutureBuilder<Application?>(
                future: DeviceApps.getApp(record.packageName!, true),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data is ApplicationWithIcon) {
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.transparent,
                        backgroundImage: MemoryImage(
                          (snapshot.data as ApplicationWithIcon).icon,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            Flexible(
              child: Text(
                record.appName ?? record.packageName ?? l10n.unknownApp,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GlassmorphismCard(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  FutureBuilder<Application?>(
                    future: record.packageName != null
                        ? DeviceApps.getApp(record.packageName!, true)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data is ApplicationWithIcon) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: MemoryImage(
                            (snapshot.data as ApplicationWithIcon).icon,
                          ),
                        );
                      }
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.notifications_active,
                          color: scheme.onPrimaryContainer,
                          size: 30,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.appName ??
                              record.packageName ??
                              l10n.unknownApp,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (record.senderName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.senderLabel}: ${record.senderName}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.primary),
                          ),
                        ],
                        if (record.groupKey != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.groupLabel}: ${record.groupKey}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: revisionsAsync.when(
              data: (revisions) {
                if (revisions.isEmpty) {
                  return Center(child: Text(l10n.noRevisionsFound));
                }
                return ListView.builder(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: revisions.length,
                  itemBuilder: (context, index) {
                    final rev = revisions[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      rev.captureTimestamp ?? 0,
                    );
                    final timeStr = DateFormat.Hms().format(date);
                    final dateStr = DateFormat.yMd().format(date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassmorphismCard(
                        blur: 10,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    timeStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (rev.mediaPath != null &&
                                File(rev.mediaPath!).existsSync()) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Image.file(
                                    File(rev.mediaPath!),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (rev.title != null && rev.title!.isNotEmpty)
                              Text(
                                rev.title!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            if (rev.text != null && rev.text!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(rev.text!),
                              ),
                            if (rev.bigText != null &&
                                rev.bigText!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  rev.bigText!,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            if (rev.progressMax != null &&
                                rev.progressMax! > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: LinearProgressIndicator(
                                  value: (rev.progressIndeterminate == true)
                                      ? null
                                      : (rev.progressValue?.toDouble() ?? 0) /
                                          (rev.progressMax?.toDouble() ?? 1),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('${l10n.error}: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
