package com.nottik.app.service

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import androidx.room.Room
import com.nottik.app.db.AppDatabase
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.security.MessageDigest

class NottikNotificationListener : NotificationListenerService() {
    private val scope = CoroutineScope(Dispatchers.IO)
    private lateinit var db: AppDatabase

    override fun onCreate() {
        super.onCreate()
        db = Room.databaseBuilder(
            applicationContext,
            AppDatabase::class.java, "nottik-db"
        ).build()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)
        if (sbn == null) return

        val packageName = sbn.packageName
        val notificationId = sbn.id
        val tag = sbn.tag
        val key = sbn.key
        val postTime = sbn.postTime

        val extras = sbn.notification.extras
        val title = extras.getCharSequence("android.title")?.toString()
        val text = extras.getCharSequence("android.text")?.toString()
        val category = sbn.notification.category

        val contentToHash = "$title|$text"
        val hash = hashString(contentToHash)

        scope.launch {
            val record = NotificationRecord(
                notificationKey = key,
                packageName = packageName,
                notificationId = notificationId,
                tag = tag,
                postTime = postTime,
                firstCapturedTime = System.currentTimeMillis()
            )

            val revision = NotificationRevision(
                captureTimestamp = System.currentTimeMillis(),
                contentHash = hash,
                title = title,
                text = text,
                category = category
            )

            try {
                db.notificationDao().insertOrUpdateNotification(record, revision)
                Log.d("NottikListener", "Saved notification from \$packageName")
            } catch (e: Exception) {
                Log.e("NottikListener", "Error saving notification", e)
            }
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?, rankingMap: RankingMap?, reason: Int) {
        super.onNotificationRemoved(sbn, rankingMap, reason)
        // MVP: Optionally mark as removed, skipped for brevity in this step
    }

    private fun hashString(input: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
