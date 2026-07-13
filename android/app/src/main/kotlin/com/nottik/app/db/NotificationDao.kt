package com.nottik.app.db

import androidx.room.ColumnInfo
import androidx.room.Dao
import androidx.room.Embedded
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision

@Dao
interface NotificationDao {
    data class NotificationRecordId(val id: Long)

    data class HistoryPreviewRow(
        @Embedded val record: NotificationRecord,
        @ColumnInfo(name = "latest_title") val latestTitle: String?,
        @ColumnInfo(name = "latest_text") val latestText: String?,
        @ColumnInfo(name = "latest_big_text") val latestBigText: String?,
        @ColumnInfo(name = "latest_summary_text") val latestSummaryText: String?,
        @ColumnInfo(name = "latest_sub_text") val latestSubText: String?,
        @ColumnInfo(name = "latest_app_icon_path") val latestAppIconPath: String?,
        @ColumnInfo(name = "latest_large_icon_path") val latestLargeIconPath: String?,
        @ColumnInfo(name = "latest_media_path") val latestMediaPath: String?
    )
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertRecord(record: NotificationRecord): Long

    @Insert
    suspend fun insertRevision(revision: NotificationRevision): Long

    @Query("SELECT * FROM notification_records WHERE notification_key = :key LIMIT 1")
    suspend fun getRecordByKey(key: String): NotificationRecord?

    @Query("UPDATE notification_records SET last_update_time = :updateTime, is_removed = :isRemoved, removal_reason = :removalReason WHERE id = :id")
    suspend fun updateRecordStatus(id: Long, updateTime: Long, isRemoved: Boolean, removalReason: Int?)

    @Query("SELECT content_hash FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC LIMIT 1")
    suspend fun getLatestRevisionHash(recordId: Long): String?

    @Query("SELECT * FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC LIMIT 1")
    suspend fun getLatestRevision(recordId: Long): NotificationRevision?

    @Query("""
        SELECT * FROM notification_records 
        WHERE is_group_summary = 0
        AND (
          :searchQuery IS NULL
          OR app_name LIKE '%' || :searchQuery || '%'
          OR package_name LIKE '%' || :searchQuery || '%'
          OR sender_name LIKE '%' || :searchQuery || '%'
          OR id IN (
            SELECT parent_record_id FROM notification_revisions
            WHERE title LIKE '%' || :searchQuery || '%'
               OR text LIKE '%' || :searchQuery || '%'
               OR big_text LIKE '%' || :searchQuery || '%'
          )
        )
        AND (:category IS NULL OR custom_category = :category)
        ORDER BY last_update_time DESC 
        LIMIT :limit OFFSET :offset
    """)
    suspend fun getHistoryPaginated(offset: Long, limit: Long, searchQuery: String?, category: String?): List<NotificationRecord>

    @Query("""
        SELECT
          r.*,
          lr.title AS latest_title,
          lr.text AS latest_text,
          lr.big_text AS latest_big_text,
          lr.summary_text AS latest_summary_text,
          lr.sub_text AS latest_sub_text,
          lr.app_icon_path AS latest_app_icon_path,
          lr.large_icon_path AS latest_large_icon_path,
          lr.media_path AS latest_media_path
        FROM notification_records r
        LEFT JOIN notification_revisions lr ON lr.id = (
          SELECT latest.id
          FROM notification_revisions latest
          WHERE latest.parent_record_id = r.id
          ORDER BY latest.capture_timestamp DESC
          LIMIT 1
        )
        WHERE r.is_group_summary = 0
        AND (
          :searchQuery IS NULL
          OR r.app_name LIKE '%' || :searchQuery || '%'
          OR r.package_name LIKE '%' || :searchQuery || '%'
          OR r.sender_name LIKE '%' || :searchQuery || '%'
          OR r.id IN (
            SELECT parent_record_id FROM notification_revisions
            WHERE title LIKE '%' || :searchQuery || '%'
               OR text LIKE '%' || :searchQuery || '%'
               OR big_text LIKE '%' || :searchQuery || '%'
          )
        )
        AND (:category IS NULL OR r.custom_category = :category)
        ORDER BY r.last_update_time DESC
        LIMIT :limit OFFSET :offset
    """)
    suspend fun getHistoryPreviewPaginated(
        offset: Long,
        limit: Long,
        searchQuery: String?,
        category: String?
    ): List<HistoryPreviewRow>

    @Query("SELECT DISTINCT package_name FROM notification_records ORDER BY app_name COLLATE NOCASE")
    suspend fun getDistinctPackages(): List<String>

    @Query("SELECT app_name FROM notification_records WHERE package_name = :packageName AND app_name IS NOT NULL LIMIT 1")
    suspend fun getAppNameForPackage(packageName: String): String?
    
    @Query("SELECT * FROM notification_records WHERE id = :id LIMIT 1")
    suspend fun getRecordById(id: Long): NotificationRecord?

    @Query("SELECT * FROM notification_revisions WHERE parent_record_id = :recordId ORDER BY capture_timestamp DESC")
    suspend fun getRevisionsByRecordId(recordId: Long): List<NotificationRevision>

    @Query("SELECT id FROM notification_records WHERE last_update_time < :cutoffTime AND package_name = :packageName")
    suspend fun getRecordsOlderThanForPackage(cutoffTime: Long, packageName: String): List<NotificationRecordId>

    @Query("DELETE FROM notification_records WHERE last_update_time < :cutoffTime AND package_name = :packageName")
    suspend fun deleteRecordsOlderThanForPackage(cutoffTime: Long, packageName: String)

    @Query("SELECT id FROM notification_records WHERE last_update_time < :cutoffTime AND package_name NOT IN (SELECT package_name FROM app_metadata WHERE retention_days IS NOT NULL)")
    suspend fun getRecordsOlderThanDefault(cutoffTime: Long): List<NotificationRecordId>

    @Query("DELETE FROM notification_records WHERE last_update_time < :cutoffTime AND package_name NOT IN (SELECT package_name FROM app_metadata WHERE retention_days IS NOT NULL)")
    suspend fun deleteRecordsOlderThanDefault(cutoffTime: Long)
    
    @Query("SELECT media_path FROM notification_revisions WHERE parent_record_id IN (:recordIds) AND media_path IS NOT NULL")
    suspend fun getMediaPathsForRecords(recordIds: List<Long>): List<String?>
    
    @Query("SELECT media_path FROM notification_revisions WHERE media_path IS NOT NULL")
    suspend fun getAllMediaPaths(): List<String?>

    @Query("DELETE FROM notification_records WHERE package_name = :packageName AND last_update_time < :cutoffTime")
    suspend fun deleteOldRecordsForApp(packageName: String, cutoffTime: Long)
}