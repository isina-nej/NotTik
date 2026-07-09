package com.nottik.app.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "notification_revisions")
data class NotificationRevision(
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0,
    
    @ColumnInfo(name = "parent_record_id")
    var parentRecordId: Long = 0,
    
    @ColumnInfo(name = "capture_timestamp")
    val captureTimestamp: Long,
    
    @ColumnInfo(name = "content_hash")
    val contentHash: String,
    
    @ColumnInfo(name = "title")
    val title: String?,
    
    @ColumnInfo(name = "text")
    val text: String?,
    
    @ColumnInfo(name = "category")
    val category: String?
)
