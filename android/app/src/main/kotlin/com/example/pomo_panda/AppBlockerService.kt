package com.example.pomo_panda

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AppBlockerService : AccessibilityService() {

    private val TAG = "PomoPanda"
    
    private val blockedApps = listOf(
        "com.instagram.android",
        "com.snapchat.android",
        "com.zhiliaoapp.musically", // TikTok
        "com.google.android.youtube"
    )

    private val mainHandler = Handler(Looper.getMainLooper())
    private var lastBlockedApp: String? = null
    private var lastBlockTime: Long = 0
    private val BLOCK_COOLDOWN_MS = 3000L // 3 seconds cooldown

    companion object {
        private const val CHANNEL = "com.example.pomo_panda/blocker_channel"
        private var flutterEngine: FlutterEngine? = null

        fun setFlutterEngine(engine: FlutterEngine) {
            Log.d("PomoPanda", "✓ Flutter engine set!")
            flutterEngine = engine
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "🐼 Accessibility Service Connected!")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val targetPackageName = event.packageName?.toString() ?: return
            
            // Ignore if it's our own app
            if (targetPackageName == applicationContext.packageName) {
                return
            }
            
            // Check if it's a blocked app
            if (blockedApps.contains(targetPackageName)) {
                val currentTime = System.currentTimeMillis()
                
                // Only block if:
                // 1. It's a different app than we just blocked, OR
                // 2. Enough time has passed since the last block
                if (targetPackageName != lastBlockedApp || 
                    (currentTime - lastBlockTime) > BLOCK_COOLDOWN_MS) {
                    
                    Log.d(TAG, "🚫 BLOCKED APP DETECTED: $targetPackageName")
                    lastBlockedApp = targetPackageName
                    lastBlockTime = currentTime
                    
                    blockApp(targetPackageName)
                } else {
                    Log.d(TAG, "⏳ Cooldown active, ignoring: $targetPackageName")
                }
            }
        }
    }

    private fun blockApp(packageName: String) {
        Log.d(TAG, "Blocking app and going home...")
        
        // First, immediately go to home screen to close the blocked app
        performGlobalAction(GLOBAL_ACTION_HOME)
        
        // Then show our app with the blocker screen
        mainHandler.postDelayed({
            launchPomoPanda(packageName)
        }, 300) // Short delay to ensure home action completes
    }

    private fun launchPomoPanda(blockedPackage: String) {
        Log.d(TAG, "Launching PomoPanda...")
        
        try {
            val myPackageName = applicationContext.packageName
            val launchIntent = packageManager.getLaunchIntentForPackage(myPackageName)
            
            if (launchIntent != null) {
                launchIntent.addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or 
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                )
                startActivity(launchIntent)
                
                // Wait for Flutter to initialize
                mainHandler.postDelayed({
                    showBlockerScreen(blockedPackage)
                }, 1000)
                
            } else {
                Log.e(TAG, "❌ Launch intent is NULL!")
            }
        } catch (e: Exception) {
            Log.e(TAG, "❌ Exception launching app: ${e.message}", e)
        }
    }

    private fun showBlockerScreen(packageName: String) {
        Log.d(TAG, "showBlockerScreen called for: $packageName")
        
        val engine = flutterEngine
        
        if (engine == null) {
            Log.e(TAG, "❌ Flutter engine is NULL!")
            return
        }
        
        try {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            
            Log.d(TAG, "Invoking showBlockerScreen method...")
            channel.invokeMethod("showBlockerScreen", packageName, object : MethodChannel.Result {
                override fun success(result: Any?) {
                    Log.d(TAG, "✓ Blocker screen shown successfully!")
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.e(TAG, "❌ Error showing screen: $errorCode - $errorMessage")
                }

                override fun notImplemented() {
                    Log.e(TAG, "❌ Method not implemented in Flutter!")
                }
            })
        } catch (e: Exception) {
            Log.e(TAG, "❌ Channel exception: ${e.message}", e)
        }
    }

    override fun onInterrupt() {
        Log.d(TAG, "Service interrupted")
    }
}