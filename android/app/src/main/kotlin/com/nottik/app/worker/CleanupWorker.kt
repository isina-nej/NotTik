package com.nottik.app.worker

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.nottik.app.db.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class CleanupWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        try {
            val database = AppDatabase.getDatabase(applicationContext)
            
            // Delete records older than 30 days (Default retention)
            val cutoffTime = System.currentTimeMillis() - (30L * 24L * 60L * 60L * 1000L)
            
            val dao = database.notificationDao()
            val metadataDao = database.appMetadataDao()
            
            val appsMetadata = metadataDao.getAllAppMetadata()
            
            // Handle custom retention per app
            for (meta in appsMetadata) {
                if (meta.retentionDays != null) {
                    val appCutoff = System.currentTimeMillis() - (meta.retentionDays * 24L * 60L * 60L * 1000L)
                    dao.deleteOldRecordsForApp(meta.packageName, appCutoff)
                }
            }
            
            // Handle default retention (for apps with no custom retention)
            dao.deleteOldRecords(cutoffTime)
            
            Result.success()
        } catch (e: Exception) {
            Log.e("CleanupWorker", "Error during cleanup", e)
            Result.failure()
        }
    }
}