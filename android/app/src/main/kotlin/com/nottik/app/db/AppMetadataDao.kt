package com.nottik.app.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.nottik.app.models.AppMetadata

@Dao
interface AppMetadataDao {
    @Query("SELECT * FROM app_metadata")
    suspend fun getAllAppMetadata(): List<AppMetadata>

    @Query("SELECT * FROM app_metadata WHERE package_name = :packageName LIMIT 1")
    suspend fun getAppMetadata(packageName: String): AppMetadata?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertAppMetadata(metadata: AppMetadata): Long

    @Update
    suspend fun updateAppMetadata(metadata: AppMetadata)

    @Query("UPDATE app_metadata SET is_logging_enabled = :enabled WHERE package_name = :packageName")
    suspend fun updateLoggingStatus(packageName: String, enabled: Boolean)
}