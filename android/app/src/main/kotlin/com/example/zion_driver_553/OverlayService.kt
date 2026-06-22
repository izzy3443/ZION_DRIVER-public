package com.example.zion_driver_553

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.util.Log
import android.view.*
import android.widget.*
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import android.animation.ValueAnimator

class OverlayService : Service() {

    private var windowManager: WindowManager? = null
    private var overlayView: View? = null
    private var tripIdGlobal: String = "unknown"

    override fun onCreate() {
        super.onCreate()
        Log.d("OverlayService", "🧠 onCreate")

        Thread.setDefaultUncaughtExceptionHandler { _, throwable ->
            Log.e("OverlayService", "💥 Uncaught Exception: ${throwable.message}", throwable)
            showCustomToast(
                title = "Unexpected Error",
                subtitle = "Service encountered an issue",
                isAccepted = false
            )
            stopSelf()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("OverlayService", "🟢 Service started")

        startForeground(1, createNotification())

        val tripId = intent?.getStringExtra("tripId") ?: "Unknown"
        tripIdGlobal = tripId
        val passengerName = intent?.getStringExtra("passengerName") ?: "Passenger"
        val pickup = intent?.getStringExtra("pickup") ?: "Unknown"
        val dropoff = intent?.getStringExtra("dropoff") ?: "Unknown"
        val fairAmount = intent?.getStringExtra("fairAmount") ?: "?"
        val duration = intent?.getStringExtra("duration") ?: "ETA Unknown"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            Log.e("OverlayService", "❌ Overlay permission not granted")
            showCustomToast(
                title = "Permission Missing",
                subtitle = "Overlay permission not granted",
                isAccepted = false
            )
            stopSelf()
            return START_NOT_STICKY
        }

        showOverlay(tripId, passengerName, pickup, dropoff, fairAmount, duration)
        return START_STICKY
    }

    private fun createNotification(): Notification {
        val channelId = "overlay_channel_id"
        val channelName = "Overlay Notification"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(chan)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Trip Request Active")
            .setContentText("Tap to respond to trip")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    // ─────────────────────────────────────────────
    // Custom Toast Helper
    // ─────────────────────────────────────────────
    private fun showCustomToast(
        title: String,
        subtitle: String,
        isAccepted: Boolean
    ) {
        Handler(Looper.getMainLooper()).post {
            try {
                val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
                val layout = inflater.inflate(R.layout.custom_toast, null)

                // Colors
                val bgColor     = if (isAccepted) Color.parseColor("#EAF3DE") else Color.parseColor("#FCEBEB")
                val iconBgColor = if (isAccepted) Color.parseColor("#639922") else Color.parseColor("#A32D2D")
                val borderColor = if (isAccepted) Color.parseColor("#97C459") else Color.parseColor("#F09595")
                val titleColor  = if (isAccepted) Color.parseColor("#27500A") else Color.parseColor("#501313")
                val subColor    = if (isAccepted) Color.parseColor("#3B6D11") else Color.parseColor("#791F1F")
                val iconRes     = if (isAccepted) android.R.drawable.ic_menu_directions
                                  else            android.R.drawable.ic_menu_close_clear_cancel

                // Root background
                val root = layout.findViewById<LinearLayout>(R.id.toast_root)
                val rootBg = GradientDrawable().apply {
                    setColor(bgColor)
                    setStroke(4, borderColor)
                    cornerRadius = 48f
                }
                root.background = rootBg

                // Icon circle background + icon
                val iconView = layout.findViewById<ImageView>(R.id.toast_icon)
                val iconCircle = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(iconBgColor)
                }
                iconView.background = iconCircle
                iconView.setImageResource(iconRes)
                iconView.setColorFilter(Color.WHITE)

                // Text
                layout.findViewById<TextView>(R.id.toast_title).apply {
                    text = title
                    setTextColor(titleColor)
                }
                layout.findViewById<TextView>(R.id.toast_subtitle).apply {
                    text = subtitle
                    setTextColor(subColor)
                }

                // Show toast
                @Suppress("DEPRECATION")
                Toast(applicationContext).apply {
                    duration = Toast.LENGTH_LONG
                    view = layout
                    setGravity(Gravity.TOP or Gravity.CENTER_HORIZONTAL, 0, 80)
                    show()
                }

            } catch (e: Exception) {
                Log.e("OverlayService", "❌ Custom toast error: ${e.message}", e)
                // Fallback to system toast if custom one fails
                Toast.makeText(applicationContext, title, Toast.LENGTH_SHORT).show()
            }
        }
    }

    // ─────────────────────────────────────────────
    // Overlay
    // ─────────────────────────────────────────────
    private fun showOverlay(
        tripId: String,
        passengerName: String,
        pickup: String,
        dropoff: String,
        fairAmount: String,
        duration: String
    ) {
        if (overlayView != null) {
            Log.w("OverlayService", "⚠️ Overlay already shown. Skipping...")
            return
        }

        try {
            windowManager = getSystemService(WINDOW_SERVICE) as? WindowManager
            val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
            overlayView = inflater.inflate(R.layout.trip_overlay_layout, null)

            overlayView?.apply {
                findViewById<TextView>(R.id.pickupText)?.text = "Pickup: $pickup"
                findViewById<TextView>(R.id.dropoffText)?.text = "Dropoff: $dropoff"
                findViewById<TextView>(R.id.fairAmountText)?.text = "₹$fairAmount"
                findViewById<TextView>(R.id.durationText)?.text = "Trip duration: $duration"

                val progressFill = findViewById<View>(R.id.progressFill)
                val acceptButton = findViewById<Button>(R.id.acceptButton)

                // ✅ Accept Button
                acceptButton.setOnClickListener {
                    showCustomToast(
                        title    = "Trip Accepted!",
                        subtitle = "Navigating to pickup location...",
                        isAccepted = true
                    )
                    Log.i("OverlayService", "✅ Trip Accepted")
                    launchFlutterAndNotify("tripAccepted", tripId)
                    removeOverlay()
                }

                // ❌ Reject Button
                findViewById<ImageView>(R.id.closeButton)?.setOnClickListener {
                    showCustomToast(
                        title    = "Trip Rejected",
                        subtitle = "Looking for your next trip...",
                        isAccepted = false
                    )
                    Log.i("OverlayService", "❌ Trip Rejected via Close Button")
                    removeOverlay()
                }

                // ⏱ Progress bar + auto-dismiss after 10s
                acceptButton.post {
                    val fullWidth = acceptButton.width
                    val animator = ValueAnimator.ofInt(0, fullWidth)
                    animator.duration = 10_000L

                    animator.addUpdateListener { valueAnimator ->
                        val animatedValue = valueAnimator.animatedValue as Int
                        val lp = progressFill.layoutParams
                        lp.width = animatedValue
                        progressFill.layoutParams = lp
                    }

                    animator.start()

                    Handler(Looper.getMainLooper()).postDelayed({
                        if (overlayView != null) {
                            Log.i("OverlayService", "⏱️ Timer expired - auto removing overlay")
                            removeOverlay()
                        }
                    }, 10_000L)
                }
            }

            val params = WindowManager.LayoutParams(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                else
                    WindowManager.LayoutParams.TYPE_PHONE,
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                PixelFormat.TRANSLUCENT
            )

            params.gravity = Gravity.BOTTOM or Gravity.CENTER_HORIZONTAL
            params.y = 0

            windowManager?.addView(overlayView, params)
            Log.d("OverlayService", "🪟 Overlay added to window manager")

        } catch (e: Exception) {
            Log.e("OverlayService", "🔥 Error showing overlay: ${e.message}", e)
            showCustomToast(
                title    = "Overlay Error",
                subtitle = e.message ?: "Something went wrong",
                isAccepted = false
            )
            stopSelf()
        }
    }

    // ─────────────────────────────────────────────
    // Flutter Communication
    // ─────────────────────────────────────────────
    private fun launchFlutterAndNotify(method: String, tripId: String) {
        val context = applicationContext
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        context.startActivity(launchIntent)
        sendFlutterMessage(method, tripId)
    }

    private fun sendFlutterMessage(method: String, tripId: String) {
        try {
            val engine = FlutterEngineCache.getInstance()["main_engine"]
            if (engine == null) {
                Log.e("OverlayService", "🚫 FlutterEngine not found in cache")
                return
            }
            MethodChannel(engine.dartExecutor.binaryMessenger, "trip_channel")
                .invokeMethod(method, tripId)
            Log.d("OverlayService", "📡 Sent $method to Flutter with tripId $tripId")
        } catch (e: Exception) {
            Log.e("OverlayService", "❌ Failed to send message to Flutter: ${e.message}", e)
        }
    }

    // ─────────────────────────────────────────────
    // Cleanup
    // ─────────────────────────────────────────────
    private fun removeOverlay() {
        try {
            if (overlayView != null && windowManager != null) {
                Handler(mainLooper).post {
                    try {
                        windowManager?.removeView(overlayView)
                        Log.d("OverlayService", "🧹 Overlay removed safely")
                        overlayView = null
                        stopSelf()
                    } catch (e: Exception) {
                        Log.e("OverlayService", "⚠️ Error removing overlay: ${e.message}", e)
                        stopSelf()
                    }
                }
            } else {
                Log.w("OverlayService", "❗ No overlay to remove")
                stopSelf()
            }
        } catch (e: Exception) {
            Log.e("OverlayService", "⚠️ Error in removeOverlay: ${e.message}", e)
            stopSelf()
        }
    }

    override fun onDestroy() {
        Log.d("OverlayService", "🛑 Service destroyed")
        try {
            overlayView?.let {
                windowManager?.removeView(it)
                Log.d("OverlayService", "🧹 Overlay removed in onDestroy")
            }
        } catch (e: Exception) {
            Log.e("OverlayService", "⚠️ Error in onDestroy cleanup: ${e.message}", e)
        }
        overlayView = null
        windowManager = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}