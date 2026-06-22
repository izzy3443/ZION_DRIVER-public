package com.example.zion_driver_553

import android.content.Intent
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Log.d("FCM", "🔥 Message Received")

        val data = message.data
        val tripId = data["tripId"]
        val passengerName = data["passengerName"]
        val pickup = data["pickup"]
        val dropoff = data["dropoff"]
        val fairAmount = data["fairAmount"]
        val duration = data["duration"]

        if (tripId != null) {
            Log.d("FCM", "📦 Trip Request Received: $tripId")

            val intent = Intent(applicationContext, OverlayService::class.java).apply {
                putExtra("tripId", tripId)
                putExtra("passengerName", passengerName)
                putExtra("pickup", pickup)
                putExtra("dropoff", dropoff)
                putExtra("fairAmount", fairAmount)
                putExtra("duration", duration)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                applicationContext.startForegroundService(intent)
            } else {
                applicationContext.startService(intent)
            }
        } else {
            Log.d("FCM", "❗ No tripId found in payload.")
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "🔑 New Token: $token")
    }
}