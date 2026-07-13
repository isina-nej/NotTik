import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:nottik/app/bridge/pigeon.dart';
import 'package:nottik/app/data/providers/history_provider.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

/// Resolves Android filesDir/app_icons path without hardcoding user id.
final appIconsDirProvider = FutureProvider<Directory?>((ref) async {
  try {
    final docs = await getApplicationDocumentsDirectory();
    // documents = .../app_flutter ; filesDir = .../files
    final filesDir = Directory('${docs.parent.path}/files/app_icons');
    if (await filesDir.exists()) return filesDir;
    return filesDir;
  } catch (_) {
    return null;
  }
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(notificationHistoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh.withValues(
                      alpha: 0.7,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: scheme.primary, width: 1.2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    ref
                        .read(notificationHistoryProvider.notifier)
                        .setSearchQuery(value);
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      ref
                          .read(notificationHistoryProvider.notifier)
                          .setSearchQuery(null);
                    }
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                // Light: black selected. Dark: white selected.
                labelColor: isDark ? Colors.white : Colors.black,
                unselectedLabelColor: scheme.onSurfaceVariant,
                indicatorColor: isDark ? Colors.white : Colors.black,
                indicatorWeight: 2.5,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: l10n.all),
                  Tab(text: l10n.apps),
                  Tab(text: l10n.people),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Builder(builder: (_) => _buildListView(historyAsync, l10n)),
          Builder(
            builder: (_) =>
                _buildListView(historyAsync, l10n, filterType: 'apps'),
          ),
          Builder(
            builder: (_) =>
                _buildListView(historyAsync, l10n, filterType: 'people'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(
    AsyncValue historyAsync,
    AppLocalizations l10n, {
    String? filterType,
  }) {
    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DepthEmptyIcon(
                  icon: Icons.notifications_off_rounded,
                  size: 88,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.emptyHistory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        var filteredRecords = (records as List<NativeNotificationRecord>)
            .toList();
        if (filterType == 'people') {
          filteredRecords = filteredRecords
              .where((r) => (r.senderName?.trim().isNotEmpty ?? false))
              .toList();
        } else if (filterType == 'apps') {
          filteredRecords = filteredRecords
              .where((r) => !(r.senderName?.trim().isNotEmpty ?? false))
              .toList();
        }

        if (filteredRecords.isEmpty) {
          return Center(child: Text(l10n.emptyFilteredHistory));
        }

        final canLoadMore = filterType == null && records.length >= 20;

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(notificationHistoryProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 100),
            itemCount: filteredRecords.length + (canLoadMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredRecords.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: FilledButton.tonal(
                      onPressed: () => ref
                          .read(notificationHistoryProvider.notifier)
                          .loadMore(),
                      child: Text(l10n.loadMore),
                    ),
                  ),
                );
              }
              return _HistoryTile(record: filteredRecords[index], l10n: l10n);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DepthEmptyIcon(icon: Icons.error_outline_rounded, size: 80),
            const SizedBox(height: 16),
            Text(
              l10n.historyLoadError,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () =>
                  ref.read(notificationHistoryProvider.notifier).refresh(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final NativeNotificationRecord record;
  final AppLocalizations l10n;

  const _HistoryTile({required this.record, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasMedia = record.mediaPath?.trim().isNotEmpty ?? false;
    final hasPerson = record.senderName?.trim().isNotEmpty ?? false;

    final titleText = hasPerson
        ? record.senderName!.trim()
        : (record.latestTitle?.trim().isNotEmpty == true
              ? record.latestTitle!.trim()
              : (record.appName ?? record.packageName ?? l10n.unknownApp));

    final bodyText = record.latestText?.trim() ?? '';
    final appLine = record.appName ?? record.packageName ?? '';
    final timeFormatted = DateFormat.Hm().format(
      DateTime.fromMillisecondsSinceEpoch(
        record.lastUpdateTime ?? record.postTime ?? 0,
      ),
    );
    final firstLetter = titleText.isNotEmpty
        ? titleText.characters.first.toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/detail', extra: record),
        child: DepthListCard(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 7, 8, 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AppAvatar(path: record.appIconPath, letter: firstLetter),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeFormatted,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    if (bodyText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        bodyText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.82),
                          height: 1.2,
                        ),
                      ),
                    ],
                    if (appLine.isNotEmpty || hasMedia) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (appLine.isNotEmpty)
                            Flexible(
                              child: Text(
                                appLine,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          if (appLine.isNotEmpty && hasMedia)
                            const SizedBox(width: 6),
                          if (hasMedia) _ImageBadge(label: l10n.hasImageBadge),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final String label;

  const _ImageBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_rounded, size: 11, color: scheme.tertiary),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: scheme.tertiary,
              fontFamily: 'Vazirmatn',
            ),
          ),
        ],
      ),
    );
  }
}

class _AppAvatar extends StatelessWidget {
  final String? path;
  final String letter;

  const _AppAvatar({required this.path, required this.letter});

  @override
  Widget build(BuildContext context) {
    return DepthAppBadge(
      path: path,
      letter: letter,
      size: 34,
      accent: Theme.of(context).colorScheme.primary,
    );
  }
}
