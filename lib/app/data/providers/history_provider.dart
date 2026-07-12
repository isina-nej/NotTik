import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/bridge/pigeon.dart';

part 'history_provider.g.dart';

@riverpod
class NotificationHistory extends _$NotificationHistory {
  final NotificationBridge _bridge = NotificationBridge();

  String? _searchQuery;
  String? _category;

  @override
  FutureOr<List<NativeNotificationRecord>> build() async {
    return _fetchPage(0);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query?.isEmpty == true ? null : query;
    refresh();
  }

  void setCategory(String? category) {
    _category = category?.isEmpty == true ? null : category;
    refresh();
  }

  Future<List<NativeNotificationRecord>> _fetchPage(int offset) async {
    final result = await _bridge.getLatestHistory(
      offset,
      20,
      _searchQuery,
      _category,
    );
    return result.items?.whereType<NativeNotificationRecord>().toList() ?? [];
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError) return;

    final currentList = state.value ?? [];

    // Preserve previous data during pagination (no flash)
    state = const AsyncValue<List<NativeNotificationRecord>>.loading();

    try {
      final newItems = await _fetchPage(currentList.length);
      state = AsyncData([...currentList, ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final items = await _fetchPage(0);
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
