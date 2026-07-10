package com.nottik.app.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.Icon
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

object NotificationImageExtractor {
    private const val TAG = "NotificationImageExtractor"
    private const val MEDIA_DIR = "media"

    fun extractAndSaveBitmap(context: Context, bitmap: Bitmap?, prefix: String): String? {
        if (bitmap == null) return null
        
        try {
            val mediaDir = File(context.filesDir, MEDIA_DIR)
            if (!mediaDir.exists()) {
                mediaDir.mkdirs()
            }
            
            val filename = "${prefix}_${UUID.randomUUID()}.png"
            val file = File(mediaDir, filename)
            
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 90, out)
            }
            
            return file.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save bitmap", e)
            return null
        }
    }

    fun extractAndSaveIcon(context: Context, icon: Icon?, prefix: String): String? {
        if (icon == null) return null
        // In a real scenario you would convert Icon to Drawable then to Bitmap
        // For MVP, we skip complex Icon decoding to keep it lightweight, unless strictly needed.
        return null
    }
}