package com.example.pomo_panda

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pomo_panda/blocker_channel"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Pass the Flutter engine to the accessibility service
        AppBlockerService.setFlutterEngine(flutterEngine)
        
        // Set up the method channel here as well
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "goHome") {
                // This will be called from Flutter when user clicks the button
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}