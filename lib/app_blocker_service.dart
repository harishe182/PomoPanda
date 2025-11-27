import 'package:flutter/services.dart';

class AppBlocker {
  static const MethodChannel _channel = MethodChannel("app_blocker/channel");

  static Future<void> openAccessibilitySettings() async {
    await _channel.invokeMethod("openAccessibilitySettings");
  }

  static Future<void> startBlocking() async {
    await _channel.invokeMethod("startBlockerService");
  }

  static Future<void> stopBlocking() async {
    await _channel.invokeMethod("stopBlockerService");
  }
}
