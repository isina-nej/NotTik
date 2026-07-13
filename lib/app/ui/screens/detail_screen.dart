import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/data/providers/detail_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';

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
    final appTitle = record.appName ?? record.packageName ?? l10n.unknownApp;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppAmbientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DepthAppBadge(
                  path: record.appIconPath,
                  letter: _firstLetter(appTitle),
                  size: 32,
                  accent: scheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(appTitle, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 10),
                child: GlassmorphismCard(
                  blur: 10,
                  depth: 0.75,
                  padding: const EdgeInsetsDirectional.all(14),
                  child: Row(
                    children: [
                      DepthAppBadge(
                        path: record.appIconPath,
                        letter: _firstLetter(appTitle),
                        size: 52,
                        accent: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (_clean(record.packageName).isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                record.packageName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                            if (_clean(record.senderName).isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _MetaPill(
                                icon: Icons.person_rounded,
                                text:
                                    '${l10n.senderLabel}: ${record.senderName}',
                              ),
                            ],
                            if (_clean(record.groupKey).isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _MetaPill(
                                icon: Icons.layers_rounded,
                                text: '${l10n.groupLabel}: ${record.groupKey}',
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
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        16,
                        2,
                        16,
                        24,
                      ),
                      itemCount: revisions.length,
                      itemBuilder: (context, index) {
                        return _RevisionCard(
                          revision: revisions[index],
                          l10n: l10n,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('${l10n.error}: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _clean(String? value) => value?.trim() ?? '';

  static String _firstLetter(String value) {
    final clean = value.trim();
    return clean.isEmpty ? '?' : clean.characters.first.toUpperCase();
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisionCard extends StatelessWidget {
  final NativeNotificationRevision revision;
  final AppLocalizations l10n;

  const _RevisionCard({required this.revision, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = DateTime.fromMillisecondsSinceEpoch(
      revision.captureTimestamp ?? 0,
    );
    final timeStr = DateFormat.Hms().format(date);
    final dateStr = DateFormat.yMd().format(date);
    final mediaPath = revision.mediaPath;
    final hasMedia = mediaPath?.trim().isNotEmpty ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: GlassmorphismCard(
        blur: 10,
        depth: 0.7,
        padding: const EdgeInsetsDirectional.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    timeStr,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (hasMedia) ...[
              const SizedBox(height: 10),
              Text(
                l10n.notificationImage,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(mediaPath!.trim()),
                  width: double.infinity,
                  cacheWidth: MediaQuery.sizeOf(context).width.ceil() * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: scheme.surfaceContainerHigh,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 46,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
            if (_clean(revision.title).isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                revision.title!.trim(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
            if (_clean(revision.text).isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                revision.text!.trim(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.45),
              ),
            ],
            if (_clean(revision.bigText).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                revision.bigText!.trim(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (revision.progressMax != null && revision.progressMax! > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (revision.progressIndeterminate == true)
                    ? null
                    : (revision.progressValue?.toDouble() ?? 0) /
                          (revision.progressMax?.toDouble() ?? 1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _clean(String? value) => value?.trim() ?? '';
}
