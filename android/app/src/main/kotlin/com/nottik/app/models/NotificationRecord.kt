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
    
    @ColumnInfo(name = "notification_id")
    val notificationId: Int,
    
    @ColumnInfo(name = "tag")
    val tag: String? = null,
    
    @ColumnInfo(name = "post_time")
    val postTime: Long,
    
    @ColumnInfo(name = "first_captured_time")
    val firstCapturedTime: Long,
    
    @ColumnInfo(name = "is_removed")
    val isRemoved: Boolean = false,
    
    @ColumnInfo(name = "removal_reason")
    val removalReason: Int? = null
)
