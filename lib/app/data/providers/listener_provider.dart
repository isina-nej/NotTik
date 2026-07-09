import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nottik/app/bridge/pigeon.dart';

part 'listener_provider.g.dart';

@riverpod
class ListenerConnected extends _$ListenerConnected {
  final _bridge = NotificationBridge();

  @override
  Future<bool> build() async {
    return _bridge.isListenerConnected();
  }

  Future<void> checkConnection() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _bridge.isListenerConnected());
  }

  void openSettings() {
    _bridge.openListenerSettings();
  }
}