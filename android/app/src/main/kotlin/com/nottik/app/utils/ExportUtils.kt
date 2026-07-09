package com.nottik.app.utils

import android.content.Context
import android.net.Uri
import com.nottik.app.db.AppDatabase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

object ExportUtils {
    
    suspend fun exportToJson(context: Context, uri: Uri): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val database = AppDatabase.getDatabase(context)
            val dao = database.notificationDao()
            
            // Note: In a real app this should be paginated if huge, 
            // for MVP we fetch all.
            val records = dao.getHistoryPaginated(0, 5000, null, null)
            
            val jsonArray = JSONArray()
            for (item in records) {
                val obj = JSONObject()
                obj.put("package", item.packageName)
                obj.put("app_name", item.appName)
                obj.put("post_time", item.postTime)
                jsonArray.put(obj)
            }
            
            context.contentResolver.openOutputStream(uri)?.use { outStream ->
                outStream.write(jsonArray.toString(2).toByteArray(Charsets.UTF_8))
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun backupDatabaseToZip(context: Context, uri: Uri): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val database = AppDatabase.getDatabase(context)
            // Force checkpoint
            database.openHelper.writableDatabase.query("PRAGMA wal_checkpoint(FULL)").close()

            val dbFile = context.getDatabasePath("nottik_database")
            
            context.contentResolver.openOutputStream(uri)?.use { outStream ->
                ZipOutputStream(outStream).use { zos ->
                    if (dbFile.exists()) {
                        zos.putNextEntry(ZipEntry(dbFile.name))
                        dbFile.inputStream().use { it.copyTo(zos) }
                        zos.closeEntry()
                    }
                    
                    val walFile = context.getDatabasePath("nottik_database-wal")
                    if (walFile.exists()) {
                        zos.putNextEntry(ZipEntry(walFile.name))
                        walFile.inputStream().use { it.copyTo(zos) }
                        zos.closeEntry()
                    }

                    val shmFile = context.getDatabasePath("nottik_database-shm")
                    if (shmFile.exists()) {
                        zos.putNextEntry(ZipEntry(shmFile.name))
                        shmFile.inputStream().use { it.copyTo(zos) }
                        zos.closeEntry()
                    }
                }
            }
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}