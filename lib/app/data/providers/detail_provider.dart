import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/bridge/pigeon.dart';

part 'detail_provider.g.dart';

@riverpod
class NotificationDetail extends _$NotificationDetail {
  final NotificationBridge _bridge = NotificationBridge();

  @override
  FutureOr<List<NativeNotificationRevision>> build(int recordId) async {
    return _fetchRevisions(recordId);
  }

  Future<List<NativeNotificationRevision>> _fetchRevisions(int id) async {
    final result = await _bridge.getRevisions(id);
    return result.whereType<NativeNotificationRevision>().toList();
  }
}
