import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/data/providers/history_provider.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:device_apps/device_apps.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(notificationHistoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
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
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
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
          _buildListView(historyAsync, l10n),
          _buildListView(historyAsync, l10n, filterType: 'apps'),
          _buildListView(historyAsync, l10n, filterType: 'people'),
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
                Icon(
                  Icons.notifications_off_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.emptyHistory,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }

        var filteredRecords = records;
        if (filterType == 'people') {
          filteredRecords =
              records.where((r) => r.senderName != null).toList();
        } else if (filterType == 'apps') {
          filteredRecords =
              records.where((r) => r.senderName == null).toList();
        }

        if (filteredRecords.isEmpty) {
          return Center(child: Text(l10n.emptyFilteredHistory));
        }

        // Page size is 20; hide load-more when last page was short.
        final canLoadMore = filterType == null && records.length >= 20;

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(notificationHistoryProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
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

              final record = filteredRecords[index];
              final titleText = record.senderName != null
                  ? record.senderName!
                  : (record.appName ??
                      record.packageName ??
                      l10n.unknownApp);

              final appSubtitle = record.senderName != null
                  ? (record.appName ?? record.packageName ?? '')
                  : '';

              final timeFormatted = DateFormat.Hm().format(
                DateTime.fromMillisecondsSinceEpoch(record.postTime ?? 0),
              );
              final firstLetter =
                  titleText.isNotEmpty ? titleText[0].toUpperCase() : '?';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassmorphismCard(
                  blur: 10,
                  padding: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: FutureBuilder<Application?>(
                      future: record.packageName != null
                          ? DeviceApps.getApp(record.packageName!, true)
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
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeFormatted,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                    subtitle: appSubtitle.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              appSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : null,
                    trailing: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      context.push('/detail', extra: record);
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.historyLoadError,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
