# تحقیق الگوهای Pigeon v24.x برای ارتباط Kotlin-Flutter در NotTik

> **تاریخ:** 2026-07-09
> **نسخه Pigeon:** 24.2.1 (موجود در پروژه) / 27.1.0 (آخرین نسخه)
> **وضعیت:** تحقیق تکمیل شده

---

## فهرست

1. [نمای کلی Pigeon v24.x](#1-نمای-کلی-pigeon-v24x)
2. [APIهای پرسوجوی صفحه‌بندی‌شده (Pagination)](#2-apipرسوجوهای-صفحه‌بندی‌شده)
3. [اعلان‌های بیدرنگ Kotlin به Flutter](#3-اعلان‌های-بیدرنگ)
4. [DTOهای پیچیده فیلتر/جستجو](#4-dtoهای-فیلتر-جستجو)
5. [مدیریت خطا](#5-مدیریت-خطا)
6. [انتقال داده‌های حجیم](#6-انتقال-داده‌های-حجیم)
7. [تنظیمات تولید کد](#7-تنظیمات-تولید-کد)
8. [نمونه کامل برای NotTik](#8-نمونه-کامل)

---

## 1. نمای کلی Pigeon v24.x

Pigeon ابزار تولید کد است که ارتباط بین Flutter و پلتفرم بومی را نوع‌امن و بدون نیاز به نوشتن دستی MethodChannel فراهم می‌کند.

### انواع API در Pigeon

| Annotation | جهت ارتباط | کاربرد در NotTik |
|---|---|---|
| `@HostApi()` | Flutter → Kotlin | پرس‌وجوی نوتیفیکیشن‌ها، تنظیمات |
| `@FlutterApi()` | Kotlin → Flutter | فراخوانی callback از Kotlin به Dart |
| `@EventChannelApi()` | Kotlin → Flutter (Streaming) | ارسال نوتیفیکیشن‌های جدید بیدرنگ |

### انواع داده‌های پشتیبانی‌شده

- تمامی انواع اولیه: `bool`, `int`, `double`, `String`, `Object`
- کلاس‌های سفارشی (Data Classes)
- `List<T>` و `Map<K, V>` با انواع تودرتو
- Enumها
- `Uint8List`, `Int32List`, `Float64List` برای داده‌های باینری
- کلاس‌های sealed (Dart 3) برای event channel

### نسخه 24.x تغییرات کلیدی

- پشتیبانی از `TaskQueue` برای اجرای متدها در background thread
- پشتیبانی از `@EventChannelApi` برای streaming داده از Kotlin به Flutter
- بهبود مدیریت خطا با `FlutterError`
- پشتیبانی از multi-instance با `messageChannelSuffix`

---

## 2. APIهای پرسوجوی صفحه‌بندی‌شده (Pagination)

### الگوی DTO دراکر (Pigeon Definition)

```dart
// pigeons/messages.dart

/// درخواست صفحه‌بندی‌شده برای پرس‌وجوی نوتیفیکیشن‌ها
class NotificationQueryRequest {
  NotificationQueryRequest({
    required this.offset,
    required this.limit,
    this.sortOrder = 'desc',
  });

  /// شماره آیتم اول (شروع از ۰)
  int offset;

  /// حداکثر تعداد آیتم در هر درخواست
  int limit;

  /// ترتیب مرتب‌سازی: 'asc' یا 'desc'
  String sortOrder;
}

/// نتیجه صفحه‌بندی‌شده
class NotificationPage {
  NotificationPage({
    required this.notifications,
    required this.totalCount,
    required this.hasMore,
    required this.offset,
    required this.limit,
  });

  List<NotificationItem> notifications;
  int totalCount;
  bool hasMore;
  int offset;
  int limit;
}

/// آیتم نوتیفیکیشن سبک (بدون فیلدهای اضافی)
class NotificationItem {
  NotificationItem({
    required this.id,
    required this.packageName,
    required this.notificationId,
    this.title,
    this.text,
    required this.postTime,
    this.category,
    required this.isRemoved,
  });

  int id;
  String packageName;
  int notificationId;
  String? title;
  String? text;
  int postTime;
  String? category;
  bool isRemoved;
}
```

### HostApi دراکر

```dart
@HostApi()
abstract class NotificationQueryApi {
  /// دریافت صفحه نوتیفیکیشن‌ها
  NotificationPage getNotifications(NotificationQueryRequest request);

  /// دریافت تعداد کل نوتیفیکیشن‌ها
  int getNotificationCount();

  /// دریافت یک نوتیفیکیشن خاص با جزئیات
  NotificationItem? getNotificationById(int id);
}
```

### پیاده‌سازی Kotlin (Host)

```kotlin
class NotificationQueryApiImpl(private val db: AppDatabase) : NotificationQueryApi {

    override fun getNotifications(request: NotificationQueryRequest): NotificationPage {
        val dao = db.notificationDao()

        // Query صفحه‌بندی‌شده با Room
        val records = dao.getNotificationsPaged(
            offset = request.offset.toLong(),
            limit = request.limit,
            sortOrder = request.sortOrder
        )

        val totalCount = dao.getNotificationCount()
        val hasMore = (request.offset + request.limit) < totalCount

        return NotificationPage(
            notifications = records.map { record ->
                NotificationItem(
                    id = record.id.toInt(),
                    packageName = record.packageName,
                    notificationId = record.notificationId,
                    title = record.latestTitle,
                    text = record.latestText,
                    postTime = record.postTime,
                    category = record.latestCategory,
                    isRemoved = record.isRemoved
                )
            },
            totalCount = totalCount,
            hasMore = hasMore,
            offset = request.offset,
            limit = request.limit
        )
    }

    override fun getNotificationCount(): Int {
        return db.notificationDao().getTotalNotificationCount()
    }

    override fun getNotificationById(id: Int): NotificationItem? {
        val record = db.notificationDao().getRecordById(id.toLong()) ?: return null
        return NotificationItem(
            id = record.id.toInt(),
            packageName = record.packageName,
            notificationId = record.notificationId,
            title = record.latestTitle,
            text = record.latestText,
            postTime = record.postTime,
            category = record.latestCategory,
            isRemoved = record.isRemoved
        )
    }
}
```

### استفاده در Dart (Flutter)

```dart
final api = NotificationQueryApi();

// بارگذاری صفحه اول
final page1 = await api.getNotifications(
  NotificationQueryRequest(offset: 0, limit: 50),
);
print('Total: ${page1.totalCount}, hasMore: ${page1.hasMore}');
print('Loaded: ${page1.notifications.length} notifications');

// بارگذاری صفحه بعدی (برای infinite scroll)
if (page1.hasMore) {
  final page2 = await api.getNotifications(
    NotificationQueryRequest(offset: 50, limit: 50),
  );
}
```

### نکات کلیدی

- **اندازه صفحه پیشنهادی:** 50-100 آیتم. کمتر از 50 باعث تعداد زیاد درخواست‌ها، بیشتر از 100 باعث کندی serialization می‌شود.
- **پاسخ null:** Pigeon برای مقدار return غیرnullable که null باشد، `PlatformException` پرتاب می‌کند. از nullable return types (`NotificationItem?`) استفاده کنید.
- **مقدار limit:** حداکثر 200 پیشنهاد می‌شود. برای داده‌های بزرگ‌تر از Uint8List و فشرده‌سازی استفاده کنید.

---

## 3. اعلان‌های بیدرنگ Kotlin به Flutter

وقتی `NottikNotificationListener` نوتیفیکیشن جدیدی دریافت می‌کند، Flutter باید بلافاصله مطلع شود. Pigeon دو رویکرد اصلی برای این کار ارائه می‌دهد:

### رویکرد ۱: `@EventChannelApi` (توصیه‌شده)

این رویکرد از Flutter EventChannels استفاده می‌کند و برای جریان داده‌های بیدرنگ ایده‌آل است.

#### تعریف Pigeon (Dart)

```dart
/// رویدادهای جدید نوتیفیکیشن از Kotlin به Flutter
sealed class NotificationEvent {
  // Pigeon از کلاس‌های sealed Dart 3 پشتیبانی می‌کند
}

class NotificationReceivedEvent extends NotificationEvent {
  NotificationReceivedEvent({
    required this.id,
    required this.packageName,
    this.title,
    this.text,
    required this.postTime,
  });

  int id;
  String packageName;
  String? title;
  String? text;
  int postTime;
}

class NotificationRemovedEvent extends NotificationEvent {
  NotificationRemovedEvent({required this.id, required this.reason});

  int id;
  int reason;
}

class DatabaseChangedEvent extends NotificationEvent {
  DatabaseChangedEvent({required this.newCount});

  int newCount;
}

@EventChannelApi()
abstract class NotificationEventStream {
  /// Stream رویدادهای نوتیفیکیشن
  /// از Kotlin به Flutter فرستاده می‌شود
  PlatformEvent streamNotificationEvents();
}
```

> **نکته:** `PlatformEvent` نوع ویژه‌ای است که Pigeon برای EventChannel تولید می‌کند. با کلاس sealed کار می‌کند.

#### پیاده‌سازی Kotlin (StreamHandler)

```kotlin
class NotificationEventListener : NotificationEventStreamStreamHandler() {

    private var eventSink: PigeonEventSink<PlatformEvent>? = null

    override fun onListen(p0: Any?, sink: PigeonEventSink<PlatformEvent>) {
        eventSink = sink
    }

    /// ارسال رویداد نوتیفیکیشن جدید به Flutter
    fun onNotificationPosted(id: Int, packageName: String, 
                             title: String?, text: String?, postTime: Long) {
        eventSink?.success(
            NotificationReceivedEvent(
                id = id.toLong(),
                packageName = packageName,
                title = title,
                text = text,
                postTime = postTime
            )
        )
    }

    /// ارسال رویداد حذف نوتیفیکیشن به Flutter
    fun onNotificationRemoved(id: Int, reason: Int) {
        eventSink?.success(
            NotificationRemovedEvent(
                id = id.toLong(),
                reason = reason.toLong()
            )
        )
    }

    /// ارسال اعلان تغییر دیتابیس
    fun onDatabaseChanged(newCount: Int) {
        eventSink?.success(
            DatabaseChangedEvent(newCount = newCount.toLong())
        )
    }

    /// پایان Stream
    fun onDone() {
        eventSink?.endOfStream()
        eventSink = null
    }
}
```

#### ثبت StreamHandler در MainActivity

```kotlin
class MainActivity : FlutterActivity() {
    private lateinit var notificationEventListener: NotificationEventListener

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ثبت HostApi
        NotificationQueryApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            NotificationQueryApiImpl(getDatabase())
        )

        // ثبت EventChannel
        notificationEventListener = NotificationEventListener()
        NotificationEventStreamStreamHandler.register(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationEventListener
        )
    }
}
``()

#### اتصال از NottikNotificationListener

```kotlin
class NottikNotificationListener : NotificationListenerService() {
    // ... existing code ...

    // رفرنس به listener بیدرنگ
    private var eventListener: NotificationEventListener? = null

    fun setEventListener(listener: NotificationEventListener) {
        eventListener = listener
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        // ... existing save logic ...

        scope.launch {
            db.notificationDao().insertOrUpdateNotification(record, revision)

            // ارسال رویداد به Flutter
            eventListener?.onNotificationPosted(
                id = record.id.toInt(),
                packageName = record.packageName,
                title = revision.title,
                text = revision.text,
                postTime = record.postTime
            )

            // ارسال آمار جدید
            val totalCount = db.notificationDao().getTotalNotificationCount()
            eventListener?.onDatabaseChanged(totalCount)
        }
    }
}
```

#### دریافت Stream در Dart (Flutter)

```dart
// در Riverpod provider یا widget
final eventStream = NotificationEventStream();
final events = eventStream.streamNotificationEvents();

events.listen((PlatformEvent event) {
  switch (event) {
    case NotificationReceivedEvent():
      // نوتیفیکیشن جدید رسید!
      print('New: ${event.title} from ${event.packageName}');
      // بروزرسانی state و اضافه کردن به لیست
      ref.read(notificationListProvider.notifier).addNotification(event);

    case NotificationRemovedEvent():
      // نوتیفیکیشن حذف شد
      ref.read(notificationListProvider.notifier).removeNotification(event.id);

    case DatabaseChangedEvent():
      // آمار کل بروزرسانی شد
      ref.read(totalCountProvider.notifier).state = event.newCount;
  }
});
```

### رویکرد ۲: `@FlutterApi` (فراخوانی callback)

این رویکرد مستقیماً از Kotlin به متد Flutter فراخوانی می‌کند. برای رویدادهای منفرد مناسب‌تر است.

```dart
@FlutterApi()
abstract class NotificationCallback {
  /// فراخوانی وقتی نوتیفیکیشن جدید ذخیره شد
  void onNewNotification(int id, String packageName, 
                         String? title, String? text, int postTime);
}
```

```kotlin
// در Kotlin
class NotificationFlutterCallback(binding: FlutterPlugin.FlutterPluginBinding) {
    private val flutterApi = NotificationCallbackApi(binding.binaryMessenger)

    fun notifyNewNotification(id: Long, packageName: String,
                              title: String?, text: String?, postTime: Long) {
        flutterApi.onNewNotification(
            id, packageName, title, text, postTime
        ) { result ->
            result.onSuccess { /* Flutter پاسخ داد */ }
            result.onFailure { e -> Log.e("NotTik", "Callback failed", e) }
        }
    }
}
```

### مقایسه دو رویکرد

| معیار | `@EventChannelApi` | `@FlutterApi` |
|---|---|---|
| مناسب برای جریان مداوم | ✅ عالی | ❌ نه چندان |
| مناسب برای رویدادهای پراکنده | ✅ خوب | ✅ عالی |
| پشتیبانی از sealed class | ✅ بله | ❌ خیر |
| پیچیدگی پیاده‌سازی | متوسط | کم |
| مدیریت lifecycle | خودکار (onListen) | دستی |

### توصیه نهایی برای NotTik

از **`@EventChannelApi`** استفاده کنید زیرا:
1. نوتیفیکیشن‌ها جریان مداومی دارند (هر لحظه ممکن است نوتیفیکیشن جدیدی برسد)
2. از sealed class برای انواع مختلف رویداد پشتیبانی می‌کند
3. lifecycle مدیریت شده دارد ( وقتی Flutter widget unmount می‌شود، stream خاتمه می‌یابد)

---

## 4. DTOهای فیلتر/جستجوی پیچیده

### الگوی فیلتر در Pigeon

```dart
/// انواع مرتب‌سازی
enum SortField { postTime, title, packageName }

enum SortOrder { ascending, descending }

/// فیلتر پیشرفته نوتیفیکیشن‌ها
class NotificationFilter {
  NotificationFilter({
    this.packageNames,
    this.categories,
    this.searchQuery,
    this.sinceTimestamp,
    this.untilTimestamp,
    this.isRemoved,
    this.sortField = SortField.postTime,
    this.sortOrder = SortOrder.descending,
  });

  /// فیلتر بر اساس نام پکیج (null = همه)
  List<String>? packageNames;

  /// فیلتر بر اساس دسته‌بندی (null = همه)
  List<String>? categories;

  /// جستجو در عنوان و متن
  String? searchQuery;

  /// محدوده زمانی
  int? sinceTimestamp;
  int? untilTimestamp;

  /// فقط حذف‌شده‌ها / فقط فعال‌ها
  bool? isRemoved;

  SortField sortField;
  SortOrder sortOrder;
}

/// نتیجه جستجو
class SearchResult {
  SearchResult({
    required this.notifications,
    required this.totalCount,
    required this.offset,
    required this.limit,
    required this.hasMore,
    required this.queryTimeMs,
  });

  List<NotificationItem> notifications;
  int totalCount;
  int offset;
  int limit;
  bool hasMore;

  /// زمان صرف‌شده برای جستجو (برای debug)
  int queryTimeMs;
}
```

### HostApi با فیلتر

```dart
@HostApi()
abstract class NotificationSearchApi {
  /// جستجوی پیشرفته با فیلتر
  SearchResult searchNotifications(
    NotificationFilter filter, {
    required int offset,
    required int limit,
  });

  /// دریافت نام پکیج‌های موجود (برای UI فیلتر)
  List<String> getAvailablePackageNames();

  /// دریافت دسته‌بندی‌های موجود
  List<String> getAvailableCategories();
}
```

### پیاده‌سازی Kotlin

```kotlin
class NotificationSearchImpl(private val db: AppDatabase) : NotificationSearchApi {

    override fun searchNotifications(
        filter: NotificationFilter,
        offset: Long,
        limit: Long
    ): SearchResult {
        val startTime = System.currentTimeMillis()
        val dao = db.notificationDao()

        // ساخت query داینامیک با Room
        val queryBuilder = StringBuilder(
            """
            SELECT nr.id, nr.package_name, nr.notification_id, 
                   nr.post_time, nr.is_removed,
                   nrv.title, nrv.text, nrv.category
            FROM notification_records nr
            LEFT JOIN notification_revisions nrv 
                ON nrv.parent_record_id = nr.id
                AND nrv.capture_timestamp = (
                    SELECT MAX(nrv2.capture_timestamp)
                    FROM notification_revisions nrv2
                    WHERE nrv2.parent_record_id = nr.id
                )
            WHERE 1=1
            """.trimIndent()
        )
        val args = mutableListOf<Any>()

        // اعمال فیلترها
        filter.packageNames?.let { packages ->
            if (packages.isNotEmpty()) {
                val placeholders = packages.joinToString(",") { "?" }
                queryBuilder.append(" AND nr.package_name IN ($placeholders)")
                args.addAll(packages)
            }
        }

        filter.categories?.let { categories ->
            if (categories.isNotEmpty()) {
                val placeholders = categories.joinToString(",") { "?" }
                queryBuilder.append(" AND nrv.category IN ($placeholders)")
                args.addAll(categories)
            }
        }

        filter.searchQuery?.let { query ->
            if (query.isNotBlank()) {
                queryBuilder.append(" AND (nrv.title LIKE ? OR nrv.text LIKE ?)")
                args.add("%$query%")
                args.add("%$query%")
            }
        }

        filter.sinceTimestamp?.let {
            queryBuilder.append(" AND nr.post_time >= ?")
            args.add(it)
        }

        filter.untilTimestamp?.let {
            queryBuilder.append(" AND nr.post_time <= ?")
            args.add(it)
        }

        filter.isRemoved?.let {
            queryBuilder.append(" AND nr.is_removed = ?")
            args.add(if (it) 1 else 0)
        }

        // مرتب‌سازی
        val sortColumn = when (filter.sortField) {
            SortField.POST_TIME -> "nr.post_time"
            SortField.TITLE -> "nrv.title"
            SortField.PACKAGE_NAME -> "nr.package_name"
            else -> "nr.post_time"
        }
        val sortDir = if (filter.sortOrder == SortOrder.DESCENDING) "DESC" else "ASC"
        queryBuilder.append(" ORDER BY $sortColumn $sortDir")

        // شمارش کل
        val countQuery = "SELECT COUNT(*) FROM (${queryBuilder})"
        // ... execute count query ...

        // صفحه‌بندی
        queryBuilder.append(" LIMIT ? OFFSET ?")
        args.add(limit)
        args.add(offset)

        // اجرای query اصلی
        // ... execute and map to NotificationItem ...

        val queryTime = System.currentTimeMillis() - startTime

        return SearchResult(
            notifications = results,
            totalCount = totalCount,
            offset = offset.toInt(),
            limit = limit.toInt(),
            hasMore = (offset + limit) < totalCount,
            queryTimeMs = queryTime
        )
    }

    override fun getAvailablePackageNames(): List<String> {
        return db.notificationDao().getAllDistinctPackageNames()
    }

    override fun getAvailableCategories(): List<String> {
        return db.notificationDao().getAllDistinctCategories()
    }
}
```

### نکات مهم

- **پشتیبانی از nested classes:** Pigeon از تودرتوی کلاس‌ها پشتیبانی می‌کند.
- **Enumها:** هم در parameter و هم در return type استفاده می‌شوند. نام enum‌ها در Kotlin به UPPERCASE تبدیل می‌شوند (مثلاً `SortField.postTime` → `SortField.POST_TIME`).
- **Map و List:** هر دو به‌عنوان field در data class پشتیبانی می‌شوند.
- **Null safety:** فیلدهای nullable با `?` در Dart و `Type?` در Kotlin مشخص می‌شوند.

---

## 5. مدیریت خطا

### FlutterError در Kotlin

Pigeon کلاس `FlutterError` را در کد تولیدشده Kotlin ایجاد می‌کند:

```kotlin
// کد تولیدشده توسط Pigeon
class FlutterError(
    val code: String,
    override val message: String? = null,
    val details: Any? = null
) : Throwable()
```

### الگوی خطای سفارشی

```dart
/// انواع خطاهای NotTik
class NotTikErrors {
  static const String databaseCorrupted = 'DATABASE_CORRUPTED';
  static const String queryTimeout = 'QUERY_TIMEOUT';
  static const String invalidFilter = 'INVALID_FILTER';
  static const String notificationNotFound = 'NOTIFICATION_NOT_FOUND';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String serviceUnavailable = 'SERVICE_UNAVAILABLE';
}
```

```kotlin
// در پیاده‌سازی HostApi
class NotificationQueryApiImpl(
    private val db: AppDatabase
) : NotificationQueryApi {

    override fun getNotifications(request: NotificationQueryRequest): NotificationPage {
        // اعتبارسنجی ورودی
        if (request.limit < 1 || request.limit > 500) {
            throw FlutterError(
                code = "INVALID_FILTER",
                message = "Limit must be between 1 and 500, got: ${request.limit}",
                details = mapOf("minLimit" to 1, "maxLimit" to 500)
            )
        }

        if (request.offset < 0) {
            throw FlutterError(
                code = "INVALID_FILTER",
                message = "Offset cannot be negative, got: ${request.offset}"
            )
        }

        return try {
            val dao = db.notificationDao()
            // ... query logic ...
            page
        } catch (e: SQLiteException) {
            throw FlutterError(
                code = "DATABASE_CORRUPTED",
                message = "Database query failed: ${e.message}",
                details = e.stackTraceToString()
            )
        } catch (e: CancellationException) {
            throw FlutterError(
                code = "QUERY_TIMEOUT",
                message = "Query was cancelled or timed out"
            )
        }
    }
}
```

### دریافت خطا در Dart

```dart
import 'package:flutter/services.dart';

final api = NotificationQueryApi();

try {
  final page = await api.getNotifications(
    NotificationQueryRequest(offset: 0, limit: 50),
  );
  // موفقیت‌آمیز
} on PlatformException catch (e) {
  switch (e.code) {
    case 'DATABASE_CORRUPTED':
      // نمایش پیام بازیابی
      showDatabaseRecoveryDialog();
      break;
    case 'INVALID_FILTER':
      // نمایش پیام خطای فیلتر
      showValidationError(e.message);
      break;
    case 'QUERY_TIMEOUT':
      // نمایش دکمه retry
      showRetryButton();
      break;
    default:
      // خطای ناشناخته
      logError(e);
      showGenericError();
  }
}
```

### قوانین مدیریت خطا

1. **متدهای همزمان:** هر exception در Kotlin به‌صورت خودکار به `PlatformException` در Dart تبدیل می‌شود. از `FlutterError` استفاده کنید تا code و message دقیق داشته باشید.

2. **متدهای ناهمزمان (`@async`):** به‌صورت خودکار catch نمی‌شوند! خطا باید از طریق callback بازگردانده شود:

```kotlin
// متد async - خطا باید از callback بازگردد
override fun searchNotificationsAsync(
    filter: NotificationFilter,
    offset: Long,
    limit: Long,
    callback: (Result<SearchResult>) -> Unit
) {
    try {
        val result = doSearch(filter, offset, limit)
        callback(Result.success(result))
    } catch (e: Exception) {
        callback(Result.failure(
            FlutterError("SEARCH_FAILED", e.message, e.stackTraceToString())
        ))
    }
}
```

3. **نکته مهم `details`:** فیلد `details` می‌تواند هر نوعی باشد که Pigeon codec پشتیبانی کند (String, int, Map, List). از `Map<String, Any?>` برای اطلاعات اضافی استفاده کنید.

---

## 6. انتقال داده‌های حجیم

### مشکل

NotTik ممکن است هزاران نوتیفیکیشن ذخیره کند. انتقال کل دیتابیس از طریق platform channel باعث:
- کندی serialization/deserialization
- مصرف حافظه زیاد
- ANR (Application Not Responding) در Android

### راه‌حل‌ها

#### ۱. صفحه‌بندی (Pagination) - ضروری

همان‌طور که در بخش ۲ توضیح داده شد، هرگز کل دیتابیس را یکجا منتقل نکنید.

#### ۲. Response سبک (Lightweight Response)

```dart
/// DTO سبک برای لیست اصلی
class NotificationListItem {
  NotificationListItem({
    required this.id,
    required this.packageName,
    this.title,
    required this.postTime,
    // بدون text کامل - فقط preview
    this.textPreview,
  });

  int id;
  String packageName;
  String? title;
  int postTime;
  String? textPreview; // حداکثر 100 کاراکتر
}

/// DTO کامل برای جزئیات
class NotificationDetail {
  NotificationDetail({
    required this.id,
    required this.packageName,
    required this.notificationId,
    this.title,
    this.text, // متن کامل
    this.category,
    required this.postTime,
    required this.firstCapturedTime,
    this.revisionCount,
  });

  // ... all fields ...
}
```

#### ۳. شمارش جداگانه (Count Endpoint)

```dart
@HostApi()
abstract class NotificationQueryApi {
  // لیست سبک (بدون متن کامل)
  List<NotificationListItem> getRecentNotifications(int limit);

  // شمارش کل (بدون بارگذاری داده)
  int getNotificationCount();

  // جزئیات یک نوتیفیکیشن خاص
  NotificationDetail? getNotificationDetail(int notificationId);

  // صفحه‌بندی
  NotificationPage getNotifications(NotificationQueryRequest request);
}
```

#### ۴. فشرده‌سازی برای داده‌های باینری

```dart
// اگر نیاز به انتقال تصاویر یا فایل‌های باینری دارید
// از Uint8List استفاده کنید - Pigeon این نوع را بهینه منتقل می‌کند

@HostApi()
abstract class MediaApi {
  /// دریافت آیکون پکیج به‌صورت باینری
  Uint8List? getPackageIcon(String packageName);

  /// دریافت attachment نوتیفیکیشن
  Uint8List? getNotificationAttachment(int notificationId, int index);
}
```

#### ۵. جلوگیری از انتقال تکراری

```dart
// از timestamp آخرین sync استفاده کنید
class SyncRequest {
  SyncRequest({required this.lastSyncTimestamp});

  /// فقط نوتیفیکیشن‌های جدیدتر از این زمان
  int lastSyncTimestamp;
}

@HostApi()
abstract class SyncApi {
  /// دریافت نوتیفیکیشن‌های جدید از آخرین sync
  List<NotificationListItem> getNewNotifications(SyncRequest request);

  /// دریافت نوتیفیکیشن‌های حذف‌شده از آخرین sync
  List<int> getRemovedNotificationIds(SyncRequest request);
}
```

---

## 7. تنظیمات تولید کد

### نصب Pigeon

```yaml
# pubspec.yaml
dependencies:
  pigeon: ^24.2.1  # نسخه فعلی پروژه

# توجه: pigeon در dev_dependencies نیست
# بلکه به‌عنوان dependency اصلی استفاده می‌شود
# چون annotations در کد اصلی استفاده می‌شوند
```

### فایل تنظیمات Pigeon

```dart
// pigeons/messages.dart (یا lib/pigeon_schemas.dart)
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/platform/messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.nottik.app.pigeon',
  ),
  // تنظیمات اختیاری:
  // javaOut: '...',  // اگر Java هم نیاز دارید
  // dartPackageName: 'nottik',
))
```

### اجرای تولید کد

```bash
# روش ساده
dart run pigeon --input lib/pigeon_schemas.dart

# با dart format بعد از تولید
dart run pigeon --input lib/pigeon_schemas.dart && \
  dart format lib/core/platform/messages.g.dart && \
  ktfmt android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt
```

### اضافه کردن به Makefile / Script

```bash
#!/bin/bash
# tools/generate_pigeon.sh

set -e

echo "Generating Pigeon code..."
dart run pigeon --input lib/pigeon_schemas.dart

echo "Formatting Dart..."
dart format lib/core/platform/messages.g.dart

echo "Formatting Kotlin..."
if command -v ktfmt &> /dev/null; then
  ktfmt android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt
fi

echo "✅ Pigeon code generated successfully!"
```

### KSP و Room (نکته مهم)

> **Pigeon نیازی به KSP یا build_runner ندارد!**

تفاوت‌های کلیدی:

| ابزار | ابزار تولید کد | اجرا |
|---|---|---|
| **Pigeon** | `dart run pigeon` | CLI مستقل (Dart) |
| **Room/KSP** | KSP Gradle Plugin | هنگام build اندروید |
| **build_runner** | `dart run build_runner` | CLI مستقل (Dart) |

- Pigeon یک ابزار CLI مبتنی بر Dart است که مستقیماً اجرا می‌شود
- Room از KSP استفاده می‌کند که در `build.gradle.kts` تنظیم شده
- نیازی به اضافه کردن Pigeon به Gradle یا build_runner نیست

### نکات Gradle

```kotlin
// android/app/build.gradle.kts
// KSP فقط برای Room استفاده می‌شود
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.devtools.ksp")  // فقط برای Room
}

dependencies {
    val room_version = "2.6.1"
    ksp("androidx.room:room-compiler:$room_version")  // KSP برای Room
    // Pigeon نیازی به dependency جداگانه در Gradle ندارد
}
```

### ساختار فایل‌های تولیدشده

```
NotTik/
├── lib/
│   ├── pigeon_schemas.dart              # تعریف‌های Pigeon (شما می‌نویسید)
│   └── core/platform/
│       └── messages.g.dart              # کد تولیدشده Dart (تولید خودکار)
├── android/app/src/main/kotlin/.../
│   └── pigeon/
│       └── Messages.g.kt                # کد تولیدشده Kotlin (تولید خودکار)
```

### ارتقاء به Pigeon 27.x (اختیاری)

آخرین نسخه Pigeon 27.1.0 است که تغییرات زیر را دارد:

- **Breaking:** `toString` روی data class‌ها override می‌شود
- `FlutterError` از `Throwable` به `RuntimeException` تغییر کرده (v26.3.4)
- بهبود equality و hashing در data class‌ها
- پشتیبانی بهتر از `sealed class` و event channels

**نکته مهم:** اگر از Pigeon 27.x استفاده کنید، `FlutterError` دیگر `Throwable` نیست بلکه `RuntimeException` است. این در Kotlin interop بهتر عمل می‌کند.

برای ارتقاء:
```yaml
# pubspec.yaml
pigeon: ^27.1.0
```

```bash
dart run pigeon --input lib/pigeon_schemas.dart
```

---

## 8. نمونه کامل برای NotTik

### ساختار پیشنهادی Pigeon Schema

```dart
// lib/pigeon_schemas.dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/core/platform/messages.g.dart',
  dartOptions: DartOptions(),
  kotlinOut:
      'android/app/src/main/kotlin/com/nottik/app/pigeon/Messages.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.nottik.app.pigeon',
  ),
))

// ─── Enums ──────────────────────────────

enum SortField { postTime, title, packageName }
enum SortOrder { ascending, descending }

// ─── DTOs ───────────────────────────────

class NotificationQueryRequest {
  NotificationQueryRequest({
    required this.offset,
    required this.limit,
    this.sortOrder = SortOrder.descending,
  });
  int offset;
  int limit;
  SortOrder sortOrder;
}

class NotificationFilter {
  NotificationFilter({
    this.packageNames,
    this.categories,
    this.searchQuery,
    this.sinceTimestamp,
    this.untilTimestamp,
    this.isRemoved,
  });
  List<String>? packageNames;
  List<String>? categories;
  String? searchQuery;
  int? sinceTimestamp;
  int? untilTimestamp;
  bool? isRemoved;
}

class NotificationItem {
  NotificationItem({
    required this.id,
    required this.packageName,
    required this.notificationId,
    this.title,
    this.text,
    required this.postTime,
    this.category,
    required this.isRemoved,
  });
  int id;
  String packageName;
  int notificationId;
  String? title;
  String? text;
  int postTime;
  String? category;
  bool isRemoved;
}

class NotificationPage {
  NotificationPage({
    required this.notifications,
    required this.totalCount,
    required this.hasMore,
    required this.offset,
    required this.limit,
  });
  List<NotificationItem> notifications;
  int totalCount;
  bool hasMore;
  int offset;
  int limit;
}

class SearchResult {
  SearchResult({
    required this.notifications,
    required this.totalCount,
    required this.hasMore,
    required this.queryTimeMs,
  });
  List<NotificationItem> notifications;
  int totalCount;
  bool hasMore;
  int queryTimeMs;
}

// ─── Event Channel DTOs ─────────────────

class NotificationReceivedEvent {
  NotificationReceivedEvent({
    required this.id,
    required this.packageName,
    this.title,
    this.text,
    required this.postTime,
  });
  int id;
  String packageName;
  String? title;
  String? text;
  int postTime;
}

class NotificationRemovedEvent {
  NotificationRemovedEvent({required this.id, required this.reason});
  int id;
  int reason;
}

// ─── APIs ───────────────────────────────

@HostApi()
abstract class NativeNotificationApi {
  bool isListenerConnected();
  void requestRebind();
  void openNotificationSettings();
}

@HostApi()
abstract class NotificationQueryApi {
  NotificationPage getNotifications(NotificationQueryRequest request);
  SearchResult searchNotifications(NotificationFilter filter,
      {required int offset, required int limit});
  int getNotificationCount();
  List<String> getAvailablePackageNames();
  List<String> getAvailableCategories();
}

@EventChannelApi()
abstract class NotificationEventStream {
  PlatformEvent streamNotificationEvents();
}
```

### چک‌لیست پیاده‌سازی

- [ ] Pigeon schema را در `lib/pigeon_schemas.dart` بنویسید
- [ ] `dart run pigeon --input lib/pigeon_schemas.dart` اجرا کنید
- [ ] `NotificationQueryApiImpl` در Kotlin پیاده‌سازی کنید
- [ ] `NotificationEventListener` در Kotlin پیاده‌سازی کنید
- [ ] `NotificationQueryApi.setUp()` در `MainActivity` ثبت کنید
- [ ] `NotificationEventStreamStreamHandler.register()` در `MainActivity` ثبت کنید
- [ ] `eventListener` را به `NottikNotificationListener` متصل کنید
- [ ] Riverpod providers برای state management بنویسید
- [ ] UI با infinite scroll و search پیاده‌سازی کنید
- [ ] Error handling در Flutter اضافه کنید

---

## منابع

- [Pigeon Documentation](https://pub.dev/packages/pigeon)
- [Pigeon Example README](https://github.com/flutter/packages/tree/main/packages/pigeon/example)
- [Flutter EventChannel API](https://api.flutter.dev/flutter/services/EventChannel-class.html)
- [Room Pagination](https://developer.android.com/topic/libraries/architecture/room/paging)
- [Pigeon CHANGELOG](https://github.com/flutter/packages/blob/main/packages/pigeon/CHANGELOG.md)
