package com.nottik.app.db

import androidx.room.Database
import androidx.room.RoomDatabase
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision

@Database(entities = [NotificationRecord::class, NotificationRevision::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun notificationDao(): NotificationDao
}
