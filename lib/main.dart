import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const PomoPandaApp());
}

class PomoPandaApp extends StatelessWidget {
  const PomoPandaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PomoPanda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'SF Pro Text', // iOS default font
      ),
      home: const MainNavigation(),
    );
  }
}

