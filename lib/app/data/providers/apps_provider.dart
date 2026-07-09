import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/bridge/pigeon.dart';

part 'apps_provider.g.dart';

@riverpod
class AppsManagement extends _$AppsManagement {
  final NotificationBridge _bridge = NotificationBridge();

  @override
  FutureOr<List<NativeAppMetadata>> build() async {
    return _fetchAllMetadata();
  }

  Future<List<NativeAppMetadata>> _fetchAllMetadata() async {
    final metadata = await _bridge.getAllAppMetadata();
    return metadata.whereType<NativeAppMetadata>().toList();
  }

  Future<void> toggleLogging(String packageName, bool currentStatus) async {
    await _bridge.setAppLoggingStatus(packageName, !currentStatus);
    // Refresh the list
    state = const AsyncLoading();
    try {
      final items = await _fetchAllMetadata();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
