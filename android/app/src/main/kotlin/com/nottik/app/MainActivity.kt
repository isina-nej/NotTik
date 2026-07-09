package com.nottik.app

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.nottik.app.bridge.NotificationBridge
import com.nottik.app.bridge.NativeNotificationRecord
import com.nottik.app.bridge.NativeNotificationRevision
import com.nottik.app.bridge.PaginatedResult
import com.nottik.app.db.AppDatabase
import com.nottik.app.service.NottikNotificationListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity : FlutterActivity(), NotificationBridge {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private lateinit var database: AppDatabase

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        database = AppDatabase.getDatabase(applicationContext)
        NotificationBridge.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }

    // --- Synchronous methods ---

    override fun isListenerConnected(): Boolean =
        NotificationManagerCompat.getEnabledListenerPackages(this).contains(packageName)

    override fun openListenerSettings() {
        startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
    }

    override fun requestRebind() {
        val cn = ComponentName(this, NottikNotificationListener::class.java)
        packageManager.setComponentEnabledSetting(cn, android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_DISABLED, android.content.pm.PackageManager.DONT_KILL_APP)
        packageManager.setComponentEnabledSetting(cn, android.content.pm.PackageManager.COMPONENT_ENABLED_STATE_ENABLED, android.content.pm.PackageManager.DONT_KILL_APP)
    }

    // --- Async methods with callbacks ---

    override fun getLatestHistory(
        offset: Long,
        limit: Long,
        callback: (Result<PaginatedResult>) -> Unit
    ) {
        scope.launch {
            try {
                val records = withContext(Dispatchers.IO) {
                    database.notificationDao().getHistoryPaginated(offset, limit)
                }
                val items = records.map { rec ->
                    NativeNotificationRecord(
                        id = rec.id,
                        notificationKey = rec.notificationKey,
                        packageName = rec.packageName,
                        appName = rec.appName,
                        notificationId = rec.notificationId.toLong(),
                        tag = rec.tag,
                        postTime = rec.postTime,
                        firstCapturedTime = rec.firstCapturedTime,
                        lastUpdateTime = rec.lastUpdateTime,
                        groupKey = rec.groupKey,
                        channelId = rec.channelId,
                        priority = rec.priority.toLong(),
                        visibility = rec.visibility.toLong(),
                        isOngoing = rec.isOngoing,
                        isClearable = rec.isClearable,
                        isGroupSummary = rec.isGroupSummary,
                        isRemoved = rec.isRemoved,
                        removalReason = rec.removalReason?.toLong()
                    )
                }
                callback(Result.success(PaginatedResult(items = items, hasMore = items.size.toLong() == limit)))
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
                val rec = withContext(Dispatchers.IO) {
                    database.notificationDao().getRecordById(id)
                }
                callback(Result.success(rec?.let {
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
                }))
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
                        category = rev.category
                    )
                }))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }
}
