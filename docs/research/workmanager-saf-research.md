# تحقیق: WorkManager و Storage Access Framework برای NotTik

**تاریخ:** ۲۰۲۶-۰۷-۰۹  
**وضعیت:** تکمیل شده  
**هدف:** مستندسازی فنی WorkManager برای پاک‌سازی دوره‌ای و SAF برای بکاپ/ریستور

---

## فهرست

1. [WorkManager: تنظیم PeriodicWorkRequest](#1-workmanager-تنظیم-periodicworkrequest)
2. [پیکربندی و کنترل Work از Flutter](#2-پیکربندی-و-کنترل-work-از-flutter)
3. [حذف ردیف‌های Room و فایل‌های مدیا در Worker](#3-حذف-ردیف‌های-room-و-فایل‌های-مدیا-در-worker)
4. [Storage Access Framework: ایجاد فایل](#4-storage-access-frameworkایجاد-فایل)
5. [ایجاد ZIP بکاپ از Room DB + مدیا](#5-ایجاد-zip-بکاپ-از-room-db--مدیا)
6. [ریستور از ZIP بکاپ](#6-ریستور-از-zip-بکاپ)
7. [اعمال SAF در AndroidManifest](#7-اعمال-saf-در-androidmanifest)

---

## 1. WorkManager: تنظیم PeriodicWorkRequest

### 1.1 مفاهیم پایه

WorkManager بخشی از AndroidX است و تضمین می‌کند که کارهای زمان‌بندی‌شده حتی پس از ریستارت دستگاه و بسته شدن اپلیکیشن اجرا شوند. برای NotTik از `PeriodicWorkRequest` استفاده می‌کنیم تا پاک‌سازی روزانه انجام شود.

**نکات کلیدی:**
- حداقل بازه زمانی `PeriodicWorkRequest` برابر ۱۵ دقیقه است
- WorkManager از `JobScheduler` (API 23+) یا `GCMNetworkManager` استفاده می‌کند
- هر کار باید یک **unique work name** داشته باشد تا از تداخل جلوگیری شود
- `PeriodicWorkRequest` قابل لغو و به‌روزرسانی است

### 1.2 تعریف Worker

```kotlin
package com.nottik.app.worker

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.nottik.app.db.AppDatabase
import java.io.File

class CleanupWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val retentionDays = inputData.getInt("retention_days", 30)
        val mediaCleanupEnabled = inputData.getBoolean("media_cleanup_enabled", true)

        return try {
            val db = AppDatabase.getInstance(applicationContext)
            val dao = db.notificationDao()

            // محاسبه زمان برش بر اساس دوره نگهداری
            val cutoffTime = System.currentTimeMillis() - (retentionDays * 24L * 60 * 60 * 1000)

            // حذف فایل‌های مدیا قبل از حذف ردیف‌ها
            if (mediaCleanupEnabled) {
                val orphanedFiles = dao.getMediaPathsOlderThan(cutoffTime)
                deleteMediaFiles(orphanedFiles)
            }

            // حذف ردیف‌های قدیمی از دیتابیس
            val deletedRecords = dao.deleteRecordsOlderThan(cutoffTime)
            val deletedRevisions = dao.deleteRevisionsOlderThan(cutoffTime)

            // لاگ نتیجه
            android.util.Log.i("CleanupWorker",
                "Cleaned up $deletedRecords records, $deletedRevisions revisions")

            Result.success()
        } catch (e: Exception) {
            android.util.Log.e("CleanupWorker", "Cleanup failed", e)
            Result.retry()
        }
    }

    private fun deleteMediaFiles(paths: List<String>) {
        val filesDir = applicationContext.filesDir
        for (relativePath in paths) {
            val file = File(filesDir, relativePath)
            if (file.exists() && file.isFile) {
                file.delete()
            }
        }
    }
}
```

### 1.3 ثبت PeriodicWorkRequest در Application یا MainActivity

```kotlin
package com.nottik.app

import android.content.Context
import androidx.work.*
import com.nottik.app.worker.CleanupWorker
import java.util.concurrent.TimeUnit

object WorkManagerScheduler {

    private const val UNIQUE_WORK_NAME = "nottik_daily_cleanup"

    /**
     * ثبت یا به‌روزرسانی کار دوره‌ای پاک‌سازی.
     * اگر کاری با همین نام وجود داشته باشد، جایگزین می‌شود.
     */
    fun scheduleDailyCleanup(
        context: Context,
        retentionDays: Int = 30,
        mediaCleanupEnabled: Boolean = true
    ) {
        val inputData = workDataOf(
            "retention_days" to retentionDays,
            "media_cleanup_enabled" to mediaCleanupEnabled
        )

        val constraints = Constraints.Builder()
            .setRequiresBatteryNotLow(true)  // فقط وقتی باتری کم نباشد
            .build()

        val periodicWorkRequest = PeriodicWorkRequestBuilder<CleanupWorker>(
            repeatInterval = 1,
            repeatIntervalTimeUnit = TimeUnit.DAYS
        )
            .setInputData(inputData)
            .setConstraints(constraints)
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                WorkRequest.MIN_BACKOFF_MILLIS,
                TimeUnit.MILLISECONDS
            )
            .build()

        // ExistingPeriodicWorkPolicy.UPDATE: اگر کار با همین نام موجود است،
        // با تنظیمات جدید به‌روزرسانی می‌شود
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            periodicWorkRequest
        )
    }

    /**
     * لغو کار دوره‌ای پاک‌سازی (وقتی کاربر پاک‌سازی خودکار را غیرفعال کند)
     */
    fun cancelDailyCleanup(context: Context) {
        WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
    }

    /**
     * بررسی وضعیت فعلی کار
     */
    fun getWorkStatus(
        context: Context,
        callback: (WorkInfo?) -> Unit
    ) {
        WorkManager.getInstance(context)
            .getWorkInfosForUniqueWorkLiveData(UNIQUE_WORK_NAME)
            .observeForever { workInfos ->
                val latest = workInfos?.lastOrNull()
                callback(latest)
            }
    }
}
```

### 1.4 تنظیم در Application Class

```kotlin
package com.nottik.app

import android.app.Application
import androidx.work.Configuration

class NottikApplication : Application(), Configuration.Provider {

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setMinimumLoggingLevel(android.util.Log.INFO)
            .build()

    override fun onCreate() {
        super.onCreate()
        // ثبت اولیه کار دوره‌ای با مقادیر پیش‌فرض
        WorkManagerScheduler.scheduleDailyCleanup(this)
    }
}
```

**نکته مهم درباره AndroidManifest:**

```xml
<application
    android:name=".NottikApplication"
    android:label="nottik"
    android:icon="@mipmap/ic_launcher">
    <!-- ... -->
</application>
```

### 1.5 گزینه‌های ExistingPeriodicWorkPolicy

| Policy | رفتار |
|--------|--------|
| `KEEP` | اگر کاری با همین نام در حال انتظار است، جدید نادیده گرفته می‌شود |
| `UPDATE` | کار قبلی لغو شده و کار جدید جایگزین آن می‌شود (توصیه شده برای NotTik) |
| `REPLACE` | (فقط برای OneTimeWorkRequest) مشابه UPDATE |

**برای NotTik:** از `UPDATE` استفاده می‌کنیم چون وقتی کاربر تنظیمات نگهداری را تغییر می‌دهد، باید کار با مقادیر جدید به‌روزرسانی شود.

---

## 2. پیکربندی و کنترل Work از Flutter

### 2.1 معماری ارتباطی

```
Flutter UI (Settings Screen)
    ↓  Pigeon API Call
MainActivity.kt (Pigeon Handler)
    ↓  Direct Kotlin Call
WorkManagerScheduler.scheduleDailyCleanup(context, retentionDays, mediaCleanupEnabled)
```

### 2.2 تعریف Pigeon Interface (Flutter Side)

```dart
// pigeon_schemas.dart — اضافه کردن متدهای جدید
import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class NativeNotificationApi {
  // متدهای موجود...
  bool isListenerConnected();
  void requestRebind();
  void openNotificationSettings();

  // متدهای جدید برای مدیریت WorkManager
  void scheduleCleanupWork(int retentionDays, bool mediaCleanupEnabled);
  void cancelCleanupWork();
  bool isCleanupWorkScheduled();
}
```

### 2.3 پیاده‌سازی در Kotlin (MainActivity)

```kotlin
// اضافه کردن به MainActivity.kt
override fun scheduleCleanupWork(retentionDays: Int, mediaCleanupEnabled: Boolean) {
    WorkManagerScheduler.scheduleDailyCleanup(
        context = this,
        retentionDays = retentionDays,
        mediaCleanupEnabled = mediaCleanupEnabled
    )
}

override fun cancelCleanupWork() {
    WorkManagerScheduler.cancelDailyCleanup(this)
}

override fun isCleanupWorkScheduled(): Boolean {
    // بررسی سینکرونی وضعیت کار
    val workInfos = WorkManager.getInstance(this)
        .getWorkInfosForUniqueWork(WorkManagerScheduler.UNIQUE_WORK_NAME)
        .get() // Blocking call — بهتر است async شود
    return workInfos.any { it.state == WorkInfo.State.ENQUEUED }
}
```

### 2.4 فراخوانی از Flutter (Settings Screen)

```dart
// lib/features/settings/presentation/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          // تنظیم دوره نگهداری
          ListTile(
            title: const Text('دوره نگهداری اعلان‌ها'),
            subtitle: const Text('مدت زمان نگهداری اعلان‌ها قبل از حذف خودکار'),
            trailing: const Text('۳۰ روز'),
            onTap: () => _showRetentionPicker(context),
          ),
          // فعال/غیرفعال کردن پاک‌سازی خودکار
          SwitchListTile(
            title: const Text('پاک‌سازی خودکار'),
            subtitle: const Text('حذف خودکار اعلان‌های قدیمی'),
            value: true,
            onChanged: (value) {
              if (value) {
                _scheduleCleanup(context);
              } else {
                _cancelCleanup(context);
              }
            },
          ),
          // دکمه‌های بکاپ و ریستور
          ListTile(
            title: const Text('ایجاد نسخه پشتیبان'),
            leading: const Icon(Icons.backup),
            onTap: () => _createBackup(context),
          ),
          ListTile(
            title: const Text('بازیابی از نسخه پشتیبان'),
            leading: const Icon(Icons.restore),
            onTap: () => _restoreBackup(context),
          ),
        ],
      ),
    );
  }

  void _scheduleCleanup(BuildContext context) {
    NativeNotificationApi().scheduleCleanupWork(30, true);
  }

  void _cancelCleanup(BuildContext context) {
    NativeNotificationApi().cancelCleanupWork();
  }

  void _showRetentionPicker(BuildContext context) {
    // نمایش دیالوگ انتخاب دوره نگهداری
  }

  void _createBackup(BuildContext context) {
    // باز کردن SAF file picker برای ذخیره بکاپ
  }

  void _restoreBackup(BuildContext context) {
    // باز کردن SAF file picker برای انتخاب فایل بکاپ
  }
}
```

### 2.5 جریان به‌روزرسانی تنظیمات

```
1. کاربر تنظیم «دوره نگهداری» را از ۳۰ به ۶۰ روز تغییر می‌دهد
2. Flutter → Pigeon → scheduleCleanupWork(60, true)
3. WorkManagerScheduler.scheduleDailyCleanup(context, 60, true)
4. enqueueUniquePeriodicWork("nottik_daily_cleanup", UPDATE, newRequest)
5. WorkManager کار قبلی را لغو و با تنظیمات جدید ثبت می‌کند
6. اجرای بعدی: CleanupWorker با retentionDays=60 اجرا می‌شود
```

### 2.6 نکات مهم درباره Pigeon و WorkManager

- **اتصال Pigeon با WorkManager نیاز به Application Context دارد.** `WorkManager.getInstance()` نیاز به context دارد اما Pigeon متدها از Activity فراخوانی می‌شوند. از `applicationContext` استفاده کنید.
- **بررسی وضعیت کار** بهتر است از `LiveData` یا `Flow` استفاده کند، نه `.get()` Blocking.
- **InputData در `PeriodicWorkRequest` هر بار اجرا خوانده می‌شود.** اگر تنظیمات تغییر کند، باید کار را با `UPDATE` جایگزین کنید.

---

## 3. حذف ردیف‌های Room و فایل‌های مدیا در Worker

### 3.1 اضافه کردن Query به DAO

```kotlin
// NotificationDao.kt — متدهای جدید
@Dao
interface NotificationDao {

    // متدهای موجود...

    /**
     * دریافت مسیر فایل‌های مدیای ردیف‌های قدیمی‌تر از یک زمان مشخص.
     * فرض: فایل‌ها در notification_revisions ذخیره شده‌اند.
     */
    @Query("""
        SELECT r.media_file_path 
        FROM notification_revisions r
        INNER JOIN notification_records p ON r.parent_record_id = p.id
        WHERE p.first_captured_time < :cutoffTime
        AND r.media_file_path IS NOT NULL
        AND r.media_file_path != ''
    """)
    suspend fun getMediaPathsOlderThan(cutoffTime: Long): List<String>

    /**
     * حذف ردیف‌های notification_records قدیمی‌تر از یک زمان مشخص.
     * با توجه به foreign key constraints، ابتدا باید revisions حذف شوند.
     */
    @Query("DELETE FROM notification_revisions WHERE parent_record_id IN (SELECT id FROM notification_records WHERE first_captured_time < :cutoffTime)")
    suspend fun deleteRevisionsOlderThan(cutoffTime: Long): Int

    @Query("DELETE FROM notification_records WHERE first_captured_time < :cutoffTime")
    suspend fun deleteRecordsOlderThan(cutoffTime: Long): Int

    /**
     * حذف تعداد کل ردیف‌ها برای آمارگیری
     */
    @Query("SELECT COUNT(*) FROM notification_records")
    suspend fun getTotalRecordCount(): Int

    @Query("SELECT COUNT(*) FROM notification_revisions")
    suspend fun getTotalRevisionCount(): Int
}
```

### 3.2 Worker با پشتیبانی از مدیا

```kotlin
class CleanupWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        val retentionDays = inputData.getInt("retention_days", 30)
        val mediaCleanupEnabled = inputData.getBoolean("media_cleanup_enabled", true)

        return try {
            val db = AppDatabase.getInstance(applicationContext)
            val dao = db.notificationDao()

            val cutoffTime = System.currentTimeMillis() - 
                (retentionDays * 24L * 60 * 60 * 1000)

            val beforeRecords = dao.getTotalRecordCount()
            val beforeRevisions = dao.getTotalRevisionCount()

            // مرحله ۱: حذف فایل‌های مدیا
            var deletedFiles = 0
            if (mediaCleanupEnabled) {
                val mediaPaths = dao.getMediaPathsOlderThan(cutoffTime)
                val filesDir = applicationContext.filesDir
                
                for (relativePath in mediaPaths) {
                    try {
                        val file = File(filesDir, relativePath)
                        if (file.exists() && file.isFile) {
                            if (file.delete()) {
                                deletedFiles++
                            }
                        }
                    } catch (e: Exception) {
                        android.util.Log.w("CleanupWorker", 
                            "Failed to delete media file: $relativePath", e)
                        // ادامه بده — حذف فایل منفرد نباید کل عملیات را متوقف کند
                    }
                }
            }

            // مرحله ۲: حذف revisions قدیمی
            val deletedRevisions = dao.deleteRevisionsOlderThan(cutoffTime)
            
            // مرحله ۳: حذف records قدیمی
            val deletedRecords = dao.deleteRecordsOlderThan(cutoffTime)

            val afterRecords = dao.getTotalRecordCount()
            val afterRevisions = dao.getTotalRevisionCount()

            android.util.Log.i("CleanupWorker", """
                Cleanup complete:
                  - Records: $beforeRecords → $afterRecords (deleted $deletedRecords)
                  - Revisions: $beforeRevisions → $afterRevisions (deleted $deletedRevisions)
                  - Media files deleted: $deletedFiles
            """.trimIndent())

            // ذخیره نتیجه برای نمایش به کاربر (اختیاری)
            val outputData = workDataOf(
                "deleted_records" to deletedRecords,
                "deleted_revisions" to deletedRevisions,
                "deleted_files" to deletedFiles
            )

            Result.success(outputData)
        } catch (e: Exception) {
            android.util.Log.e("CleanupWorker", "Cleanup failed", e)
            Result.retry()
        }
    }
}
```

### 3.3 ملاحظات حیاتی

- **ترتیب حذف:** ابتدا فایل‌های مدیا، سپس revisions، سپس records. اگر records را اول حذف کنیم، دیگر نمی‌توانیم path فایل‌ها را پیدا کنیم.
- **Error Handling:** حذف فایل منفرد نباید کل Worker را متوقف کند. از try-catch داخل حلقه استفاده کنید.
- **Batch Operations:** اگر تعداد ردیف‌ها خیلی زیاد است، عملیات را به دسته‌های ۱۰۰ تایی تقسیم کنید تا Memory overflow نشود.
- **Atomicity:** Room به‌طور پیش‌فرض از Foreign Key cascading استفاده نمی‌کند مگر اینکه در `@Entity` تعریف شده باشد. بنابراین حذف دستی لازم است.

### 3.4 Database Builder با Factory (برای WorkManager)

```kotlin
package com.nottik.app.db

import android.content.Context
import androidx.room.Room

object AppDatabaseBuilder {
    
    private const val DATABASE_NAME = "nottik_database"
    
    @Volatile
    private var instance: AppDatabase? = null

    fun getInstance(context: Context): AppDatabase {
        return instance ?: synchronized(this) {
            instance ?: buildDatabase(context).also { instance = it }
        }
    }

    private fun buildDatabase(context: Context): AppDatabase {
        return Room.databaseBuilder(
            context.applicationContext,  // مهم: applicationContext نه activity
            AppDatabase::class.java,
            DATABASE_NAME
        )
        .fallbackToDestructiveMigration()
        .build()
    }
}
```

**نکته:** در Worker باید از `applicationContext` استفاده کنید چون lifecycle از Activity متفاوت است.

---

## 4. Storage Access Framework: ایجاد فایل

### 4.1 مفاهیم SAF

Storage Access Framework (SAF) یک API اندروید است که به کاربر اجازه می‌دهد فایل‌ها و پوشه‌ها را از طریق فایل‌سیستم انتخاب یا ذخیره کند. مزایا:
- نیازی به مجوز `READ_EXTERNAL_STORAGE` یا `WRITE_EXTERNAL_STORAGE` ندارد
- کاربر کنترل کامل دارد روی اینکه اپ به کدام پوشه‌ها دسترسی دارد
- با Scoped Storage سازگار است
- امتیازات از نو تأیید نمی‌شوند

### 4.2 ایجاد فایل JSON Export

```kotlin
package com.nottik.app.export

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.google.gson.GsonBuilder
import com.nottik.app.db.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class JsonExporter(private val activity: Activity) {

    /**
     * باز کردن SAF picker برای ذخیره فایل JSON.
     */
    fun launchJsonExport() {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, "nottik_export_${System.currentTimeMillis()}.json")
        }
        activity.startActivityForResult(intent, REQUEST_CODE_JSON_EXPORT)
    }

    /**
     * پردازش نتیجه SAF و نوشتن فایل JSON.
     * این متد در onActivityResult فراخوانی می‌شود.
     */
    suspend fun handleJsonExportResult(uri: Uri) = withContext(Dispatchers.IO) {
        val db = AppDatabase.getInstance(activity.applicationContext)
        val records = db.notificationDao().getAllRecordsWithRevisions()
        
        val exportData = ExportData(
            exportDate = System.currentTimeMillis(),
            appVersion = "1.0.0",
            records = records.map { ExportRecord.from(it) }
        )

        val gson = GsonBuilder()
            .setPrettyPrinting()
            .create()
        val json = gson.toJson(exportData)

        activity.contentResolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(json.toByteArray(Charsets.UTF_8))
        }
    }

    companion object {
        const val REQUEST_CODE_JSON_EXPORT = 1001
    }
}

// مدل‌های داده برای اکسپورت
data class ExportData(
    val exportDate: Long,
    val appVersion: String,
    val records: List<ExportRecord>
)

data class ExportRecord(
    val packageName: String,
    val notificationId: Int,
    val tag: String?,
    val postTime: Long,
    val revisions: List<ExportRevision>
) {
    companion object {
        fun from(recordWithRevisions: RecordWithRevisions): ExportRecord {
            return ExportRecord(
                packageName = recordWithRevisions.record.packageName,
                notificationId = recordWithRevisions.record.notificationId,
                tag = recordWithRevisions.record.tag,
                postTime = recordWithRevisions.record.postTime,
                revisions = recordWithRevisions.revisions.map { rev ->
                    ExportRevision(
                        captureTimestamp = rev.captureTimestamp,
                        title = rev.title,
                        text = rev.text,
                        category = rev.category
                    )
                }
            )
        }
    }
}

data class ExportRevision(
    val captureTimestamp: Long,
    val title: String?,
    val text: String?,
    val category: String?
)
```

### 4.3 ایجاد فایل CSV Export

```kotlin
package com.nottik.app.export

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.nottik.app.db.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.OutputStreamWriter

class CsvExporter(private val activity: Activity) {

    fun launchCsvExport() {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "text/csv"
            putExtra(Intent.EXTRA_TITLE, "nottik_export_${System.currentTimeMillis()}.csv")
        }
        activity.startActivityForResult(intent, REQUEST_CODE_CSV_EXPORT)
    }

    suspend fun handleCsvExportResult(uri: Uri) = withContext(Dispatchers.IO) {
        val db = AppDatabase.getInstance(activity.applicationContext)
        val dao = db.notificationDao()
        val records = dao.getAllRecordsWithRevisions()

        activity.contentResolver.openOutputStream(uri)?.use { outputStream ->
            val writer = OutputStreamWriter(outputStream, Charsets.UTF_8)
            
            // Header
            writer.write("Package Name,Notification ID,Tag,Post Time,Title,Text,Category,Capture Time\n")

            // Data rows
            for (recordWithRevisions in records) {
                val record = recordWithRevisions.record
                for (revision in recordWithRevisions.revisions) {
                    val line = listOf(
                        escapeCsv(record.packageName),
                        record.notificationId.toString(),
                        escapeCsv(record.tag ?: ""),
                        record.postTime.toString(),
                        escapeCsv(revision.title ?: ""),
                        escapeCsv(revision.text ?: ""),
                        escapeCsv(revision.category ?: ""),
                        revision.captureTimestamp.toString()
                    ).joinToString(",")
                    writer.write("$line\n")
                }
            }

            writer.flush()
        }
    }

    private fun escapeCsv(value: String): String {
        return if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            "\"${value.replace("\"", "\"\"")}\""
        } else {
            value
        }
    }

    companion object {
        const val REQUEST_CODE_CSV_EXPORT = 1002
    }
}
```

### 4.4 ادغام SAF در MainActivity

```kotlin
override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    
    if (resultCode != Activity.RESULT_OK || data?.data == null) return
    
    val uri = data.data!!

    when (requestCode) {
        JsonExporter.REQUEST_CODE_JSON_EXPORT -> {
            lifecycleScope.launch {
                JsonExporter(this@MainActivity).handleJsonExportResult(uri)
            }
        }
        CsvExporter.REQUEST_CODE_CSV_EXPORT -> {
            lifecycleScope.launch {
                CsvExporter(this@MainActivity).handleCsvExportResult(uri)
            }
        }
        ZipBackupCreator.REQUEST_CODE_ZIP_EXPORT -> {
            lifecycleScope.launch {
                ZipBackupCreator(this@MainActivity).handleZipExportResult(uri)
            }
        }
        ZipBackupRestorer.REQUEST_CODE_ZIP_IMPORT -> {
            lifecycleScope.launch {
                ZipBackupRestorer(this@MainActivity).handleZipImportResult(uri)
            }
        }
    }
}
```

### 4.5 نکات SAF

- **`ACTION_CREATE_DOCUMENT`** برای ایجاد فایل جدید استفاده می‌شود
- **`ACTION_OPEN_DOCUMENT`** برای انتخاب فایل موجود استفاده می‌شود
- **`CATEGORY_OPENABLE`** فقط فایل‌های قابل بازشدن را نشان می‌دهد
- **`type`** (MIME type) تعیین می‌کند چه فایل‌هایی نشان داده شوند
- **Persistence:** امتیاز SAF فقط برای یک session معتبر است. برای دسترسی دائمی باید از `takePersistableUriPermission` استفاده کنید

---

## 5. ایجاد ZIP بکاپ از Room DB + مدیا

### 5.1 ساختار فایل ZIP

```
nottik_backup_20260709_123456.zip
├── backup_manifest.json        # اطلاعات متادیتای بکاپ
├── nottik_database.db          # کپی فایل دیتابیس Room
├── nottik_database.db-shm      # WAL shared memory (اگر WAL mode فعال باشد)
├── nottik_database.db-wal      # WAL journal (اگر WAL mode فعال باشد)
└── media/                      # فایل‌های مدیا
    ├── img_001.webp
    ├── img_002.jpeg
    └── ...
```

### 5.2 manifest فایل بکاپ

```kotlin
data class BackupManifest(
    val backupDate: Long,
    val appVersion: String,
    val databaseVersion: Int,
    val totalRecords: Int,
    val totalRevisions: Int,
    val mediaFileCount: Int,
    val checksum: String  // SHA-256 of the DB file
)
```

### 5.3 ایجاد ZIP با Java ZipOutputStream

```kotlin
package com.nottik.app.backup

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.nottik.app.db.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.*
import java.security.MessageDigest
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class ZipBackupCreator(private val activity: Activity) {

    companion object {
        private const val TAG = "ZipBackupCreator"
        const val REQUEST_CODE_ZIP_EXPORT = 1003
        private const val BUFFER_SIZE = 8192
    }

    fun launchZipExport() {
        val timestamp = java.text.SimpleDateFormat(
            "yyyyMMdd_HHmmss", java.util.Locale.US
        ).format(java.util.Date())

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/zip"
            putExtra(Intent.EXTRA_TITLE, "nottik_backup_$timestamp.zip")
        }
        activity.startActivityForResult(intent, REQUEST_CODE_ZIP_EXPORT)
    }

    suspend fun handleZipExportResult(uri: Uri) = withContext(Dispatchers.IO) {
        val db = AppDatabase.getInstance(activity.applicationContext)
        val dao = db.notificationDao()

        // غیرفعال کردن WAL checkpoint قبل از کپی دیتابیس
        // تا از صحت فایل DB اطمینان حاصل شود
        
        val recordsCount = dao.getTotalRecordCount()
        val revisionsCount = dao.getTotalRevisionCount()

        activity.contentResolver.openOutputStream(uri)?.use { outputStream ->
            ZipOutputStream(BufferedOutputStream(outputStream)).use { zipOut ->
                
                // مرحله ۱: اضافه کردن دیتابیس Room
                val dbPath = activity.getDatabasePath("nottik_database")
                val dbShmPath = File(dbPath.path + "-shm")
                val dbWalPath = File(dbPath.path + "-wal")
                
                // محاسبه checksum دیتابیس
                val dbChecksum = calculateSHA256(dbPath)
                
                addFileToZip(zipOut, dbPath, "nottik_database.db")
                if (dbShmPath.exists()) {
                    addFileToZip(zipOut, dbShmPath, "nottik_database.db-shm")
                }
                if (dbWalPath.exists()) {
                    addFileToZip(zipOut, dbWalPath, "nottik_database.db-wal")
                }

                // مرحله ۲: اضافه کردن فایل‌های مدیا
                val filesDir = activity.filesDir
                var mediaCount = 0
                if (filesDir.exists() && filesDir.isDirectory) {
                    filesDir.listFiles()?.forEach { file ->
                        if (file.isFile && isMediaFile(file.name)) {
                            addFileToZip(zipOut, file, "media/${file.name}")
                            mediaCount++
                        }
                    }
                }

                // مرحله ۳: ایجاد و اضافه کردن manifest
                val manifest = BackupManifest(
                    backupDate = System.currentTimeMillis(),
                    appVersion = activity.packageManager
                        .getPackageInfo(activity.packageName, 0)
                        .versionName ?: "unknown",
                    databaseVersion = 1, // از Room version بخوانید
                    totalRecords = recordsCount,
                    totalRevisions = revisionsCount,
                    mediaFileCount = mediaCount,
                    checksum = dbChecksum
                )
                
                val manifestJson = com.google.gson.Gson()
                    .toJson(manifest)
                val manifestBytes = manifestJson.toByteArray(Charsets.UTF_8)
                zipOut.putNextEntry(ZipEntry("backup_manifest.json"))
                zipOut.write(manifestBytes)
                zipOut.closeEntry()

                Log.i(TAG, "Backup created: $recordsCount records, " +
                    "$revisionsCount revisions, $mediaCount media files")
            }
        }
    }

    private fun addFileToZip(zipOut: ZipOutputStream, file: File, entryName: String) {
        zipOut.putNextEntry(ZipEntry(entryName))
        FileInputStream(file).use { input ->
            val buffer = ByteArray(BUFFER_SIZE)
            var bytesRead: Int
            while (input.read(buffer).also { bytesRead = it } != -1) {
                zipOut.write(buffer, 0, bytesRead)
            }
        }
        zipOut.closeEntry()
    }

    private fun isMediaFile(fileName: String): Boolean {
        return fileName.endsWith(".webp", ignoreCase = true) ||
            fileName.endsWith(".jpeg", ignoreCase = true) ||
            fileName.endsWith(".jpg", ignoreCase = true) ||
            fileName.endsWith(".png", ignoreCase = true) ||
            fileName.endsWith(".gif", ignoreCase = true)
    }

    private fun calculateSHA256(file: File): String {
        val digest = MessageDigest.getInstance("SHA-256")
        FileInputStream(file).use { input ->
            val buffer = ByteArray(BUFFER_SIZE)
            var bytesRead: Int
            while (input.read(buffer).also { bytesRead = it } != -1) {
                digest.update(buffer, 0, bytesRead)
            }
        }
        return digest.digest().joinToString("") { "%02x".format(it) }
    }
}
```

### 5.4 نکات حیاتی ایجاد بکاپ

- **Wal Checkpoint:** قبل از کپی فایل دیتابیس، بهتر است WAL checkpoint انجام شود تا همه تغییرات به فایل اصلی نوشته شوند. در Room می‌توان از `PRAGMA wal_checkpoint(TRUNCATE)` استفاده کرد.
- **File Lock:** دیتابیس Room هنگام اجرا قفل است. کپی مستقیم فایل `.db` در حالی که Room فعال است می‌تواند باعث خرابی شود. راه‌حل: checkpoint کردن WAL یا کپی از کوئری‌ها به جای فایل خام.
- **alternatives approach:** به جای کپی فایل خام DB، می‌توانید از query برای خواندن همه داده‌ها و سپس نوشتن به JSON استفاده کنید. این روش ایمن‌تر است.

### 5.5 روش ایمن‌تر: Export از طریق Query

```kotlin
/**
 * روش ایمن‌تر: خواندن داده از Room و نوشتن در JSON داخل ZIP
 * این روش مشکل file locking را دور می‌زند.
 */
suspend fun createSafeBackup(uri: Uri) = withContext(Dispatchers.IO) {
    val db = AppDatabase.getInstance(activity.applicationContext)
    val dao = db.notificationDao()

    activity.contentResolver.openOutputStream(uri)?.use { outputStream ->
        ZipOutputStream(BufferedOutputStream(outputStream)).use { zipOut ->
            
            // خواندن همه داده‌ها از Room
            val records = dao.getAllRecordsWithRevisions()
            val exportData = ExportData(
                exportDate = System.currentTimeMillis(),
                appVersion = "1.0.0",
                records = records.map { ExportRecord.from(it) }
            )
            
            // نوشتن JSON در ZIP
            val jsonData = com.google.gson.GsonBuilder()
                .setPrettyPrinting()
                .create()
                .toJson(exportData)
            
            zipOut.putNextEntry(ZipEntry("database.json"))
            zipOut.write(jsonData.toByteArray(Charsets.UTF_8))
            zipOut.closeEntry()

            // کپی فایل‌های مدیا
            val filesDir = activity.filesDir
            filesDir.listFiles()?.forEach { file ->
                if (file.isFile && isMediaFile(file.name)) {
                    addFileToZip(zipOut, file, "media/${file.name}")
                }
            }
        }
    }
}
```

---

## 6. ریستور از ZIP بکاپ

### 6.1 اعتبارسنجی فایل بکاپ

```kotlin
package com.nottik.app.backup

import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.google.gson.Gson
import com.nottik.app.db.AppDatabase
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.*
import java.util.zip.ZipInputStream

class ZipBackupRestorer(private val activity: Activity) {

    companion object {
        private const val TAG = "ZipBackupRestorer"
        const val REQUEST_CODE_ZIP_IMPORT = 1004
        private const val BUFFER_SIZE = 8192
    }

    fun launchZipImport() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/zip"
        }
        activity.startActivityForResult(intent, REQUEST_CODE_ZIP_IMPORT)
    }

    /**
     * خلاصه نتیجه ریستور برای نمایش به کاربر
     */
    data class RestoreResult(
        val success: Boolean,
        val message: String,
        val recordsRestored: Int = 0,
        val mediaFilesRestored: Int = 0
    )

    suspend fun handleZipImportResult(uri: Uri): RestoreResult = 
        withContext(Dispatchers.IO) {
        
        try {
            val filesDir = activity.filesDir
            
            // مرحله ۱: استخراج فایل‌ها به موقت و اعتبارسنجی
            val tempDir = File(activity.cacheDir, "restore_temp")
            if (tempDir.exists()) tempDir.deleteRecursively()
            tempDir.mkdirs()

            var manifest: BackupManifest? = null
            var recordsFromJson: List<ExportRecord>? = null
            val mediaFiles = mutableMapOf<String, ByteArray>()

            activity.contentResolver.openInputStream(uri)?.use { inputStream ->
                ZipInputStream(BufferedInputStream(inputStream)).use { zipIn ->
                    var entry = zipIn.nextEntry
                    while (entry != null) {
                        val entryName = entry.name
                        val tempFile = File(tempDir, entryName)
                        
                        // ایجاد دایرکتوری والد اگر لازم باشد
                        tempFile.parentFile?.mkdirs()
                        
                        // خواندن محتوا
                        val bytes = zipIn.readBytes()
                        
                        when {
                            entryName == "backup_manifest.json" -> {
                                manifest = Gson().fromJson(
                                    String(bytes, Charsets.UTF_8),
                                    BackupManifest::class.java
                                )
                            }
                            entryName == "database.json" -> {
                                recordsFromJson = Gson().fromJson(
                                    String(bytes, Charsets.UTF_8),
                                    Array<ExportRecord>::class.java
                                ).toList()
                            }
                            entryName.startsWith("media/") -> {
                                val fileName = entryName.removePrefix("media/")
                                mediaFiles[fileName] = bytes
                            }
                            // پشتیبانی از فرمت قدیمی (فایل خام DB)
                            entryName == "nottik_database.db" -> {
                                // ریستور از فایل خام DB
                                // پیچیده‌تر — نیاز به close کردن Room و جایگزینی فایل
                            }
                        }
                        
                        zipIn.closeEntry()
                        entry = zipIn.nextEntry
                    }
                }
            }

            // مرحله ۲: اعتبارسنجی
            if (manifest == null) {
                tempDir.deleteRecursively()
                return@withContext RestoreResult(
                    success = false,
                    message = "فایل بکاپ معتبر نیست: manifest یافت نشد"
                )
            }

            // مرحله ۳: بازیابی داده‌ها
            if (recordsFromJson != null) {
                val db = AppDatabase.getInstance(activity.applicationContext)
                val dao = db.notificationDao()

                var recordsRestored = 0
                var mediaRestored = 0

                for (exportRecord in recordsFromJson!!) {
                    // بررسی تکراری نبودن
                    val existing = dao.getRecordByOriginalIdentity(
                        exportRecord.packageName,
                        exportRecord.notificationId,
                        exportRecord.tag
                    )

                    if (existing != null) {
                        // ردیف موجود — فقط اگر جدیدتر باشد، جایگزین کن
                        // یا نادیده بگیر (بسته به سیاست)
                        continue
                    }

                    // ایجاد ردیف جدید
                    val record = NotificationRecord(
                        notificationKey = "${exportRecord.packageName}:${exportRecord.notificationId}",
                        packageName = exportRecord.packageName,
                        notificationId = exportRecord.notificationId,
                        tag = exportRecord.tag,
                        postTime = exportRecord.postTime,
                        firstCapturedTime = exportRecord.postTime,
                        isRemoved = false
                    )
                    val recordId = dao.insertRecord(record)

                    // اضافه کردن revisions
                    for (exportRevision in exportRecord.revisions) {
                        val revision = NotificationRevision(
                            parentRecordId = recordId,
                            captureTimestamp = exportRevision.captureTimestamp,
                            contentHash = "", // hash مجدداً محاسبه می‌شود
                            title = exportRevision.title,
                            text = exportRevision.text,
                            category = exportRevision.category
                        )
                        dao.insertRevision(revision)
                    }

                    recordsRestored++
                }

                // مرحله ۴: بازیابی فایل‌های مدیا
                for ((fileName, fileBytes) in mediaFiles) {
                    val targetFile = File(filesDir, fileName)
                    FileOutputStream(targetFile).use { output ->
                        output.write(fileBytes)
                    }
                    mediaRestored++
                }

                // پاکسازی
                tempDir.deleteRecursively()

                return@withContext RestoreResult(
                    success = true,
                    message = "بازیابی موفق: $recordsRestored اعلان و " +
                        "$mediaRestored فایل مدیا بازیابی شد",
                    recordsRestored = recordsRestored,
                    mediaFilesRestored = mediaRestored
                )
            }

            tempDir.deleteRecursively()
            return@withContext RestoreResult(
                success = false,
                message = "فرمت فایل بکاپ پشتیبانی نمی‌شود"
            )

        } catch (e: Exception) {
            Log.e(TAG, "Restore failed", e)
            return@withContext RestoreResult(
                success = false,
                message = "خطا در بازیابی: ${e.message}"
            )
        }
    }
}
```

### 6.2 ریستور از فایل خام DB (روش پیشرفته و خطرناک)

```kotlin
/**
 * ⚠️ هشدار: این روش Room را متوقف می‌کند و فایل دیتابیس را جایگزین می‌کند.
 * فقط در صورتی استفاده کنید که بکاپ از همین دستگاه با همین نسخه اپ باشد.
 */
suspend fun restoreFromRawDbBackup(
    dbBackupUri: Uri,
    shmBytes: ByteArray?,
    walBytes: ByteArray?
) = withContext(Dispatchers.IO) {
    // ۱. Room را متوقف کنید
    AppDatabase.getInstance(activity.applicationContext).close()
    
    // ۲. فایل دیتابیس فعلی را پشتیبان بگیرید
    val currentDb = activity.getDatabasePath("nottik_database")
    val backupOfCurrent = File(currentDb.path + ".backup_before_restore")
    currentDb.copyTo(backupOfCurrent, overwrite = true)
    
    // ۳. فایل جایگزین را بنویسید
    activity.contentResolver.openInputStream(dbBackupUri)?.use { input ->
        FileOutputStream(currentDb).use { output ->
            input.copyTo(output)
        }
    }
    
    // ۴. فایل‌های WAL و SHM را بازنویسی کنید
    if (shmBytes != null) {
        val shmFile = File(currentDb.path + "-shm")
        shmFile.writeBytes(shmBytes)
    }
    if (walBytes != null) {
        val walFile = File(currentDb.path + "-wal")
        walFile.writeBytes(walBytes)
    }
    
    // ۵. Room را دوباره باز کنید (با همان DB builder)
    AppDatabase.getInstance(activity.applicationContext)
}
```

**توصیه برای NotTik:** از روش JSON-based restore استفاده کنید. ایمن‌تر و cross-version سازگارتر است.

### 6.3 ملاحظات ریستور

- **نسخه دیتابیس:** اگر نسخه اپ بکاپ با نسخه فعلی متفاوت باشد، ممکن است schema تغییر کرده باشد. فیلدهای JSON ممکن است ناقص باشند.
- **Identity Constraint:** قبل از درج، بررسی کنید آیا ردیف تکراری وجود دارد یا نه.
- **Media Files:** اگر فایل مدیا از قبل وجود دارد، می‌توانید skip کنید یا overwrite کنید.
- **Transaction:** همه درج‌ها را در یک `@Transaction` قرار دهید تا اگر خطایی رخ داد، همه چیز rollback شود.

---

## 7. اعمال SAF در AndroidManifest

### 7.1 نکته مهم: SAF نیازی به مجوز خاصی ندارد!

SAF نیازی به `READ_EXTERNAL_STORAGE` یا `WRITE_EXTERNAL_STORAGE` ندارد. این یکی از بزرگ‌ترین مزایای آن است. فقط کافی است `Intent`‌های درست را ارسال کنید:

```xml
<!-- AndroidManifest.xml فعلی — نیازی به تغییر برای SAF نیست -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- اگر می‌خواهید فایل‌های بکاپ را به اشتراک بگذارید (اختیاری): -->
    <application
        android:label="nottik"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- ... existing activities and services ... -->
        
        <!-- Activity اشتراک‌گذاری فایل بکاپ (اختیاری) -->
        <activity
            android:name=".ExportShareActivity"
            android:exported="true"
            android:label="اشتراک‌گذاری بکاپ">
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="application/zip" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.SEND" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:mimeType="application/json" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 7.2 دسترسی‌های اضافی برای کپی دیتابیس (اگر لازم باشد)

```xml
<!-- اگر می‌خواهید فایل دیتابیس را مستقیماً از /data/data بخوانید،
     مجوز خاصی لازم نیست چون در فضای اختصاصی اپ است.
     اما اگر بخواهید فایل بکاپ را در Downloads ذخیره کنید: -->
     
<!-- از API 29 به بعد این مجوز محدود شده و برای SAF نیاز نیست -->
```

### 7.3 Package Visibility برای Export Activity

```xml
<!-- اگر از Package Visibility برای اشتراک‌گذاری استفاده می‌کنید -->
<queries>
    <intent>
        <action android:name="android.intent.action.PROCESS_TEXT"/>
        <data android:mimeType="text/plain"/>
    </intent>
    <!-- برای اشتراک‌گذاری فایل بکاپ با اپ‌های دیگر -->
    <intent>
        <action android:name="android.intent.action.SEND" />
        <data android:mimeType="application/zip" />
    </intent>
    <intent>
        <action android:name="android.intent.action.SEND" />
        <data android:mimeType="application/json" />
    </intent>
</queries>
```

### 7.4 WorkManager و Foreground Service

```xml
<!-- اگر Worker نیاز به اجرا به عنوان Foreground Service دارد (اختیاری) -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

<!-- ⚠️ نکته: برای NotTik cleanup ساده، Foreground Service لازم نیست.
     WorkManager به تنهایی کافی است. -->
```

### 7.5 خلاصه مجوزها

| نیاز | مجوز | لازم برای NotTik؟ |
|------|------|--------------------|
| SAF: ایجاد فایل | هیچ (فقط Intent) | ✅ بله |
| SAF: انتخاب فایل | هیچ (فقط Intent) | ✅ بله |
| Room DB در فضای اپ | هیچ (داخل /data/data) | ✅ بله |
| WorkManager | هیچ (runtime) | ✅ بله |
| اشتراک‌گذاری فایل | هیچ (فقط Intent) | اختیاری |
| اینترنت | `INTERNET` | ❌ خیر (اپ offline) |
| حافظه خارجی | `READ/WRITE_EXTERNAL_STORAGE` | ❌ خیر |

---

## خلاصه پیشنهادات اجرایی برای NotTik

### فاز ۱: WorkManager Cleanup
1. اضافه کردن `CleanupWorker.kt` و `WorkManagerScheduler.kt`
2. اضافه کردن متدهای DAO برای حذف
3. ثبت در `NottikApplication` یا `MainActivity`
4. اضافه کردن Pigeon API برای کنترل از Flutter
5. اضافه کردن صفحه تنظیمات در Flutter

### فاز ۲: Backup/Restore
1. اضافه کردن `ZipBackupCreator.kt` (روش JSON-based)
2. اضافه کردن `ZipBackupRestorer.kt`
3. اضافه کردن `JsonExporter.kt` و `CsvExporter.kt` (اختیاری)
4. اضافه کردن Pigeon API برای export/import
5. اضافه کردن UI در صفحه تنظیمات

### وابستگی‌ها (build.gradle.kts)
```kotlin
// WorkManager قبلاً اضافه شده ✅
implementation("androidx.work:work-runtime-ktx:2.9.0")

// Gson قبلاً اضافه شده ✅  
implementation("com.google.code.gson:gson:2.10.1")

// نیاز جدید: Core KTX (برای extension functions)
implementation("androidx.core:core-ktx:1.12.0")

// نیاز جدید: Lifecycle Runtime KTX (برای lifecycleScope)
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
```

### ریسک‌ها و محدودیت‌ها

| ریسک | شدت | راه‌حل |
|------|------|--------|
| OEM battery savers ممکن است WorkManager را محدود کنند | متوسط | راهنمای کاربر برای غیرفعال کردن بهینه‌سازی باتری |
| WAL checkpoint قبل از کپی DB ممکن است فشار I/O ایجاد کند | کم | انجام در پس‌زمینه با کوئری |
| ریستور از نسخه اپ قدیمی‌تر ممکن است schema mismatch داشته باشد | متوسط | Migration logic در ریستور |
| فایل‌های بکاپ ZIP ممکن است بزرگ باشند (تصاویر زیاد) | کم | فشرده‌سازی + اطلاع به کاربر |

---

## منابع

- [WorkManager Overview](https://developer.android.com/topic/libraries/architecture/workmanager)
- [PeriodicWorkRequest](https://developer.android.com/reference/kotlin/androidx/work/PeriodicWorkRequestBuilder)
- [ExistingPeriodicWorkPolicy](https://developer.android.com/reference/kotlin/androidx/work/ExistingPeriodicWorkPolicy)
- [Storage Access Framework](https://developer.android.com/guide/providers/document-provider)
- [ACTION_CREATE_DOCUMENT](https://developer.android.com/reference/android/content/Intent#ACTION_CREATE_DOCUMENT)
- [Room Database](https://developer.android.com/training/data-storage/room)
- [Room + WorkManager Integration](https://developer.android.com/topic/libraries/architecture/room)
