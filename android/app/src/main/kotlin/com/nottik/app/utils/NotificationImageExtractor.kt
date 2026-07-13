package com.nottik.app.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.ImageDecoder
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.security.MessageDigest
import java.util.UUID

object NotificationImageExtractor {
    private const val TAG = "NotificationImageExtractor"
    private const val MEDIA_DIR = "media"
    private const val APP_ICON_DIR = "app_icons"
    private const val MAX_EDGE = 2048

    data class ExtractedMedia(
        val path: String,
        val contentKey: String,
    )

    fun extractAndSaveBitmap(context: Context, bitmap: Bitmap?, prefix: String): String? {
        return saveBitmap(context, bitmap, prefix)?.path
    }

    fun extractAndSaveIcon(context: Context, icon: Icon?, prefix: String): String? {
        return iconToSaved(context, icon, prefix)?.path
    }

    fun extractAndSaveAppIcon(context: Context, packageName: String): String? {
        return try {
            val dir = File(context.filesDir, APP_ICON_DIR)
            if (!dir.exists()) dir.mkdirs()
            val file = File(dir, "${packageName.replace('.', '_')}.png")
            if (file.exists() && file.length() > 0) return file.absolutePath

            val drawable = context.packageManager.getApplicationIcon(packageName)
            val size = 192
            val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            file.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Failed to extract app icon for $packageName", e)
            null
        }
    }

    /**
     * Best-effort capture of every image Android put on this notification.
     * Returns paths for large icon, big picture, messaging image attachments.
     */
    fun extractNotificationMedia(
        context: Context,
        notification: android.app.Notification,
        extras: Bundle,
    ): Triple<String?, String?, String?> {
        var largeIconPath: String? = null
        var bigPicturePath: String? = null
        var messagingImagePath: String? = null

        try {
            largeIconPath = extractAndSaveIcon(context, notification.getLargeIcon(), "large_icon")
        } catch (e: Exception) {
            Log.e(TAG, "largeIcon extract failed", e)
        }

        try {
            bigPicturePath = extractBigPicture(context, extras)
        } catch (e: Exception) {
            Log.e(TAG, "bigPicture extract failed", e)
        }

        try {
            messagingImagePath = extractMessagingImages(context, extras).firstOrNull()
        } catch (e: Exception) {
            Log.e(TAG, "messaging image extract failed", e)
        }

        return Triple(largeIconPath, bigPicturePath, messagingImagePath)
    }

    fun mediaContentKey(paths: List<String?>): String {
        return paths.filterNotNull().joinToString("|") { File(it).name }
    }

    private fun extractBigPicture(context: Context, extras: Bundle): String? {
        // Prefer modern Icon form when present (API 31+ often uses EXTRA_PICTURE_ICON).
        val pictureIcon = extras.getParcelableCompat(android.app.Notification.EXTRA_PICTURE_ICON, Icon::class.java)
        iconToSaved(context, pictureIcon, "big_picture")?.path?.let { return it }

        // Legacy Bitmap form.
        val pictureBitmap = extras.getParcelableCompat(android.app.Notification.EXTRA_PICTURE, Bitmap::class.java)
        saveBitmap(context, pictureBitmap, "big_picture")?.path?.let { return it }

        // Some OEMs still put Icon/Bitmap under EXTRA_LARGE_ICON_BIG.
        val largeBig = extras.getParcelableCompat(android.app.Notification.EXTRA_LARGE_ICON_BIG, Icon::class.java)
        iconToSaved(context, largeBig, "big_picture")?.path?.let { return it }

        val largeBigBmp = extras.getParcelableCompat(android.app.Notification.EXTRA_LARGE_ICON_BIG, Bitmap::class.java)
        return saveBitmap(context, largeBigBmp, "big_picture")?.path
    }

    private fun extractMessagingImages(context: Context, extras: Bundle): List<String> {
        val out = ArrayList<String>()
        val messages = extras.getParcelableArray(android.app.Notification.EXTRA_MESSAGES) ?: return out
        for (msgObj in messages) {
            val bundle = msgObj as? Bundle ?: continue
            val mime = bundle.getString("type")
                ?: bundle.getString("mimeType")
                ?: bundle.getString("dataMimeType")
            val uri = bundle.getParcelableCompat("uri", Uri::class.java)
                ?: bundle.getString("uri")?.let { runCatching { Uri.parse(it) }.getOrNull() }
            if (uri == null) continue
            if (mime != null && !mime.startsWith("image/") && mime != "*/*") continue
            copyUriToMedia(context, uri, "msg_img")?.path?.let { out.add(it) }
        }
        // Historic messages sometimes hold older attachments.
        val historic = extras.getParcelableArray(android.app.Notification.EXTRA_HISTORIC_MESSAGES)
        if (historic != null) {
            for (msgObj in historic) {
                val bundle = msgObj as? Bundle ?: continue
                val mime = bundle.getString("type")
                    ?: bundle.getString("mimeType")
                    ?: bundle.getString("dataMimeType")
                val uri = bundle.getParcelableCompat("uri", Uri::class.java)
                    ?: bundle.getString("uri")?.let { runCatching { Uri.parse(it) }.getOrNull() }
                if (uri == null) continue
                if (mime != null && !mime.startsWith("image/") && mime != "*/*") continue
                copyUriToMedia(context, uri, "msg_img")?.path?.let { out.add(it) }
            }
        }
        return out
    }

    private fun iconToSaved(context: Context, icon: Icon?, prefix: String): ExtractedMedia? {
        if (icon == null) return null
        return try {
            val drawable = icon.loadDrawable(context) ?: return null
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val w = drawable.intrinsicWidth.takeIf { it > 0 } ?: 256
                    val h = drawable.intrinsicHeight.takeIf { it > 0 } ?: 256
                    val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bmp)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bmp
                }
            }
            saveBitmap(context, bitmap, prefix)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to extract icon", e)
            null
        }
    }

    private fun copyUriToMedia(context: Context, uri: Uri, prefix: String): ExtractedMedia? {
        return try {
            // Prefer ImageDecoder (handles HEIF/WebP better) when possible.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    val source = ImageDecoder.createSource(context.contentResolver, uri)
                    val bitmap = ImageDecoder.decodeBitmap(source) { decoder, _, _ ->
                        decoder.isMutableRequired = false
                        decoder.allocator = ImageDecoder.ALLOCATOR_SOFTWARE
                    }
                    val saved = saveBitmap(context, bitmap, prefix)
                    if (saved != null) return saved
                } catch (e: Exception) {
                    Log.w(TAG, "ImageDecoder failed for $uri, fallback stream", e)
                }
            }

            context.contentResolver.openInputStream(uri)?.use { input ->
                val mediaDir = File(context.filesDir, MEDIA_DIR)
                if (!mediaDir.exists()) mediaDir.mkdirs()
                val bytes = input.readBytes()
                if (bytes.isEmpty()) return null
                val hash = sha1Hex(bytes).take(12)
                val ext = guessExt(context, uri, bytes)
                val file = File(mediaDir, "${prefix}_${hash}.$ext")
                if (!file.exists()) {
                    FileOutputStream(file).use { it.write(bytes) }
                }
                ExtractedMedia(file.absolutePath, file.name)
            }
        } catch (e: SecurityException) {
            Log.w(TAG, "No permission to read media uri: $uri")
            null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy uri $uri", e)
            null
        }
    }

    private fun saveBitmap(context: Context, bitmap: Bitmap?, prefix: String): ExtractedMedia? {
        if (bitmap == null || bitmap.isRecycled) return null
        return try {
            val scaled = scaleDown(bitmap, MAX_EDGE)
            val mediaDir = File(context.filesDir, MEDIA_DIR)
            if (!mediaDir.exists()) mediaDir.mkdirs()

            // Hash pixels lightly via size + a few samples + byte length estimate.
            val keySeed = "${scaled.width}x${scaled.height}_${scaled.getPixel(0, 0)}_${scaled.getPixel(scaled.width / 2, scaled.height / 2)}"
            val hash = sha1Hex(keySeed.toByteArray()).take(12)
            val file = File(mediaDir, "${prefix}_${hash}.jpg")
            if (!file.exists() || file.length() == 0L) {
                FileOutputStream(file).use { out ->
                    scaled.compress(Bitmap.CompressFormat.JPEG, 88, out)
                }
            }
            ExtractedMedia(file.absolutePath, file.name)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save bitmap", e)
            null
        }
    }

    private fun scaleDown(src: Bitmap, maxEdge: Int): Bitmap {
        val w = src.width
        val h = src.height
        val edge = maxOf(w, h)
        if (edge <= maxEdge) return src
        val scale = maxEdge.toFloat() / edge
        val nw = (w * scale).toInt().coerceAtLeast(1)
        val nh = (h * scale).toInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(src, nw, nh, true)
    }

    private fun guessExt(context: Context, uri: Uri, bytes: ByteArray): String {
        val mime = runCatching { context.contentResolver.getType(uri) }.getOrNull()
        return when {
            mime?.contains("png") == true -> "png"
            mime?.contains("webp") == true -> "webp"
            mime?.contains("gif") == true -> "gif"
            mime?.contains("heic") == true || mime?.contains("heif") == true -> "heic"
            bytes.size >= 3 && bytes[0] == 0xFF.toByte() && bytes[1] == 0xD8.toByte() -> "jpg"
            bytes.size >= 8 && bytes[0] == 0x89.toByte() && bytes[1] == 0x50.toByte() -> "png"
            else -> "bin"
        }
    }

    private fun sha1Hex(data: ByteArray): String {
        val d = MessageDigest.getInstance("SHA-1").digest(data)
        return d.joinToString("") { "%02x".format(it) }
    }

    private fun sha1Hex(data: String): String = sha1Hex(data.toByteArray())

    @Suppress("DEPRECATION")
    private fun <T> Bundle.getParcelableCompat(key: String, clazz: Class<T>): T? {
        return try {
            if (Build.VERSION.SDK_INT >= 33) {
                getParcelable(key, clazz)
            } else {
                @Suppress("UNCHECKED_CAST")
                getParcelable(key) as? T
            }
        } catch (_: Exception) {
            null
        }
    }
}
