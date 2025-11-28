import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_navigation.dart';
import 'onboarding_screen.dart';
import 'blocker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  runApp(
    MyApp(isFirstLaunch: isFirstLaunch),
  );
}

class MyApp extends StatefulWidget {
  final bool isFirstLaunch;

  const MyApp({
    Key? key,
    required this.isFirstLaunch,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const platform =
      MethodChannel('com.example.pomo_panda/blocker_channel');

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _isBlockerShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupMethodChannel();
    print("🐼 PomoPanda initialized");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("🐼 App lifecycle state: $state");
  }

  void _setupMethodChannel() {
    platform.setMethodCallHandler((call) async {
      print("🐼 Received method call: ${call.method}");

      if (call.method == "showBlockerScreen") {
        final packageName = call.arguments as String;
        print("🐼 Blocking app: $packageName");

        if (!_isBlockerShowing) {
          _isBlockerShowing = true;
          _showBlockerScreen(packageName);
        }
      }
    });

    print("🐼 Method channel setup complete");
  }

  void _showBlockerScreen(String packageName) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print("🐼 Error: Navigator context is null");
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlockerScreen(
          blockedApp: packageName,
          onDismiss: () {
            _isBlockerShowing = false;
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'PomoPanda',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
      home: widget.isFirstLaunch
          ? const OnboardingScreen()
          : const MainNavigation(),
    );
  }
}
