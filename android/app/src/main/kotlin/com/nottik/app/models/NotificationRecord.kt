package com.nottik.app.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "notification_records")
data class NotificationRecord(
    @PrimaryKey(autoGenerate = true)
    var id: Long = 0,
    
    @ColumnInfo(name = "notification_key")
    val notificationKey: String,
    
    @ColumnInfo(name = "package_name")
    val packageName: String,
    
    @ColumnInfo(name = "app_name")
    val appName: String? = null,
    
    @ColumnInfo(name = "notification_id")
    val notificationId: Int,
    
    @ColumnInfo(name = "tag")
    val tag: String? = null,
    
    @ColumnInfo(name = "post_time")
    val postTime: Long,
    
    @ColumnInfo(name = "first_captured_time")
    val firstCapturedTime: Long,
    
    @ColumnInfo(name = "last_update_time")
    val lastUpdateTime: Long,
    
    @ColumnInfo(name = "group_key")
    val groupKey: String? = null,
    
    @ColumnInfo(name = "channel_id")
    val channelId: String? = null,
    
    @ColumnInfo(name = "priority")
    val priority: Int = 0,
    
    @ColumnInfo(name = "visibility")
    val visibility: Int = 0,
    
    @ColumnInfo(name = "is_ongoing")
    val isOngoing: Boolean = false,
    
    @ColumnInfo(name = "is_clearable")
    val isClearable: Boolean = true,
    
    @ColumnInfo(name = "is_group_summary")
    val isGroupSummary: Boolean = false,
    
    @ColumnInfo(name = "is_removed")
    val isRemoved: Boolean = false,
    
    @ColumnInfo(name = "removal_reason")
    val removalReason: Int? = null,
    
    @ColumnInfo(name = "custom_category")
    val customCategory: String? = null,
    
    @ColumnInfo(name = "sender_name")
    val senderName: String? = null
)
