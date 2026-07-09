package com.nottik.app.service

import android.app.Notification
import android.content.Context
import android.graphics.Bitmap
import android.graphics.drawable.Icon
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

object NotificationImageExtractor {
    fun extractAndSaveIcon(context: Context, icon: Icon?, prefix: String): String? {
        if (icon == null) return null
        return try {
            val drawable = icon.loadDrawable(context) ?: return null
            val bitmap = android.graphics.Bitmap.createBitmap(
                drawable.intrinsicWidth.takeIf { it > 0 } ?: 100,
                drawable.intrinsicHeight.takeIf { it > 0 } ?: 100,
                android.graphics.Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            saveBitmap(context, bitmap, prefix)
        } catch (e: Exception) {
            Log.e("ImageExtractor", "Failed to extract icon", e)
            null
        }
    }

    fun extractAndSaveBitmap(context: Context, bitmap: Bitmap?, prefix: String): String? {
        if (bitmap == null) return null
        return try {
            saveBitmap(context, bitmap, prefix)
        } catch (e: Exception) {
            Log.e("ImageExtractor", "Failed to extract bitmap", e)
            null
        }
    }

    private fun saveBitmap(context: Context, bitmap: Bitmap, prefix: String): String {
        val dir = File(context.filesDir, "notification_images")
        if (!dir.exists()) dir.mkdirs()
        
        val filename = "${prefix}_${UUID.randomUUID()}.png"
        val file = File(dir, filename)
        
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
        return file.absolutePath
    }
}