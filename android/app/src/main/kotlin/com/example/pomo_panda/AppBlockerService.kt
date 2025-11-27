package com.example.pomo_panda

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.content.Intent

class AppBlockerService : AccessibilityService() {

    private val blockedApps = listOf(
        "com.instagram.android",
        "com.snapchat.android",
        "com.tiktok.android",
        "com.google.android.youtube" // <--- ADDED THIS
    )

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            if (blockedApps.contains(packageName)) {
                // Method 1 (Best for Accessibility Services): Native Global Action
                performGlobalAction(GLOBAL_ACTION_HOME)

                // Method 2 (Your original way): Launch Home Intent
                // Use this if Method 1 fails for some reason
                /*
                val homeIntent = Intent(Intent.ACTION_MAIN)
                homeIntent.addCategory(Intent.CATEGORY_HOME)
                homeIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(homeIntent)
                */
            }
        }
    }

    override fun onInterrupt() {}
}