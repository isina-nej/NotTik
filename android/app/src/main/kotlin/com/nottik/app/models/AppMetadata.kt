package com.nottik.app.models

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.ColumnInfo

@Entity(tableName = "app_metadata")
data class AppMetadata(
    @PrimaryKey
    @ColumnInfo(name = "package_name")
    val packageName: String,
    
    @ColumnInfo(name = "app_name")
    val appName: String? = null,
    
    @ColumnInfo(name = "is_logging_enabled")
    val isLoggingEnabled: Boolean = true,
    
    @ColumnInfo(name = "retention_days")
    val retentionDays: Int? = null // null means default app retention
)