# NotTik Research Log

## Research Lane A: Android Notification Access

- **Date:** 2026-07-09
- **Source:** https://developer.android.com/reference/android/service/notification/NotificationListenerService
- **Version:** API 26+ (Android 8.0+)
- **Finding:** `NotificationListenerService` allows apps to receive calls when notifications are posted or removed.
- **Impact on NotTik:** This is the core mechanism for capturing notifications. We will implement a native Kotlin service extending this class.
- **Chosen Approach:** Use `NotificationListenerService` with `onNotificationPosted` and `onNotificationRemoved`.
- **Rejected Alternatives:** AccessibilityService (violates rules, overkill for this purpose).
- **Remaining Risk:** Doze mode / battery optimizations might kill the service or delay callbacks. Android 13+ notification permissions might indirectly affect what is broadcast (though usually listener access is a separate special permission).

- **Date:** 2026-07-09
- **Source:** https://developer.android.com/reference/android/service/notification/NotificationListenerService#requestRebind(android.content.ComponentName)
- **Version:** API 24+
- **Finding:** If the listener process is killed, it might not automatically rebind. `requestRebind` can be used to request the OS to rebind the service.
- **Impact on NotTik:** We need a way to check if the listener is active and prompt the user to toggle access or try `requestRebind` if it's dead.
- **Chosen Approach:** Provide a Pigeon API to check listener status and another to launch `Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS`.

## Research Lane B: Flutter Architecture

- **Date:** 2026-07-09
- **Source:** https://docs.flutter.dev/
- **Version:** Flutter 3.24+ (Stable)
- **Finding:** Riverpod is the recommended state management solution. go_router is the standard for navigation. gen_l10n is standard for i18n.
- **Impact on NotTik:** We will use these standard tools.
- **Chosen Approach:** `flutter_riverpod`, `go_router`, and `flutter_localizations`.

- **Date:** 2026-07-09
- **Source:** https://pub.dev/packages/pigeon
- **Version:** Pigeon latest
- **Finding:** Pigeon generates type-safe communication channels between Flutter and native code, avoiding raw MethodChannel boilerplate and errors.
- **Impact on NotTik:** Perfect for our Native Kotlin <-> Flutter Dart bridge for accessing the Room DB and listener status.
- **Chosen Approach:** Use `pigeon` for all native communication.

## Research Lane C: Native Persistence

- **Date:** 2026-07-09
- **Source:** https://developer.android.com/training/data-storage/room
- **Version:** Room 2.6+
- **Finding:** Room provides a robust abstraction over SQLite. It supports Coroutines and Flow out of the box.
- **Impact on NotTik:** Room is the ideal choice for our Kotlin-first persistence architecture where the `NotificationListenerService` writes data independently of Flutter.
- **Chosen Approach:** Kotlin + Room as the single source of truth.
- **Rejected Alternatives:** Drift (Flutter-centric, wouldn't work easily when Flutter UI is dead). Shared SQLite (complex concurrency).
- **Remaining Risk:** Managing migrations safely without losing user data.

## Research Lane D: Android Package Visibility

- **Date:** 2026-07-09
- **Source:** https://developer.android.com/training/package-visibility
- **Version:** Android 11+ (API 30+)
- **Finding:** Apps cannot see all installed packages by default. `QUERY_ALL_PACKAGES` is heavily restricted by Google Play.
- **Impact on NotTik:** We cannot easily show a complete list of installed apps for the user to pick from.
- **Chosen Approach:** We will list launchable apps (via intent queries for `CATEGORY_LAUNCHER`, which are usually visible without `QUERY_ALL_PACKAGES`), and dynamically add packages to our internal list as we observe notifications from them.
- **Rejected Alternatives:** Requesting `QUERY_ALL_PACKAGES` (violates store policies and prompt rules).
- **Remaining Risk:** Users might want to filter an app before it sends a notification or if it doesn't have a launcher icon. They'll have to wait until it posts a notification.

## Research Lane F: Notification Extras Extraction

- **Date:** 2026-07-09
- **Source:** AOSP `Notification.java`, `StatusBarNotification.java` (Android Code Search)
- **Version:** API 26+ (Android 8.0+), some features API 28+/31+
- **Finding:** Notification.extras Bundle contains all structured data. Key findings:
  - **Text fields:** `android.title`, `android.text`, `android.subText`, `android.bigText`, `android.summaryText`, `android.infoText` — all are CharSequence, use `getCharSequence().toString()`.
  - **MessagingStyle:** `android.messages` contains ParcelableArray of Bundle. Each message Bundle has keys: `text`, `time`, `sender`, `sender_person` (Person), `type`, `uri`, `extras`, `remote_input_history`.
  - **Images:** `android.largeIcon` (Bitmap, deprecated), `android.picture` (BigPictureStyle), `android.pictureIcon` (Icon, API 31+). Bitmaps can be huge — save to file, store path in Room.
  - **Grouped notifications:** `StatusBarNotification.getGroupKey()` returns `userId|pkg|g:groupKey`. `Notification.FLAG_GROUP_SUMMARY` (0x200) identifies group summaries. `isGroupSummary()` and `isGroupChild()` are hidden APIs but accessible from Listener.
  - **Category detection:** `notification.category` provides semantic type (call, msg, email, event, etc.). `extras.getString("android.template")` provides style class name (MessagingStyle, CallStyle, etc.).
  - **Safe extraction:** Every Bundle field MUST be accessed independently with its own try-catch. `BadParcelableException` and `ClassCastException` are common.
- **Impact on NotTik:** Current NottikNotificationListener only extracts `title` and `text`. Need to expand to extract all extras fields, MessagingStyle messages, images, and group info.
- **Chosen Approach:** Per-field try-catch extraction, save Bitmaps to files with paths in Room, use template+category for type detection.
- **Deliverable:** `docs/research/notification-extras-research.md` (1130 lines, Persian with Kotlin code examples)
- **Remaining Risk:** Some apps use custom RemoteViews which bypass standard extras. Custom views won't be extractable via extras alone.

## Research Lane E: Storage and Background Cleanup

- **Date:** 2026-07-09
- **Source:** https://developer.android.com/topic/libraries/architecture/workmanager
- **Version:** WorkManager 2.9+
- **Finding:** WorkManager is the recommended API for deferrable background work, guaranteed to execute even if the app exits or device reboots.
- **Impact on NotTik:** Perfect for scheduled retention cleanup (e.g., daily cleanup of old notifications).
- **Chosen Approach:** Use WorkManager with `PeriodicWorkRequest`.
- **Rejected Alternatives:** AlarmManager (exact alarms are restricted in modern Android). JobScheduler (WorkManager wraps this and handles backwards compatibility).
- **Remaining Risk:** OEM battery savers might restrict background work.

