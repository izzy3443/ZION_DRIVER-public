package com.example.zion_driver_553

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "overlay_permission_channel"
    private val ENGINE_ID = "main_engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Cache the engine for use in OverlayService
        FlutterEngineCache.getInstance().put(ENGINE_ID, flutterEngine)
        Log.d("OverlayDebug", "FlutterEngine cached with ID: $ENGINE_ID")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d("OverlayDebug", "Received method call: ${call.method}")

            when (call.method) {
                "checkPermission" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    Log.d("OverlayDebug", "Overlay permission granted: $granted")
                    result.success(granted)
                }

                "startOverlay" -> {
                    Log.d("OverlayDebug", "Attempting to start overlay service")
                    val serviceIntent = Intent(this, OverlayService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Log.d("OverlayDebug", "Starting foreground service for overlay")
                        startForegroundService(serviceIntent)
                    } else {
                        Log.d("OverlayDebug", "Starting regular service for overlay")
                        startService(serviceIntent)
                    }
                    result.success(true)
                    Log.d("OverlayDebug", "Overlay service start request sent")
                }

                "stopOverlay" -> {
                    Log.d("OverlayDebug", "Attempting to stop overlay service")
                    val stopIntent = Intent(this, OverlayService::class.java)
                    stopService(stopIntent)
                    result.success(true)
                    Log.d("OverlayDebug", "Overlay service stop request sent")
                }

                else -> {
                    Log.d("OverlayDebug", "Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }

        Log.d("OverlayDebug", "MethodChannel handler set up on $CHANNEL")
    }
}