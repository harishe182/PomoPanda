import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlockerScreen extends StatelessWidget {
  final String blockedApp;
  final VoidCallback? onDismiss;

  const BlockerScreen({super.key, required this.blockedApp, this.onDismiss});

  String _getAppName(String packageName) {
    if (packageName.contains('youtube')) return 'YouTube';
    if (packageName.contains('instagram')) return 'Instagram';
    if (packageName.contains('snapchat')) return 'Snapchat';
    if (packageName.contains('tiktok') || packageName.contains('musically'))
      return 'TikTok';
    return 'Distracting App';
  }

  @override
  Widget build(BuildContext context) {
    final appName = _getAppName(blockedApp);

    return PopScope(
      canPop: false, // Prevent back button from dismissing
      child: Scaffold(
        backgroundColor: const Color(0xFFC62828),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  '🐼',
                  style: TextStyle(
                    fontSize: 100,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black54,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'STOP! Focus Mode is ON.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'The PomoPanda is guarding your time. $appName is blocked during your focus session!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    onDismiss?.call();
                    // Just pop the blocker screen, don't minimize the app
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'I UNDERSTAND. GO BACK',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
