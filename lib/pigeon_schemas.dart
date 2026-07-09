import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/platform/messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.nottik.app.pigeon'),
))

class NotificationFilter {
  bool selectedAppsOnly;
  List<String> blockedApps;

  NotificationFilter({required this.selectedAppsOnly, required this.blockedApps});
}

@HostApi()
abstract class NativeNotificationApi {
  bool isListenerConnected();
  void requestRebind();
  void openNotificationSettings();
}
