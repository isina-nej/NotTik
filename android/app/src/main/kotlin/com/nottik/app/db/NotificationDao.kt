package com.nottik.app.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision

@Dao
interface NotificationDao {
    @Insert
    fun insertRecord(record: NotificationRecord): Long

    @Insert
    fun insertRevision(revision: NotificationRevision): Long

    @Query("SELECT * FROM notification_records WHERE package_name = :packageName AND notification_id = :notificationId AND tag = :tag LIMIT 1")
    fun getRecordByOriginalIdentity(packageName: String, notificationId: Int, tag: String?): NotificationRecord?
    
    @Query("SELECT * FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC LIMIT 1")
    fun getLatestRevisionForRecord(recordId: Long): NotificationRevision?

    @Transaction
    fun insertOrUpdateNotification(record: NotificationRecord, revision: NotificationRevision) {
        var existingRecord = getRecordByOriginalIdentity(record.packageName, record.notificationId, record.tag)
        val recordId = if (existingRecord == null) {
            insertRecord(record)
        } else {
            existingRecord.id
        }
        
        val latestRevision = getLatestRevisionForRecord(recordId)
        if (latestRevision == null || latestRevision.contentHash != revision.contentHash) {
            revision.parentRecordId = recordId
            insertRevision(revision)
        }
    }
}
