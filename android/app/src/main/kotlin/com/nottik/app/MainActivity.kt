package com.nottik.app

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import com.nottik.app.pigeon.NativeNotificationApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.nottik.app.service.NottikNotificationListener

class MainActivity: FlutterActivity(), NativeNotificationApi {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        NativeNotificationApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun isListenerConnected(): Boolean {
        val enabledListeners = NotificationManagerCompat.getEnabledListenerPackages(this)
        return enabledListeners.contains(packageName)
    }

    override fun requestRebind() {
        val componentName = ComponentName(this, NottikNotificationListener::class.java)
        NottikNotificationListener.requestRebind(componentName)
    }

    override fun openNotificationSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        startActivity(intent)
    }
}
