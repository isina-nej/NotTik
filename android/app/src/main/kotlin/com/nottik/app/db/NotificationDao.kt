package com.nottik.app.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision

@Dao
interface NotificationDao {
    @Insert
    suspend fun insertRecord(record: NotificationRecord): Long

    @Insert
    suspend fun insertRevision(revision: NotificationRevision): Long

    @Query("SELECT * FROM notification_records WHERE notification_key = :key LIMIT 1")
    suspend fun getRecordByKey(key: String): NotificationRecord?

    @Query("UPDATE notification_records SET last_update_time = :updateTime, is_removed = :isRemoved, removal_reason = :removalReason WHERE id = :id")
    suspend fun updateRecordStatus(id: Long, updateTime: Long, isRemoved: Boolean, removalReason: Int?)

    @Query("SELECT content_hash FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC LIMIT 1")
    suspend fun getLatestRevisionHash(recordId: Long): String?

    @Query("""
        SELECT * FROM notification_records 
        WHERE (:searchQuery IS NULL OR app_name LIKE '%' || :searchQuery || '%' OR package_name LIKE '%' || :searchQuery || '%')
        AND (:category IS NULL OR custom_category = :category)
        ORDER BY last_update_time DESC 
        LIMIT :limit OFFSET :offset
    """)
    suspend fun getHistoryPaginated(offset: Long, limit: Long, searchQuery: String?, category: String?): List<NotificationRecord>
    
    @Query("SELECT * FROM notification_records WHERE id = :id LIMIT 1")
    suspend fun getRecordById(id: Long): NotificationRecord?

    @Query("SELECT * FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC")
    suspend fun getRevisionsByRecordId(recordId: Long): List<NotificationRevision>

    @Query("DELETE FROM notification_records")
    suspend fun deleteAll()

    @Query("DELETE FROM notification_records WHERE last_update_time < :cutoffTime AND package_name NOT IN (SELECT package_name FROM app_metadata WHERE retention_days IS NOT NULL)")
    suspend fun deleteOldRecords(cutoffTime: Long)

    @Query("DELETE FROM notification_records WHERE package_name = :packageName AND last_update_time < :cutoffTime")
    suspend fun deleteOldRecordsForApp(packageName: String, cutoffTime: Long)
}