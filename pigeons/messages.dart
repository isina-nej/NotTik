import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/app/bridge/pigeon.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/nottik/app/bridge/Pigeon.kt',
  kotlinOptions: KotlinOptions(package: 'com.nottik.app.bridge'),
))

class NativeNotificationRecord {
  int? id;
  String? notificationKey;
  String? packageName;
  String? appName;
  int? notificationId;
  String? tag;
  int? postTime;
  int? firstCapturedTime;
  int? lastUpdateTime;
  String? groupKey;
  String? channelId;
  int? priority;
  int? visibility;
  bool? isOngoing;
  bool? isClearable;
  bool? isGroupSummary;
  bool? isRemoved;
  int? removalReason;
}

class NativeNotificationRevision {
  int? id;
  int? parentRecordId;
  int? captureTimestamp;
  String? contentHash;
  String? title;
  String? text;
  String? subText;
  String? bigText;
  String? summaryText;
  String? infoText;
  String? conversationTitle;
  int? progressMax;
  int? progressValue;
  bool? progressIndeterminate;
  String? category;
}

class PaginatedResult {
  List<NativeNotificationRecord?>? items;
  bool? hasMore;
}

@HostApi()
abstract class NotificationBridge {
  bool isListenerConnected();
  void openListenerSettings();
  void requestRebind();
  
  @async
  PaginatedResult getLatestHistory(int offset, int limit);
  
  @async
  NativeNotificationRecord? getRecordDetails(int id);
  
  @async
  List<NativeNotificationRevision?> getRevisions(int recordId);
}