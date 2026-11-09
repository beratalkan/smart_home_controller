import 'package:flutter/material.dart';

import 'screens/smart_home_screen.dart';

void main() {
  runApp(const SmartHomeControllerApp());
}

/// Root widget for BIM493 Mobile Programming I - Assignment #2:
/// Smart Home Controller App.
class SmartHomeControllerApp extends StatelessWidget {
  const SmartHomeControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E5BB8),
          brightness: Brightness.light,
        ),
      ),
      home: const SmartHomeScreen(),
    );
  }
}
