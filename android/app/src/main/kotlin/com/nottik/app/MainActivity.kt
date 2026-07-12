package com.nottik.app

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.nottik.app.bridge.*
import com.nottik.app.db.AppDatabase
import com.nottik.app.service.NottikNotificationListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.*

import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.nottik.app.worker.CleanupWorker
import com.nottik.app.utils.NativeLogger
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity(), NotificationBridge {
    private val scope = CoroutineScope(Dispatchers.Main + Job())
    private lateinit var database: AppDatabase

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeLogger.init(applicationContext)
        NativeLogger.info("MainActivity", "Flutter Engine configured")
        
        NotificationBridge.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
        database = AppDatabase.getDatabase(applicationContext)
        
        // Schedule daily cleanup
        val cleanupRequest = PeriodicWorkRequestBuilder<CleanupWorker>(1, TimeUnit.DAYS)
            .build()
        WorkManager.getInstance(applicationContext).enqueueUniquePeriodicWork(
            "DailyCleanup",
            ExistingPeriodicWorkPolicy.KEEP,
            cleanupRequest
        )
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }

    override fun isListenerConnected(): Boolean {
        val packageNames = NotificationManagerCompat.getEnabledListenerPackages(this)
        return packageNames.contains(packageName)
    }

    override fun openListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    override fun requestRebind() {
        val component = ComponentName(this, NottikNotificationListener::class.java)
        packageManager.setComponentEnabledSetting(
            component,
            android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            android.content.pm.PackageManager.DONT_KILL_APP
        )
        packageManager.setComponentEnabledSetting(
            component,
            android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            android.content.pm.PackageManager.DONT_KILL_APP
        )
    }

    override fun getListenerDiagnostics(callback: (Result<ListenerDiagnostics>) -> Unit) {
        val diag = ListenerDiagnostics(
            isRunning = NottikNotificationListener.isRunning,
            hasError = NottikNotificationListener.lastError != null,
            errorMessage = NottikNotificationListener.lastError
        )
        callback(Result.success(diag))
    }

    override fun getLatestHistory(
        offset: Long,
        limit: Long,
        searchQuery: String?,
        category: String?,
        callback: (Result<PaginatedResult>) -> Unit
    ) {
        scope.launch {
            try {
                val records = withContext(Dispatchers.IO) {
                    database.notificationDao().getHistoryPaginated(offset, limit, searchQuery, category)
                }
                
                val result = PaginatedResult(
                    items = records.map {
                        NativeNotificationRecord(
                            id = it.id,
                            notificationKey = it.notificationKey,
                            packageName = it.packageName,
                            appName = it.appName,
                            notificationId = it.notificationId.toLong(),
                            tag = it.tag,
                            postTime = it.postTime,
                            firstCapturedTime = it.firstCapturedTime,
                            lastUpdateTime = it.lastUpdateTime,
                            groupKey = it.groupKey,
                            channelId = it.channelId,
                            priority = it.priority.toLong(),
                            visibility = it.visibility.toLong(),
                            isOngoing = it.isOngoing,
                            isClearable = it.isClearable,
                            isGroupSummary = it.isGroupSummary,
                            isRemoved = it.isRemoved,
                            removalReason = it.removalReason?.toLong()
                        )
                    },
                    hasMore = records.size == limit.toInt()
                )
                callback(Result.success(result))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getRecordDetails(
        id: Long,
        callback: (Result<NativeNotificationRecord?>) -> Unit
    ) {
        scope.launch {
            try {
                val detail = withContext(Dispatchers.IO) {
                    database.notificationDao().getRecordById(id)
                }
                
                if (detail == null) {
                    callback(Result.success(null))
                    return@launch
                }
                
                callback(Result.success(NativeNotificationRecord(
                    id = detail.id,
                    notificationKey = detail.notificationKey,
                    packageName = detail.packageName,
                    appName = detail.appName,
                    notificationId = detail.notificationId.toLong(),
                    tag = detail.tag,
                    postTime = detail.postTime,
                    firstCapturedTime = detail.firstCapturedTime,
                    lastUpdateTime = detail.lastUpdateTime,
                    groupKey = detail.groupKey,
                    channelId = detail.channelId,
                    priority = detail.priority.toLong(),
                    visibility = detail.visibility.toLong(),
                    isOngoing = detail.isOngoing,
                    isClearable = detail.isClearable,
                    isGroupSummary = detail.isGroupSummary,
                    isRemoved = detail.isRemoved,
                    removalReason = detail.removalReason?.toLong()
                )))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getRevisions(
        recordId: Long,
        callback: (Result<List<NativeNotificationRevision?>>) -> Unit
    ) {
        scope.launch {
            try {
                val revisions = withContext(Dispatchers.IO) {
                    database.notificationDao().getRevisionsByRecordId(recordId)
                }
                callback(Result.success(revisions.map { rev ->
                    NativeNotificationRevision(
                        id = rev.id,
                        parentRecordId = rev.parentRecordId,
                        captureTimestamp = rev.captureTimestamp,
                        contentHash = rev.contentHash,
                        title = rev.title,
                        text = rev.text,
                        subText = rev.subText,
                        bigText = rev.bigText,
                        summaryText = rev.summaryText,
                        infoText = rev.infoText,
                        conversationTitle = rev.conversationTitle,
                        progressMax = rev.progressMax.toLong(),
                        progressValue = rev.progressValue.toLong(),
                        progressIndeterminate = rev.progressIndeterminate,
                        category = rev.category,
                        mediaPath = rev.mediaPath
                        )
                }))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getAllAppMetadata(callback: (Result<List<NativeAppMetadata?>>) -> Unit) {
        scope.launch {
            try {
                val metadataList = withContext(Dispatchers.IO) {
                    database.appMetadataDao().getAllAppMetadata()
                }
                callback(Result.success(metadataList.map { meta ->
                    NativeAppMetadata(
                        packageName = meta.packageName,
                        appName = meta.appName,
                        isLoggingEnabled = meta.isLoggingEnabled,
                        retentionDays = meta.retentionDays?.toLong()
                    )
                }))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getAppMetadata(packageName: String, callback: (Result<NativeAppMetadata?>) -> Unit) {
        scope.launch {
            try {
                val meta = withContext(Dispatchers.IO) {
                    database.appMetadataDao().getAppMetadata(packageName)
                }
                if (meta != null) {
                    callback(Result.success(NativeAppMetadata(
                        packageName = meta.packageName,
                        appName = meta.appName,
                        isLoggingEnabled = meta.isLoggingEnabled,
                        retentionDays = meta.retentionDays?.toLong()
                    )))
                } else {
                    callback(Result.success(null))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun setAppLoggingStatus(packageName: String, enabled: Boolean, callback: (Result<Unit>) -> Unit) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    val existing = database.appMetadataDao().getAppMetadata(packageName)
                    if (existing != null) {
                        database.appMetadataDao().updateLoggingStatus(packageName, enabled)
                    } else {
                        database.appMetadataDao().insertAppMetadata(
                            com.nottik.app.models.AppMetadata(
                                packageName = packageName,
                                isLoggingEnabled = enabled
                            )
                        )
                    }
                }
                callback(Result.success(Unit))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getNativeLogFiles(): List<String> {
        return try {
            val logDir = java.io.File(filesDir, "logs")
            if (logDir.exists()) {
                logDir.listFiles()?.filter { it.name.endsWith(".log") }?.map { it.absolutePath } ?: emptyList()
            } else emptyList()
        } catch (e: Exception) {
            NativeLogger.error("MainActivity", "Failed to get log files", e)
            emptyList()
        }
    }

    private var currentExportType: String? = null
    private var exportCallback: ((Result<Unit>) -> Unit)? = null

    override fun exportData(type: String, callback: (Result<Unit>) -> Unit) {
        currentExportType = type
        exportCallback = callback
        
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            when (type) {
                "json" -> {
                    setType("application/json")
                    putExtra(Intent.EXTRA_TITLE, "nottik_export.json")
                }
                "zip" -> {
                    setType("application/zip")
                    putExtra(Intent.EXTRA_TITLE, "nottik_backup.zip")
                }
            }
        }
        startActivityForResult(intent, 1001)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1001 && resultCode == android.app.Activity.RESULT_OK) {
            data?.data?.let { uri ->
                scope.launch {
                    val type = currentExportType
                    if (type == "json") {
                        val res = com.nottik.app.utils.ExportUtils.exportToJson(this@MainActivity, uri)
                        exportCallback?.invoke(res)
                    } else if (type == "zip") {
                        val res = com.nottik.app.utils.ExportUtils.backupDatabaseToZip(this@MainActivity, uri)
                        exportCallback?.invoke(res)
                    }
                    exportCallback = null
                    currentExportType = null
                }
            }
        } else if (requestCode == 1001) {
            exportCallback?.invoke(Result.failure(Exception("User cancelled")))
            exportCallback = null
            currentExportType = null
        }
    }
}
