package com.nottik.app.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.nottik.app.models.NotificationRecord
import com.nottik.app.models.NotificationRevision
import com.nottik.app.models.AppMetadata

@Database(entities = [NotificationRecord::class, NotificationRevision::class, AppMetadata::class], version = 4, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {

    abstract fun notificationDao(): NotificationDao
    abstract fun appMetadataDao(): AppMetadataDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null
        
        private val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("ALTER TABLE notification_records ADD COLUMN sender_name TEXT")
                db.execSQL("ALTER TABLE notification_revisions ADD COLUMN media_path TEXT")
            }
        }

        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL("CREATE INDEX IF NOT EXISTS index_notification_records_notification_key ON notification_records(notification_key)")
                db.execSQL("CREATE INDEX IF NOT EXISTS index_notification_records_history_order ON notification_records(is_group_summary, last_update_time)")
                db.execSQL("CREATE INDEX IF NOT EXISTS index_notification_records_category_order ON notification_records(is_group_summary, custom_category, last_update_time)")
                db.execSQL("CREATE INDEX IF NOT EXISTS index_notification_records_package_retention ON notification_records(package_name, last_update_time)")
                db.execSQL("CREATE INDEX IF NOT EXISTS index_notification_revisions_latest ON notification_revisions(parent_record_id, capture_timestamp)")
            }
        }

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "nottik_database"
                )
                .addMigrations(MIGRATION_2_3, MIGRATION_3_4)
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}