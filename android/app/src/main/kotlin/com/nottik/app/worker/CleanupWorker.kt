package com.nottik.app.worker

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.nottik.app.db.AppDatabase
import java.io.File

class CleanupWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    override suspend fun doWork(): Result {
        return try {
            val db = AppDatabase.getDatabase(applicationContext)
            val notificationDao = db.notificationDao()
            val metadataDao = db.appMetadataDao()
            
            val appMetadataList = metadataDao.getAllAppMetadata()
            
            // Handle custom retention per app
            for (meta in appMetadataList) {
                if (meta.retentionDays != null) {
                    val appCutoff = System.currentTimeMillis() - (meta.retentionDays * 24L * 60L * 60L * 1000L)
                    
                    // First find records to delete to get their IDs
                    val recordsToDelete = notificationDao.getRecordsOlderThanForPackage(appCutoff, meta.packageName)
                    val recordIds = recordsToDelete.map { it.id }
                    
                    // Delete associated media files before removing from DB
                    if (recordIds.isNotEmpty()) {
                        val mediaPaths = notificationDao.getMediaPathsForRecords(recordIds)
                        deleteMediaFiles(mediaPaths)
                        notificationDao.deleteRecordsOlderThanForPackage(appCutoff, meta.packageName)
                    }
                }
            }
            
            // Handle default retention (for apps with no custom retention)
            val defaultCutoff = System.currentTimeMillis() - (30L * 24L * 60L * 60L * 1000L) // 30 days
            val defaultRecordsToDelete = notificationDao.getRecordsOlderThanDefault(defaultCutoff)
            val defaultRecordIds = defaultRecordsToDelete.map { it.id }
            
            if (defaultRecordIds.isNotEmpty()) {
                val defaultMediaPaths = notificationDao.getMediaPathsForRecords(defaultRecordIds)
                deleteMediaFiles(defaultMediaPaths)
                notificationDao.deleteRecordsOlderThanDefault(defaultCutoff)
            }
            
            // Extra safety: cleanup orphaned files in media directory
            cleanupOrphanedMediaFiles(notificationDao)
            
            Result.success()
        } catch (e: Exception) {
            Log.e("CleanupWorker", "Error during cleanup", e)
            Result.failure()
        }
    }
    
    private fun deleteMediaFiles(paths: List<String?>) {
        paths.filterNotNull().forEach { path ->
            try {
                val file = File(path)
                if (file.exists()) {
                    file.delete()
                }
            } catch (e: Exception) {
                Log.e("CleanupWorker", "Failed to delete file: \$path", e)
            }
        }
    }
    
    private suspend fun cleanupOrphanedMediaFiles(dao: com.nottik.app.db.NotificationDao) {
        try {
            val mediaDir = File(applicationContext.filesDir, "media")
            if (!mediaDir.exists() || !mediaDir.isDirectory) return
            
            val allDbMediaPaths = dao.getAllMediaPaths().filterNotNull().toSet()
            
            mediaDir.listFiles()?.forEach { file ->
                if (!allDbMediaPaths.contains(file.absolutePath)) {
                    file.delete()
                }
            }
        } catch (e: Exception) {
            Log.e("CleanupWorker", "Failed to cleanup orphaned media", e)
        }
    }
}
