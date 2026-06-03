// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5B4FCF);
  static const Color activeColor = Color(0xFF4CAF50);
  static const Color ghostColor = Color(0xFFFF9800);
  static const Color endedColor = Color(0xFFF44336);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color buttonBlue = Color(0xFF1E88E5);

  // Colores oscuros (constantes para uso sin contexto)
  static const Color bgDark = Color(0xFF0A0F1F);
  static const Color textMuted = Color(0xFF9BB4D1);
  static const Color gradientStart = Color(0xFF131C35);
  static const Color gradientEnd = Color(0xFF040712);

  // ── Helpers dependientes del contexto ──────────────────────────────────────

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color cardBackground(BuildContext context) => isDark(context)
      ? const Color(0xFF0F172A).withValues(alpha: 0.6)
      : Colors.white;

  static Color scaffoldBg(BuildContext context) =>
      isDark(context) ? bgDark : const Color(0xFFF0F4F8);

  static Color sidebarBg(BuildContext context) =>
      isDark(context) ? bgDark : Colors.white;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF1A1A2E);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? textMuted : const Color(0xFF6B7280);

  static Color borderColor(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.06)
      : Colors.black.withValues(alpha: 0.08);

  static Color dialogBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF131C35) : Colors.white;

  static Color headerBg(BuildContext context) => isDark(context)
      ? const Color(0xFF0F172A).withValues(alpha: 0.4)
      : const Color(0xFFE8EEF5);

  static Color iconMuted(BuildContext context) => isDark(context)
      ? textMuted.withValues(alpha: 0.5)
      : const Color(0xFF9CA3AF);

  static Color placeholderBg(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.04)
      : const Color(0xFFE5E7EB);

  static BoxDecoration gradientDecoration(BuildContext context) =>
      isDark(context)
      ? const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.3,
            colors: [gradientStart, gradientEnd],
            stops: [0.0, 1.0],
          ),
        )
      : BoxDecoration(color: scaffoldBg(context));

  // ── Status colors ───────────────────────────────────────────────────────────

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

  // ── Themes ──────────────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF0F4F8),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1A2E),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF1A1A2E),
      iconColor: Color(0xFF6B7280),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentBlue,
      brightness: Brightness.dark,
      surface: bgDark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: bgDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: const TextStyle(color: textMuted),
      hintStyle: TextStyle(color: textMuted.withValues(alpha: 0.5)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: textMuted,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: textMuted),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    dividerTheme: DividerThemeData(color: Colors.white.withValues(alpha: 0.06)),
    dialogTheme: DialogThemeData(
      backgroundColor: gradientStart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
    ),
  );
}
