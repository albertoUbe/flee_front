import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5B4FCF);
  static const Color activeColor = Color(0xFF4CAF50);
  static const Color ghostColor = Color(0xFFFF9800);
  static const Color endedColor = Color(0xFFF44336);

  static Color communityStatusColor(String status) {
    switch (status) {
      case 'Active':
        return activeColor;
      case 'Ghost':
        return ghostColor;
      case 'Ended':
        return endedColor;
      default:
        return Colors.grey;
    }
  }

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
}
