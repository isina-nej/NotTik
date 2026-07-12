import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nottik/l10n/generated/app_localizations.dart';
import 'package:nottik/app/data/providers/history_provider.dart';
import 'package:intl/intl.dart';
import 'package:device_apps/device_apps.dart';
import 'package:nottik/app/ui/theme/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Here we could implement API filtering based on category
        // For MVP, we'll just log or handle basic client-side sorting if needed.
        // E.g., Index 0 = All, 1 = Apps, 2 = People
      }
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  onSubmitted: (value) {
                    ref.read(notificationHistoryProvider.notifier).setSearchQuery(value);
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      ref.read(notificationHistoryProvider.notifier).setSearchQuery(null);
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

  Widget _buildListView(AsyncValue historyAsync, AppLocalizations l10n, {String? filterType}) {
    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey),
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

        // Apply local filtering based on tab
        var filteredRecords = records;
        if (filterType == 'people') {
          filteredRecords = records.where((r) => r.senderName != null).toList();
        } else if (filterType == 'apps') {
          // Simplistic logic for demonstration: prioritize items with no senderName as general app notifications
          filteredRecords = records.where((r) => r.senderName == null).toList();
        }

        if (filteredRecords.isEmpty) {
          return Center(child: Text(l10n.emptyFilteredHistory));
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(notificationHistoryProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredRecords.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredRecords.length) {
                // Only show load more if we are on the 'All' tab or if we didn't filter heavily. 
                // For MVP: keeping it simple.
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: FilledButton.tonal(
                      onPressed: () => ref.read(notificationHistoryProvider.notifier).loadMore(),
                      child: Text(l10n.loadMore),
                    ),
                  ),
                );
              }
              
              final record = filteredRecords[index];
              final titleText = record.senderName != null 
                  ? record.senderName!
                  : (record.appName ?? record.packageName ?? 'Unknown');
                  
              final appSubtitle = record.senderName != null 
                  ? (record.appName ?? record.packageName ?? '')
                  : '';
                  
              final timeFormatted = DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(record.postTime ?? 0));
              final firstLetter = titleText.isNotEmpty ? titleText[0].toUpperCase() : '?';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: GlassmorphismCard(
                  padding: const EdgeInsets.all(0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: FutureBuilder<Application?>(
                      future: record.packageName != null ? DeviceApps.getApp(record.packageName!, true) : Future.value(null),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data is ApplicationWithIcon) {
                          return CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: MemoryImage((snapshot.data as ApplicationWithIcon).icon),
                          );
                        }
                        return CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            firstLetter,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        );
                      },
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeFormatted,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          )
                        : null,
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
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text('خطا در دریافت اطلاعات', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.read(notificationHistoryProvider.notifier).refresh(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}