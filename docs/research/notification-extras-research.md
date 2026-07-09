# استخراج داده‌های extras از NotificationListenerService

**تاریخ:** 2026-07-09  
**منبع اصلی:** کد منبع AOSP `Notification.java` و `StatusBarNotification.java`  
**نسخه:** API 26+ (Android 8.0+)  
**پروژه:** NotTik — آرشیور کاملاً آفلاین نوتیفیکیشن‌ها

---

## فهرست مطالب

1. [نمای کلی Notification.extras Bundle](#1-نمای-کلی-notificationextras-bundle)
2. [استخراج ایمن فیلدهای متنی](#2-استخراج-ایمن-فیلدهای-متنی)
3. [استخراج MessagingStyle و پیام‌های مکالمه](#3-استخراج-messagingstyle-و-پیام‌های-مکالمه)
4. [استخراج تصاویر (Bitmap و Icon)](#4-استخراج-تصاویر-bitmap-و-icon)
5. [ مدیریت نوتیفیکیشن‌های گروهی (Grouped Notifications)](#5-مدیریت-نوتیفیکیشن‌های-گروهی-grouped-notifications)
6. [تشخیص و دسته‌بندی نوع نوتیفیکیشن](#6-تشخیص-و-دسته‌بندی-نوع-نوتیفیکیشن)
7. [نمونه کد جامع: استخراج کامل](#7-نمونه-کد-جامع-استخراج-کامل)
8. [نکات و خطرات مهم](#8-نکات-و-خطرات-مهم)

---

## 1. نمای کلی Notification.extras Bundle

فیلد `extras` در کلاس `Notification` یک `Bundle` است که تمام داده‌های ساختاری نوتیفیکیشن را نگهداری می‌کند. این Bundle با کلیدهای از پیش تعریف‌شده در کلاس `Notification` پر می‌شود.

### کلیدهای متنی اصلی

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_TITLE` | `"android.title"` | عنوان اصلی (contentTitle) |
| `EXTRA_TITLE_BIG` | `"android.title.big"` | عنوان در حالت expanded (مثلاً BigTextStyle) |
| `EXTRA_TEXT` | `"android.text"` | متن اصلی (contentText) |
| `EXTRA_SUB_TEXT` | `"android.subText"` | متن سوم (subText) |
| `EXTRA_BIG_TEXT` | `"android.bigText"` | متن بلッグ در BigTextStyle |
| `EXTRA_SUMMARY_TEXT` | `"android.summaryText"` | متن خلاصه |
| `EXTRA_INFO_TEXT` | `"android.infoText"` | متن اطلاعاتی |
| `EXTRA_TEXT_LINES` | `"android.textLines"` | آرایه خطوط InboxStyle (CharSequence[]) |

### کلیدهای تصویری

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_LARGE_ICON` | `"android.largeIcon"` | آیکون بزرگ (Bitmap) - deprecated |
| `EXTRA_LARGE_ICON_BIG` | `"android.largeIcon.big"` | آیکون بزرگ در حالت expanded |
| `EXTRA_PICTURE` | `"android.picture"` | تصویر بزرگ BigPictureStyle (Bitmap) |
| `EXTRA_PICTURE_ICON` | `"android.pictureIcon"` | تصویر بزرگ BigPictureStyle (Icon) |
| `EXTRA_SMALL_ICON` | `"android.icon"` | آیکون کوچک (resource ID) - deprecated |

### کلیدهای MessagingStyle

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_MESSAGES` | `"android.messages"` | آرایه Parcelable از Bundle پیام‌ها |
| `EXTRA_HISTORIC_MESSAGES` | `"android.messages.historic"` | پیام‌های تاریخی (historic) |
| `EXTRA_CONVERSATION_TITLE` | `"android.conversationTitle"` | عنوان مکالمه |
| `EXTRA_IS_GROUP_CONVERSATION` | `"android.isGroupConversation"` | آیا مکالمه گروهی است (boolean) |
| `EXTRA_MESSAGING_PERSON` | `"android.messagingUser"` | Person کاربر فعلی |
| `EXTRA_TEMPLATE` | `"android.template"` | نام کلاس Style استفاده شده |

### کلیدهای پیشرفت (Progress)

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_PROGRESS` | `"android.progress"` | مقدار پیشرفت |
| `EXTRA_PROGRESS_MAX` | `"android.progressMax"` | حداکثر پیشرفت |
| `EXTRA_PROGRESS_INDETERMINATE` | `"android.progressIndeterminate"` | نامعیّن بودن پیشرفت |

### کلیدهای تماس (CallStyle)

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_CALL_TYPE` | `"android.callType"` | نوع تماس (int) |
| `EXTRA_CALL_IS_VIDEO` | `"android.callIsVideo"` | آیا تماس ویدیویی است |
| `EXTRA_CALL_PERSON` | `"android.callPerson"` | Person تماس گیرنده |

### کلیدهای رسانه (Media)

| کلید ثابت | مقدار رشته‌ای | توضیح |
|---|---|---|
| `EXTRA_MEDIA_SESSION` | `"android.mediaSession"` | IBinder جلسه رسانه |
| `EXTRA_BACKGROUND_IMAGE_URI` | `"android.backgroundImageUri"` | URI تصویر پس‌زمینه |

---

## 2. استخراج ایمن فیلدهای متنی

### روش اصلی: دسترسی مستقیم به Bundle

هر فیلد باید **جداگانه** و با `try-catch` مستقل خوانده شود. خطا در خواندن یک فیلد نباید باعث از دست رفتن بقیه شود.

```kotlin
/**
 * استخراج تمام فیلدهای متنی به صورت ایمن
 * هر فیلد جداگانه try-catch می‌شود
 */
fun extractTextFields(extras: Bundle): Map<String, String?> {
    val result = mutableMapOf<String, String?>()
    
    // عنوان اصلی
    result["title"] = safeCharSequenceToString(extras, "android.title")
    
    // عنوان بزرگ (expanded)
    result["titleBig"] = safeCharSequenceToString(extras, "android.title.big")
    
    // متن اصلی
    result["text"] = safeCharSequenceToString(extras, "android.text")
    
    // زیرمتن
    result["subText"] = safeCharSequenceToString(extras, "android.subText")
    
    // متن بلند (BigTextStyle)
    result["bigText"] = safeCharSequenceToString(extras, "android.bigText")
    
    // متن خلاصه
    result["summaryText"] = safeCharSequenceToString(extras, "android.summaryText")
    
    // متن اطلاعاتی
    result["infoText"] = safeCharSequenceToString(extras, "android.infoText")
    
    // متن بحرانی کوتاه
    result["shortCriticalText"] = safeCharSequenceToString(extras, "android.shortCriticalText")
    
    // خطوط InboxStyle
    result["textLines"] = safeCharSequenceArrayToString(extras, "android.textLines")
    
    return result
}

/**
 * خواندن ایمن یک CharSequence از Bundle و تبدیل به String
 */
private fun safeCharSequenceToString(
    extras: Bundle, 
    key: String
): String? {
    return try {
        extras.getCharSequence(key)?.toString()
    } catch (e: Exception) {
        // BadParcelableException, ClassCastException, etc.
        null
    }
}

/**
 * خواندن ایمن آرایه CharSequence از Bundle
 */
private fun safeCharSequenceArrayToString(
    extras: Bundle, 
    key: String
): String? {
    return try {
        extras.getCharSequenceArray(key)
            ?.joinToString("\n") { it.toString() }
    } catch (e: Exception) {
        null
    }
}
```

### نکته حیاتی: تفاوت `getCharSequence()` با `getString()`

```kotlin
// ❌ غلط - ممکن است CharSequence باشد نه String
val title = extras.getString("android.title")

// ✅ درست - هم String و هم SpannableString را پوشش می‌دهد
val title = extras.getCharSequence("android.title")?.toString()

// ⚠️ همچنین ممکن است某些 فیلدها از نوع دیگری باشند
// مثلاً EXTRA_SMALL_ICON یک Int (resource ID) است
val iconId = extras.getInt("android.icon", 0)
```

### استخراج فیلدهای اضافی

```kotlin
fun extractAdditionalFields(
    extras: Bundle, 
    notification: Notification
): Map<String, Any?> {
    val result = mutableMapOf<String, Any?>()
    
    // Template type
    result["template"] = safeString(extras, "android.template")
    
    // Chronometer
    result["showChronometer"] = safeBoolean(extras, "android.showChronometer")
    result["chronometerCountDown"] = safeBoolean(extras, "android.chronometerCountDown")
    
    // Timestamp
    result["showWhen"] = safeBoolean(extras, "android.showWhen")
    
    // Colorized
    result["colorized"] = safeBoolean(extras, "android.colorized")
    
    // Compact actions
    result["compactActions"] = safeIntArray(extras, "android.compactActions")
    
    // People list (آرایه String از URI‌ها)
    result["people"] = safeStringArray(extras, "android.people")
    
    // Background image URI
    result["backgroundImageUri"] = safeString(extras, "android.backgroundImageUri")
    
    // Audio contents URI
    result["audioContentsUri"] = safeString(extras, "android.audioContents")
    
    return result
}

private fun safeString(extras: Bundle, key: String): String? {
    return try { extras.getString(key) } catch (_: Exception) { null }
}

private fun safeBoolean(extras: Bundle, key: String): Boolean? {
    return try {
        if (extras.containsKey(key)) extras.getBoolean(key) else null
    } catch (_: Exception) { null }
}

private fun safeIntArray(extras: Bundle, key: String): IntArray? {
    return try { extras.getIntArray(key) } catch (_: Exception) { null }
}

private fun safeStringArray(extras: Bundle, key: String): Array<String>? {
    return try { extras.getStringArray(key) } catch (_: Exception) { null }
}
```

---

## 3. استخراج MessagingStyle و پیام‌های مکالمه

### ساختار داده MessagingStyle

نوتیفیکیشن‌های MessagingStyle شامل یک آرایه از پیام‌های `Parcelable` در کلید `"android.messages"` هستند. هر پیام خودش یک `Bundle` است با ساختار زیر:

**کلیدهای داخل Bundle هر پیام:**

| کلید | نوع | توضیح |
|---|---|---|
| `"text"` | `CharSequence` | متن پیام |
| `"time"` | `long` | زمان ارسال (millis since epoch) |
| `"sender"` | `CharSequence` | نام فرستنده (legacy) |
| `"sender_person"` | `Person` | فرستنده (API 28+) |
| `"type"` | `String` | MIME type داده |
| `"uri"` | `Uri` | URI محتوا |
| `"extras"` | `Bundle` | extras اضافی پیام |
| `"remote_input_history"` | `boolean` | آیا از تاریخچه ورودی ریموت است |

### استخراج کامل MessagingStyle

```kotlin
data class ExtractedMessage(
    val text: String,
    val timestamp: Long,
    val senderName: String?,
    val senderUri: String?,     // URI آواتار فرستنده
    val dataMimeType: String?,
    val dataUri: String?,
    val isRemoteInputHistory: Boolean = false
)

data class MessagingStyleData(
    val conversationTitle: String?,
    val isGroupConversation: Boolean,
    val userDisplayName: String?,
    val messages: List<ExtractedMessage>,
    val historicMessages: List<ExtractedMessage>
)

/**
 * استخراج MessagingStyle از extras
 * 
 * منبع: AOSP Notification.java
 * EXTRA_MESSAGES = "android.messages" 
 * EXTRA_HISTORIC_MESSAGES = "android.messages.historic"
 * EXTRA_CONVERSATION_TITLE = "android.conversationTitle"
 * EXTRA_IS_GROUP_CONVERSATION = "android.isGroupConversation"
 * EXTRA_MESSAGING_PERSON = "android.messagingUser"
 */
fun extractMessagingStyle(extras: Bundle): MessagingStyleData? {
    // اگر پیامی وجود ندارد، MessagingStyle نیست
    if (!extras.containsKey("android.messages")) return null
    
    val messages = extractMessages(extras, "android.messages")
    val historicMessages = extractMessages(extras, "android.messages.historic")
    
    val conversationTitle = safeCharSequenceToString(
        extras, "android.conversationTitle"
    )
    val isGroupConversation = try {
        extras.getBoolean("android.isGroupConversation", false)
    } catch (_: Exception) { false }
    
    // نام کاربر فعلی (مثلاً "Me")
    val userDisplayName = extractMessagingUser(extras)
    
    return MessagingStyleData(
        conversationTitle = conversationTitle,
        isGroupConversation = isGroupConversation,
        userDisplayName = userDisplayName,
        messages = messages,
        historicMessages = historicMessages
    )
}

/**
 * استخراج پیام‌ها از آرایه Parcelable در Bundle
 * 
 * هر پیام یک Bundle است با کلیدهای:
 * "text", "time", "sender", "sender_person"
 */
private fun extractMessages(
    extras: Bundle, 
    key: String
): List<ExtractedMessage> {
    val messages = mutableListOf<ExtractedMessage>()
    
    try {
        val parcelableArray = extras.getParcelableArray(key)
            ?: return messages
        
        for (item in parcelableArray) {
            if (item is Bundle) {
                val msg = extractSingleMessage(item)
                if (msg != null) {
                    messages.add(msg)
                }
            }
        }
    } catch (e: ClassCastException) {
        // ساختار غیرمنتظره
    } catch (e: BadParcelableException) {
        // Bundle خراب
    }
    
    return messages
}

/**
 * استخراج یک پیام تکی از Bundle
 * 
 * بر اساس AOSP Notification.MessagingStyle.Message.getMessageFromBundle():
 * 1. "text" و "time" الزامی هستند
 * 2. "sender_person" (Person) اولویت دارد
 * 3. "sender" (CharSequence) legacy fallback
 * 4. "type" و "uri" اختیاری هستند
 */
private fun extractSingleMessage(bundle: Bundle): ExtractedMessage? {
    try {
        // text و time الزامی هستند
        if (!bundle.containsKey("text") || !bundle.containsKey("time")) {
            return null
        }
        
        val text = bundle.getCharSequence("text")?.toString() ?: return null
        val timestamp = bundle.getLong("time", 0L)
        
        // ترجیح: sender_person (Person object)
        var senderName: String? = null
        var senderUri: String? = null
        
        try {
            val senderPerson = bundle.getParcelable<Person>(
                "sender_person", Person::class.java
            )
            if (senderPerson != null) {
                senderName = senderPerson.name?.toString()
                senderUri = senderPerson.uri
            }
        } catch (_: Exception) {
            // fallback to legacy "sender" key
        }
        
        // Legacy fallback
        if (senderName == null) {
            senderName = try {
                bundle.getCharSequence("sender")?.toString()
            } catch (_: Exception) { null }
        }
        
        val dataMimeType = try {
            bundle.getString("type")
        } catch (_: Exception) { null }
        
        val dataUri = try {
            bundle.getParcelable<Uri>("uri", Uri::class.java)
        } catch (_: Exception) { null }
        
        val isRemoteInputHistory = try {
            bundle.getBoolean("remote_input_history", false)
        } catch (_: Exception) { false }
        
        return ExtractedMessage(
            text = text,
            timestamp = timestamp,
            senderName = senderName,
            senderUri = senderUri,
            dataMimeType = dataMimeType,
            dataUri = dataUri,
            isRemoteInputHistory = isRemoteInputHistory
        )
        
    } catch (e: Exception) {
        // هر خطای دیگری را بگیر - نباید crash کند
        return null
    }
}

/**
 * استخراج نام کاربر فعلی از extras MessagingStyle
 */
private fun extractMessagingUser(extras: Bundle): String? {
    return try {
        // API 28+: Person object
        val person = extras.getParcelable<Person>(
            "android.messagingUser", Person::class.java
        )
        person?.name?.toString()
    } catch (_: Exception) {
        // Legacy fallback
        try {
            extras.getCharSequence("android.selfDisplayName")?.toString()
        } catch (_: Exception) { null }
    }
}
```

### حداکثر تعداد پیام‌ها

طبق AOSP، `MAXIMUM_RETAINED_MESSAGES = 25` است. نوتیفیکیشن حداکثر ۲۵ پیام آخر را نگه می‌دارد. اگر نیاز به پیام‌های بیشتری دارید، باید از `EXTRA_REMOTE_INPUT_HISTORY` یا `EXTRA_REMOTE_INPUT_HISTORY_ITEMS` استفاده کنید.

---

## 4. استخراج تصاویر (Bitmap و Icon)

### انواع تصاویر قابل استخراج

1. **Large Icon** (`"android.largeIcon"`) — آیکون بزرگ کنار نوتیفیکیشن
2. **Large Icon Big** (`"android.largeIcon.big"`) — آیکون بزرگ در حالت expanded
3. **Big Picture** (`"android.picture"`) — تصویر کامل BigPictureStyle
4. **Big Picture Icon** (`"android.pictureIcon"`) — تصویر کامل به صورت Icon (API 31+)
5. **Conversation Icon** (`"android.conversationIcon"`) — آیکون مکالمه
6. **App Icon** — از `PackageManager.getApplicationIcon()`

### استخراج Bitmap از extras

```kotlin
data class NotificationImages(
    val largeIcon: Bitmap?,
    val largeIconBig: Bitmap?,
    val bigPicture: Bitmap?,
    val conversationIcon: Bitmap?
)

/**
 * استخراج تمام تصاویر از extras
 */
fun extractImages(extras: Bundle): NotificationImages {
    return NotificationImages(
        largeIcon = safeGetBitmap(extras, "android.largeIcon"),
        largeIconBig = safeGetBitmap(extras, "android.largeIcon.big"),
        bigPicture = safeGetBitmap(extras, "android.picture"),
        conversationIcon = safeGetBitmap(extras, "android.conversationIcon")
    )
}

/**
 * خواندن ایمن Bitmap از Bundle
 * 
 * ⚠️ نکته: Bitmap می‌تواند بسیار بزرگ باشد!
 * برای اپلیکیشن آرشیو باید تصاویر را ذخیره کرد
 * اما حافظه را مدیریت کرد
 */
private fun safeGetBitmap(extras: Bundle, key: String): Bitmap? {
    return try {
        extras.getParcelable(key, Bitmap::class.java)
    } catch (_: Exception) {
        // ClassCastException, OutOfMemoryError, etc.
        null
    }
}

/**
 * دریافت آیکون اپلیکیشن
 */
fun getAppIcon(
    context: Context, 
    packageName: String
): Bitmap? {
    return try {
        val appInfo = context.packageManager
            .getApplicationInfo(packageName, 0)
        val drawable = context.packageManager.getApplicationIcon(appInfo)
        
        // تبدیل Drawable به Bitmap
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth.coerceAtLeast(1),
            drawable.intrinsicHeight.coerceAtLeast(1),
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        bitmap
    } catch (e: NameNotFoundException) {
        null
    }
}

/**
 * ذخیره Bitmap به فایل
 * برای NotTik: ذخیره در فایل سیستم و ذخیره مسیر در Room
 */
fun saveBitmapToFile(
    context: Context, 
    bitmap: Bitmap, 
    filename: String
): String? {
    return try {
        val dir = File(context.filesDir, "notification_images")
        dir.mkdirs()
        val file = File(dir, filename)
        FileOutputStream(file).use { fos ->
            bitmap.compress(Bitmap.CompressFormat.WEBP_LOSSY, 85, fos)
        }
        file.absolutePath
    } catch (e: Exception) {
        null
    }
}
```

### ⚠️ هشدار حافظه

```kotlin
// ❌ خطرناک: Bitmap می‌تواند باعث OutOfMemoryError شود
val largeIcon = extras.getParcelable<Bitmap>("android.largeIcon")

// ✅ ایمن‌تر: با بررسی اندازه
fun safeExtractBitmap(
    extras: Bundle, 
    key: String, 
    maxSizeBytes: Long = 2 * 1024 * 1024 // 2MB limit
): Bitmap? {
    return try {
        val bitmap = extras.getParcelable<Bitmap>(key, Bitmap::class.java)
        if (bitmap == null) return null
        
        // تخمین اندازه در حافظه
        val estimatedSize = bitmap.width * bitmap.height * 4 // ARGB_8888
        if (estimatedSize > maxSizeBytes) {
            // نسخه کوچک‌تر بساز
            val scale = Math.sqrt(
                maxSizeBytes.toDouble() / estimatedSize
            ).toFloat()
            val scaledWidth = (bitmap.width * scale).toInt().coerceAtLeast(1)
            val scaledHeight = (bitmap.height * scale).toInt().coerceAtLeast(1)
            Bitmap.createScaledBitmap(bitmap, scaledWidth, scaledHeight, true)
        } else {
            bitmap
        }
    } catch (_: Exception) {
        null
    }
}
```

---

## 5. مدیریت نوتیفیکیشن‌های گروهی (Grouped Notifications)

### مفاهیم کلیدی

Android از دو نوع گروه‌بندی پشتیبانی می‌کند:

1. **App Groups** — توسط برنامه‌نویس با `setGroup()` تعریف شده
2. **System Auto-Groups** — توسط سیستم‌عامل گروه‌بندی خودکار (API 26+)

### ساختار Group Key

ساختار `groupKey` در `StatusBarNotification`:

```
userId|packageName|g:groupKey
```

یا اگر override شده باشد:

```
userId|packageName|g:overrideGroupKey
```

### استخراج اطلاعات گروهی

```kotlin
data class GroupInfo(
    val groupKey: String?,
    val isGroup: Boolean,
    val isGroupSummary: Boolean,
    val isGroupChild: Boolean,
    val group: String?,        // group از notification.getGroup()
    val sortKey: String?,      // sort key از notification.getSortKey()
    val overrideGroupKey: String?,
    val groupAlertBehavior: Int
)

fun extractGroupInfo(sbn: StatusBarNotification): GroupInfo {
    val notification = sbn.notification
    
    return GroupInfo(
        groupKey = sbn.groupKey,
        isGroup = sbn.isGroup,
        isGroupSummary = notification.flags and 
            Notification.FLAG_GROUP_SUMMARY != 0,
        isGroupChild = notification.flags and 
            Notification.FLAG_GROUP_SUMMARY == 0 && 
            notification.group != null,
        group = notification.group,
        sortKey = notification.sortKey,
        overrideGroupKey = try {
            // overrideGroupKey یک فیلد private در SBN است
            // اما groupKey آن را شامل می‌شود
            null
        } catch (_: Exception) { null },
        groupAlertBehavior = notification.groupAlertBehavior
    )
}

/**
 * گروه‌بندی نوتیفیکیشن‌ها بر اساس groupKey
 * برای نمایش در NotTik
 */
fun groupNotifications(
    notifications: List<StatusBarNotification>
): Map<String, List<StatusBarNotification>> {
    return notifications.groupBy { it.groupKey }
}

/**
 * تشخیص اینکه آیا یک نوتیفیکیشن group summary است
 * و جمع‌آوری فرزندان آن
 */
fun findGroupChildren(
    notifications: List<StatusBarNotification>,
    groupKey: String
): Pair<StatusBarNotification?, List<StatusBarNotification>> {
    val summary = notifications.find { 
        it.groupKey == groupKey && it.notification.isGroupSummary()
    }
    val children = notifications.filter {
        it.groupKey == groupKey && !it.notification.isGroupSummary()
    }
    return Pair(summary, children)
}

/**
 * نکته: notification.isGroupSummary() و notification.isGroupChild()
 * مستقیماً از notification قابل فراخوانی هستند
 */
fun inspectGroup(notification: Notification) {
    val isSummary = notification.isGroupSummary() // API hidden
    val isChild = notification.isGroupChild()     // API hidden
    val group = notification.group
    val sortKey = notification.sortKey
    val groupAlertBehavior = notification.groupAlertBehavior
}
```

### ⚠️ نکته مهم درباره Group Summary

```
notification.isGroupSummary() و notification.isGroupChild()
متد hidden هستند ولی در NotificationListenerService در دسترس‌اند.
```

بررسی از طریق flag:

```kotlin
val isGroupSummary = (notification.flags and 
    Notification.FLAG_GROUP_SUMMARY) != 0

// FLAG_GROUP_SUMMARY = 0x00000200
// FLAG_AUTOGROUP_SUMMARY = 0x00000400 (hidden, system only)
```

### Group Alert Behavior

```kotlin
// GROUP_ALERT_ALL = 0 — همه صدا دارند
// GROUP_ALERT_CHILDREN = 1 — فقط فرزندان
// GROUP_ALERT_SUMMARY = 2 فقط summary

when (notification.groupAlertBehavior) {
    Notification.GROUP_ALERT_ALL -> {
        // نوتیفیکیشن عادی - صدا و لرزش
    }
    Notification.GROUP_ALERT_CHILDREN -> {
        // فقط فرزندان صدا دارند
    }
    Notification.GROUP_ALERT_SUMMARY -> {
        // فقط summary صدا دارد
    }
}
```

---

## 6. تشخیص و دسته‌بندی نوع نوتیفیکیشن

###.notification.category

فیلد `category` در `Notification` مقادیر از پیش تعریف‌شده دارد:

| ثابت | مقدار | توضیح |
|---|---|---|
| `CATEGORY_CALL` | `"call"` | تماس صوتی/تصویری |
| `CATEGORY_MESSAGE` | `"msg"` | پیام مستقیم (SMS, IM) |
| `CATEGORY_EMAIL` | `"email"` | ایمیل |
| `CATEGORY_EVENT` | `"event"` | رویداد تقویم |
| `CATEGORY_ALARM` | `"alarm"` | زنگ/تایمر |
| `CATEGORY_PROMO` | `"promo"` | تبلیغات |
| `CATEGORY_PROGRESS` | `"progress"` | پیشرفت عملیات |
| `CATEGORY_SOCIAL` | `"social"` | شبکه اجتماعی |
| `CATEGORY_ERROR` | `"err"` | خطا |
| `CATEGORY_TRANSPORT` | `"transport"` | کنترل پخش رسانه |
| `CATEGORY_SYSTEM` | `"sys"` | وضعیت سیستم |
| `CATEGORY_NAVIGATION` | `"navigation"` | ناوبری نقشه |

### تشخیص از طریق Template

```kotlin
fun detectNotificationType(
    notification: Notification,
    extras: Bundle
): NotificationType {
    // 1. بررسی template
    val template = try {
        extras.getString("android.template")
    } catch (_: Exception) { null }
    
    // 2. بررسی category
    val category = notification.category
    
    return when {
        // MessagingStyle
        template?.contains("MessagingStyle") == true -> {
            NotificationType.MESSAGING
        }
        // CallStyle
        template?.contains("CallStyle") == true ||
        category == Notification.CATEGORY_CALL -> {
            NotificationType.CALL
        }
        // MediaStyle
        template?.contains("MediaStyle") == true -> {
            NotificationType.MEDIA
        }
        // BigPictureStyle
        template?.contains("BigPictureStyle") == true -> {
            NotificationType.BIG_PICTURE
        }
        // BigTextStyle
        template?.contains("BigTextStyle") == true -> {
            NotificationType.BIG_TEXT
        }
        // InboxStyle
        template?.contains("InboxStyle") == true -> {
            NotificationType.INBOX
        }
        // DecoratedCustomViewStyle
        template?.contains("DecoratedCustomView") == true -> {
            NotificationType.CUSTOM
        }
        // تشخیص از category
        category == Notification.CATEGORY_MESSAGE -> NotificationType.MESSAGE
        category == Notification.CATEGORY_EMAIL -> NotificationType.EMAIL
        category == Notification.CATEGORY_SOCIAL -> NotificationType.SOCIAL
        category == Notification.CATEGORY_PROGRESS -> NotificationType.PROGRESS
        category == Notification.CATEGORY_ALARM -> NotificationType.ALARM
        category == Notification.CATEGORY_EVENT -> NotificationType.EVENT
        category == Notification.CATEGORY_ERROR -> NotificationType.ERROR
        category == Notification.CATEGORY_TRANSPORT -> NotificationType.TRANSPORT
        category == Notification.CATEGORY_PROMO -> NotificationType.PROMO
        category == Notification.CATEGORY_NAVIGATION -> NotificationType.NAVIGATION
        category == Notification.CATEGORY_SYSTEM -> NotificationType.SYSTEM
        
        // تشخیص هوشمند از extras
        hasProgressBars(extras) -> NotificationType.PROGRESS
        hasInboxLines(extras) -> NotificationType.INBOX
        
        else -> NotificationType.UNKNOWN
    }
}

enum class NotificationType {
    MESSAGING,      // MessagingStyle
    CALL,           // CallStyle
    MEDIA,          // MediaStyle
    BIG_PICTURE,    // BigPictureStyle
    BIG_TEXT,       // BigTextStyle
    INBOX,          // InboxStyle
    CUSTOM,         // DecoratedCustomView
    MESSAGE,        // category=msg
    EMAIL,          // category=email
    SOCIAL,         // category=social
    PROGRESS,       // category=progress یا progress bars
    ALARM,          // category=alarm
    EVENT,          // category=event
    ERROR,          // category=error
    TRANSPORT,      // category=transport
    PROMO,          // category=promo
    NAVIGATION,     // category=navigation
    SYSTEM,         // category=sys
    UNKNOWN
}

private fun hasProgressBars(extras: Bundle): Boolean {
    return try {
        extras.containsKey("android.progress") ||
        extras.containsKey("android.progressMax")
    } catch (_: Exception) { false }
}

private fun hasInboxLines(extras: Bundle): Boolean {
    return try {
        extras.containsKey("android.textLines")
    } catch (_: Exception) { false }
}
```

### نکته درباره CallStyle (API 31+)

```kotlin
// اطلاعات تماس از extras
fun extractCallInfo(extras: Bundle): CallInfo? {
    return try {
        val callType = extras.getInt("android.callType", 0)
        val isVideo = extras.getBoolean("android.callIsVideo", false)
        val callPerson = extras.getParcelable<Person>(
            "android.callPerson", Person::class.java
        )
        
        CallInfo(
            callType = callType,
            isVideo = isVideo,
            callerName = callPerson?.name?.toString(),
            callerUri = callPerson?.uri
        )
    } catch (_: Exception) {
        null
    }
}

data class CallInfo(
    val callType: Int,       // 0 = unknown, 1 = incoming, 2 = outgoing
    val isVideo: Boolean,
    val callerName: String?,
    val callerUri: String?
)
```

---

## 7. نمونه کد جامع: استخراج کامل

### ساختار داده‌های خروجی

```kotlin
/**
 * ساختار کامل داده استخراج شده از یک نوتیفیکیشن
 * برای ذخیره‌سازی در Room
 */
data class ExtractedNotificationData(
    // -- فیلدهای متنی --
    val title: String?,
    val titleBig: String?,
    val text: String?,
    val subText: String?,
    val bigText: String?,
    val summaryText: String?,
    val infoText: String?,
    val shortCriticalText: String?,
    val textLines: String?,       // newline-separated
    
    // -- اطلاعات تم --
    val conversationTitle: String?,
    val isGroupConversation: Boolean?,
    val messagingUser: String?,   // نام کاربر فعلی
    
    // -- اطلاعات تماس --
    val callType: Int?,
    val callIsVideo: Boolean?,
    val callPerson: String?,
    
    // -- پیشرفت --
    val progress: Int?,
    val progressMax: Int?,
    val progressIndeterminate: Boolean?,
    
    // -- نوع --
    val template: String?,
    val category: String?,
    val notificationType: NotificationType,
    
    // -- تصاویر (مسیر فایل) --
    val largeIconPath: String?,
    val bigPicturePath: String?,
    
    // -- گروه --
    val groupKey: String?,
    val isGroup: Boolean,
    val isGroupSummary: Boolean,
    val group: String?,
    val sortKey: String?,
    
    // -- سایر --
    val showWhen: Boolean?,
    val showChronometer: Boolean?,
    val colorized: Boolean?,
    val remoteInputHistory: Array<String>?
)
```

### تابع اصلی استخراج

```kotlin
/**
 * استخراج کامل تمام داده‌های نوتیفیکیشن
 * 
 * ⚠️ هر فیلد جداگانه try-catch می‌شود
 * ⚠️ خطا در یک فیلد روی بقیه تأثیر نمی‌گذارد
 */
fun extractAll(
    context: Context,
    sbn: StatusBarNotification
): ExtractedNotificationData {
    val notification = sbn.notification
    val extras = notification.extras
    
    // فیلدهای متنی - هر کدام جداگانه ایمن
    val title = safeCharSequenceToString(extras, "android.title")
    val titleBig = safeCharSequenceToString(extras, "android.title.big")
    val text = safeCharSequenceToString(extras, "android.text")
    val subText = safeCharSequenceToString(extras, "android.subText")
    val bigText = safeCharSequenceToString(extras, "android.bigText")
    val summaryText = safeCharSequenceToString(extras, "android.summaryText")
    val infoText = safeCharSequenceToString(extras, "android.infoText")
    val shortCriticalText = safeCharSequenceToString(
        extras, "android.shortCriticalText"
    )
    val textLines = safeCharSequenceArrayToString(extras, "android.textLines")
    
    // MessagingStyle
    val messagingData = extractMessagingStyle(extras)
    
    // CallStyle
    val callInfo = extractCallInfo(extras)
    
    // Progress
    val progress = safeGetInt(extras, "android.progress")
    val progressMax = safeGetInt(extras, "android.progressMax")
    val progressIndeterminate = safeGetBoolean(
        extras, "android.progressIndeterminate"
    )
    
    // Template & Category
    val template = safeString(extras, "android.template")
    val category = notification.category
    
    // نوع نوتیفیکیشن
    val notificationType = detectNotificationType(notification, extras)
    
    // تصاویر (فقط metadata ذخیره می‌کنیم، Bitmap را جداگانه)
    val largeIcon = safeGetBitmap(extras, "android.largeIcon")
    val bigPicture = safeGetBitmap(extras, "android.picture")
    
    // ذخیره تصاویر در فایل
    val largeIconPath = largeIcon?.let { bitmap ->
        val filename = "${sbn.key.hashCode()}_icon.webp"
        saveBitmapToFile(context, bitmap, filename)
    }
    val bigPicturePath = bigPicture?.let { bitmap ->
        val filename = "${sbn.key.hashCode()}_picture.webp"
        saveBitmapToFile(context, bitmap, filename)
    }
    
    // گروه
    val groupKey = sbn.groupKey
    val isGroup = sbn.isGroup
    val isGroupSummary = (notification.flags and 
        Notification.FLAG_GROUP_SUMMARY) != 0
    val group = notification.group
    val sortKey = notification.sortKey
    
    // سایر فیلدها
    val showWhen = safeGetBoolean(extras, "android.showWhen")
    val showChronometer = safeGetBoolean(extras, "android.showChronometer")
    val colorized = safeGetBoolean(extras, "android.colorized")
    val remoteInputHistory = safeStringArray(
        extras, "android.remoteInputHistory"
    )
    
    return ExtractedNotificationData(
        title = title, titleBig = titleBig, text = text,
        subText = subText, bigText = bigText,
        summaryText = summaryText, infoText = infoText,
        shortCriticalText = shortCriticalText, textLines = textLines,
        conversationTitle = messagingData?.conversationTitle,
        isGroupConversation = messagingData?.isGroupConversation,
        messagingUser = messagingData?.userDisplayName,
        callType = callInfo?.callType,
        callIsVideo = callInfo?.isVideo,
        callPerson = callInfo?.callerName,
        progress = progress, progressMax = progressMax,
        progressIndeterminate = progressIndeterminate,
        template = template, category = category,
        notificationType = notificationType,
        largeIconPath = largeIconPath,
        bigPicturePath = bigPicturePath,
        groupKey = groupKey, isGroup = isGroup,
        isGroupSummary = isGroupSummary, group = group,
        sortKey = sortKey,
        showWhen = showWhen, showChronometer = showChronometer,
        colorized = colorized,
        remoteInputHistory = remoteInputHistory
    )
}
```

---

## 8. نکات و خطرات مهم

### 8.1 حافظه و Bitmap

```
⚠️ Bitmap‌ها می‌توانند بسیار بزرگ باشند (چند MB)
⚠️ از حداکثر اندازه پیکسلی Large Icon 16:9 رعایت کنید
⚠️ تصاویر را به WEBP تبدیل کرده و در فایل ذخیره کنید
⚠️ مسیر فایل را در Room ذخیره کنید نه خود Bitmap را
⚠️ بعد از استخراج، Bitmap را recycle کنید
```

### 8.2 Safe Bundle Access

```
⚠️ هر فیلد Bundle را جداگانه با try-catch بخوانید
⚠️ نوع داده ممکن است با انتظار شما متفاوت باشد
⚠️ BadParcelableException رایج‌ترین خطاست
⚠️ برخی فیلدها ممکن است در نسخه‌های مختلف اندروید متفاوت باشند
⚠️ NEVER assume a key exists — همیشه containsKey را چک کنید
⚠️ برخی اپ‌ها extras سفارشی اضافه می‌کنند که ممکن است خراب باشند
```

### 8.3 MessagingStyle

```
⚠️ EXTRA_MESSAGES یک ParcelableArray است، نه ArrayList
⚠️ هر عنصر خودش یک Bundle است
⚠️ sender_person ممکن است null باشد — از sender fallback کنید
⚠️ پیام‌ها مرتب‌شده از قدیم به جدید هستند
⚠️ حداکثر 25 پیام نگه داشته می‌شود
⚠️ پیام‌های historic جداگانه در EXTRA_HISTORIC_MESSAGES هستند
```

### 8.4 Grouped Notifications

```
⚠️ groupKey شامل userId|packageName|g:groupKey است
⚠️ FLAG_GROUP_SUMMARY = 0x00000200
⚠️ auto-grouped notifications ممکن است FLAG_AUTOGROUP_SUMMARY داشته باشند
⚠️ overrideGroupKey ممکن است متفاوت از group باشد
⚠️ groupAlertBehavior مشخص می‌کند کدام نوتیفیکیشن‌ها صدا دارند
⚠️ isGroupSummary() و isGroupChild() hidden API هستند ولی از Listener قابل فراخوانی
```

### 8.5 Performance

```
⚠️ onNotificationPosted در thread اصلی Listener فراخوانی می‌شود
⚠️ عملیات سنگین (ذخیره Bitmap) را به coroutine منتقل کنید
⚠️ استخراج MessagingStyle ممکن است برای پیام‌های زیاد کند باشد
⚠️ از debounce برای جلوگیری از ذخیره تکراری استفاده کنید
```

### 8.6 API Level Differences

```kotlin
// API 26+: NotificationListenerService
// API 28+: Person object در MessagingStyle
// API 29+: overrideGroupKey در StatusBarNotification  
// API 31+: CallStyle, EXTRA_PICTURE_ICON
// API 33+: EXTRA_SHORT_CRITICAL_TEXT

if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    // CallStyle و related extras
    val callType = extras.getInt("android.callType", 0)
}
```

### 8.7 فیلدهای ایمن برای هر نوع نوتیفیکیشن

| نوع | فیلدهای همیشه معتبر |
|---|---|
| همه | `title`, `text`, `category`, `template` |
| MessagingStyle | + `messages`, `conversationTitle`, `isGroupConversation` |
| CallStyle | + `callType`, `callIsVideo`, `callPerson` |
| BigPictureStyle | + `picture`, `pictureIcon` |
| BigTextStyle | + `bigText` |
| InboxStyle | + `textLines` |
| MediaStyle | + `mediaSession` |
| با Progress | + `progress`, `progressMax`, `progressIndeterminate` |

---

## منابع

- **AOSP Source:** `frameworks/base/core/java/android/app/Notification.java`
  - ثابت‌های EXTRA_* از خطوط 1242-1772
  - کلاس MessagingStyle از خط 8837
  - کلاس Message از خط 9729
  - getMessageFromBundle() از خط 10036
- **AOSP Source:** `frameworks/base/core/java/android/service/notification/StatusBarNotification.java`
  - groupKey() از خط 177
  - isGroup() از خط 200
- **Android Developers:** `NotificationListenerService` reference
- **Android Developers:** `Notification.MessagingStyle` reference
