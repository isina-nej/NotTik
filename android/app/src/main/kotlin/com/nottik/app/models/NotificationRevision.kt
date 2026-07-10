package com.nottik.app.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.PrimaryKey

@Entity(
    tableName = "notification_revisions",
    foreignKeys = [
        ForeignKey(
            entity = NotificationRecord::class,
            parentColumns = ["id"],
            childColumns = ["parent_record_id"],
            onDelete = ForeignKey.CASCADE
        )
    ]
)
data class NotificationRevision(
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0,
    
    @ColumnInfo(name = "parent_record_id", index = true)
    var parentRecordId: Long = 0,
    
    @ColumnInfo(name = "capture_timestamp")
    val captureTimestamp: Long,
    
    @ColumnInfo(name = "content_hash")
    val contentHash: String,
    
    @ColumnInfo(name = "title")
    val title: String?,
    
    @ColumnInfo(name = "text")
    val text: String?,
    
    @ColumnInfo(name = "sub_text")
    val subText: String?,
    
    @ColumnInfo(name = "big_text")
    val bigText: String?,
    
    @ColumnInfo(name = "summary_text")
    val summaryText: String?,
    
    @ColumnInfo(name = "info_text")
    val infoText: String?,
    
    @ColumnInfo(name = "text_lines")
    val textLines: String?, // JSON or concatenated
    
    @ColumnInfo(name = "conversation_title")
    val conversationTitle: String?,
    
    @ColumnInfo(name = "messaging_messages")
    val messagingMessages: String?, // JSON representation
    
    @ColumnInfo(name = "progress_max")
    val progressMax: Int = 0,
    
    @ColumnInfo(name = "progress_value")
    val progressValue: Int = 0,
    
    @ColumnInfo(name = "progress_indeterminate")
    val progressIndeterminate: Boolean = false,
    
    @ColumnInfo(name = "category")
    val category: String?,
    
    @ColumnInfo(name = "large_icon_path")
    val largeIconPath: String?,
    
    @ColumnInfo(name = "big_picture_path")
    val bigPicturePath: String?,
    
    @ColumnInfo(name = "app_icon_path")
    val appIconPath: String?,
    
    @ColumnInfo(name = "media_path")
    val mediaPath: String? = null
)
