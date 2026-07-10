package com.nottik.app.service

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import com.nottik.app.db.AppDatabase
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.security.MessageDigest

import org.json.JSONArray
import org.json.JSONObject
import com.nottik.app.utils.NativeLogger

import com.nottik.app.utils.NotificationImageExtractor

class NottikNotificationListener : NotificationListenerService() {
    private val TAG = "NottikListener"
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private lateinit var database: AppDatabase

    override fun onCreate() {
        super.onCreate()
        database = AppDatabase.getDatabase(applicationContext)
    }

    override fun onDestroy() {
        super.onDestroy()
        scope.cancel()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) return

        scope.launch {
            try {
                handleNotificationPosted(sbn)
            } catch (e: Exception) {
                Log.e(TAG, "Error handling notification", e)
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification, rankingMap: RankingMap, reason: Int) {
        scope.launch {
            try {
                handleNotificationRemoved(sbn, reason)
            } catch (e: Exception) {
                Log.e(TAG, "Error handling notification removal", e)
            }
        }
    }

    companion object {
        var isRunning: Boolean = false
        var lastError: String? = null
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isRunning = true
        lastError = null
        NativeLogger.init(applicationContext)
        NativeLogger.info(TAG, "Listener Connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isRunning = false
        NativeLogger.info(TAG, "Listener Disconnected")
    }

    private suspend fun handleNotificationPosted(sbn: StatusBarNotification) {
        val notification = sbn.notification
        val extras = notification.extras
        
        // Filter based on AppMetadata settings
        val dao = database.notificationDao()
        val metadataDao = database.appMetadataDao()
        
        val appMetadata = metadataDao.getAppMetadata(sbn.packageName)
        if (appMetadata != null && !appMetadata.isLoggingEnabled) {
            return // Skip logging for this app
        }
        
        // Extract fields safely
        val title = extras.getCharSequence(android.app.Notification.EXTRA_TITLE)?.toString()
        val text = extras.getCharSequence(android.app.Notification.EXTRA_TEXT)?.toString()
        val subText = extras.getCharSequence(android.app.Notification.EXTRA_SUB_TEXT)?.toString()
        val summaryText = extras.getCharSequence(android.app.Notification.EXTRA_SUMMARY_TEXT)?.toString()
        val infoText = extras.getCharSequence(android.app.Notification.EXTRA_INFO_TEXT)?.toString()
        val bigText = extras.getCharSequence(android.app.Notification.EXTRA_BIG_TEXT)?.toString()
        val conversationTitle = extras.getCharSequence(android.app.Notification.EXTRA_CONVERSATION_TITLE)?.toString()
        
        val progressMax = extras.getInt(android.app.Notification.EXTRA_PROGRESS_MAX, 0)
        val progressValue = extras.getInt(android.app.Notification.EXTRA_PROGRESS, 0)
        val progressIndeterminate = extras.getBoolean(android.app.Notification.EXTRA_PROGRESS_INDETERMINATE, false)
        
        // Extract MessagingStyle messages
        var messagingMessagesStr: String? = null
        var lastSenderName: String? = null
        try {
            val messages = extras.getParcelableArray(android.app.Notification.EXTRA_MESSAGES)
            if (messages != null && messages.isNotEmpty()) {
                val jsonArray = JSONArray()
                for (msgObj in messages) {
                    if (msgObj is android.os.Bundle) {
                        val msgJson = JSONObject()
                        val textStr = msgObj.getCharSequence("text")?.toString()
                        val senderStr = msgObj.getCharSequence("sender")?.toString()
                        msgJson.put("text", textStr)
                        msgJson.put("time", msgObj.getLong("time"))
                        msgJson.put("sender", senderStr)
                        jsonArray.put(msgJson)
                        
                        if (senderStr != null) {
                            lastSenderName = senderStr
                        }
                    }
                }
                messagingMessagesStr = jsonArray.toString()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to extract messages", e)
        }
        
        // If it's not a MessagingStyle or doesn't have a specific sender, fallback to title
        if (lastSenderName == null) {
            lastSenderName = title
        }

        // Extract Images
        var largeIconPath: String? = null
        var bigPicturePath: String? = null
        
        try {
            val largeIcon = notification.getLargeIcon()
            largeIconPath = NotificationImageExtractor.extractAndSaveIcon(this, largeIcon, "large_icon")
            
            val bigPicture = extras.getParcelable<android.graphics.Bitmap>(android.app.Notification.EXTRA_PICTURE)
            bigPicturePath = NotificationImageExtractor.extractAndSaveBitmap(this, bigPicture, "big_picture")
            
            val appIcon = notification.smallIcon
            // App icon is also saved if necessary.
        } catch (e: Exception) {
            Log.e(TAG, "Failed to extract images", e)
        }
        
        // Semantic hashing
        val contentBuilder = StringBuilder()
        contentBuilder.append(sbn.packageName).append("|")
        contentBuilder.append(title ?: "").append("|")
        contentBuilder.append(text ?: "").append("|")
        contentBuilder.append(bigText ?: "").append("|")
        contentBuilder.append(progressValue).append("|")
        contentBuilder.append(messagingMessagesStr ?: "").append("|")
        
        val hash = sha256(contentBuilder.toString())
        
        // Find existing record by stable key
        var record = dao.getRecordByKey(sbn.key)
        var recordId: Long
        
        val currentTime = System.currentTimeMillis()
        
        if (record == null) {
            val appName = try {
                packageManager.getApplicationLabel(
                    packageManager.getApplicationInfo(sbn.packageName, 0)
                ).toString()
            } catch (e: Exception) {
                null
            }
            
            record = NotificationRecord(
                notificationKey = sbn.key,
                packageName = sbn.packageName,
                appName = appName,
                notificationId = sbn.id,
                tag = sbn.tag,
                postTime = sbn.postTime,
                firstCapturedTime = currentTime,
                lastUpdateTime = currentTime,
                groupKey = sbn.groupKey,
                channelId = notification.channelId,
                priority = notification.priority,
                visibility = notification.visibility,
                isOngoing = sbn.isOngoing,
                isClearable = sbn.isClearable,
                isGroupSummary = notification.flags and android.app.Notification.FLAG_GROUP_SUMMARY != 0,
                isRemoved = false,
                senderName = lastSenderName
            )
            recordId = dao.insertRecord(record)
        } else {
            recordId = record.id
            val latestHash = dao.getLatestRevisionHash(recordId)
            
            if (latestHash == hash) {
                return // Duplicate revision, do nothing
            }
            
            dao.updateRecordStatus(recordId, currentTime, false, null)
        }
        
        val revision = NotificationRevision(
            parentRecordId = recordId,
            captureTimestamp = currentTime,
            contentHash = hash,
            title = title,
            text = text,
            subText = subText,
            bigText = bigText,
            summaryText = summaryText,
            infoText = infoText,
            textLines = null, // Will parse EXTRA_TEXT_LINES if needed
            conversationTitle = conversationTitle,
            messagingMessages = messagingMessagesStr,
            progressMax = progressMax,
            progressValue = progressValue,
            progressIndeterminate = progressIndeterminate,
            category = notification.category,
            largeIconPath = largeIconPath,
            bigPicturePath = bigPicturePath,
            appIconPath = null,
            mediaPath = bigPicturePath ?: largeIconPath // Store the primary available media
        )
        
        dao.insertRevision(revision)
    }

    private suspend fun handleNotificationRemoved(sbn: StatusBarNotification, reason: Int) {
        val dao = database.notificationDao()
        val record = dao.getRecordByKey(sbn.key)
        
        if (record != null) {
            dao.updateRecordStatus(record.id, System.currentTimeMillis(), true, reason)
        }
    }
    
    private fun sha256(input: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }
}