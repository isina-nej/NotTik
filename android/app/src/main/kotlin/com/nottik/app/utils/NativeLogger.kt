package com.nottik.app.utils

import android.content.Context
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object NativeLogger {
    private const val MAX_FILE_SIZE = 2 * 1024 * 1024 // 2MB
    private const val MAX_FILES = 3
    private var currentLogFile: File? = null
    private var isInitialized = false
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.US)

    fun init(context: Context) {
        if (isInitialized) return
        try {
            val logDir = File(context.filesDir, "logs")
            if (!logDir.exists()) {
                logDir.mkdirs()
            }
            currentLogFile = File(logDir, "native_0.log")
            isInitialized = true
            
            // Set unhandled exception handler
            val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
            Thread.setDefaultUncaughtExceptionHandler { thread, exception ->
                error("UncaughtException", "Crash in thread ${thread.name}", exception)
                defaultHandler?.uncaughtException(thread, exception)
            }
            
            info("Logger", "Native Logger initialized")
        } catch (e: Exception) {
            Log.e("NativeLogger", "Failed to init NativeLogger", e)
        }
    }

    fun info(tag: String, message: String) {
        log("INFO", tag, message, null)
    }

    fun error(tag: String, message: String, throwable: Throwable? = null) {
        log("ERROR", tag, message, throwable)
    }

    fun debug(tag: String, message: String) {
        log("DEBUG", tag, message, null)
    }

    @Synchronized
    private fun log(level: String, tag: String, message: String, throwable: Throwable?) {
        Log.println(if (level == "ERROR") Log.ERROR else Log.INFO, tag, message)
        
        if (!isInitialized || currentLogFile == null) return

        try {
            if (currentLogFile!!.exists() && currentLogFile!!.length() > MAX_FILE_SIZE) {
                rotateFiles()
            }

            val timestamp = dateFormat.format(Date())
            val logLine = StringBuilder().apply {
                append("[$timestamp] [$level] [$tag] $message")
                if (throwable != null) {
                    append("\nException: ${Log.getStackTraceString(throwable)}")
                }
                append("\n")
            }.toString()

            FileOutputStream(currentLogFile, true).use {
                it.write(logLine.toByteArray(Charsets.UTF_8))
            }
        } catch (e: Exception) {
            Log.e("NativeLogger", "Failed to write log", e)
        }
    }

    private fun rotateFiles() {
        try {
            val dir = currentLogFile!!.parentFile
            for (i in MAX_FILES - 1 downTo 0) {
                val oldFile = File(dir, "native_$i.log")
                if (oldFile.exists()) {
                    if (i == MAX_FILES - 1) {
                        oldFile.delete()
                    } else {
                        oldFile.renameTo(File(dir, "native_${i + 1}.log"))
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("NativeLogger", "Failed to rotate files", e)
        }
    }
}
