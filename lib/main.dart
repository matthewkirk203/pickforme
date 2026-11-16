import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PickForMeApp());
}

class PickForMeApp extends StatelessWidget {
  const PickForMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Calming, friendly palette suitable for therapeutic use.
    const seed = Color(0xFF3A7CA5); // soft therapeutic blue
    return MaterialApp(
      title: 'Pick For Me',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

