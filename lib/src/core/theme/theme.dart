import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0F766E),
      onPrimary: Colors.white,
      secondary: Color(0xFF2563EB),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFF8FAFC),
      onSurface: Color(0xFF0F172A),
      surfaceContainerHighest: Color(0xFFE2E8F0),
      onSurfaceVariant: Color(0xFF475569),
      outline: Color(0xFF94A3B8),
      shadow: Color(0x14000000),
      inverseSurface: Color(0xFF1E293B),
      onInverseSurface: Color(0xFFF8FAFC),
      inversePrimary: Color(0xFF5EEAD4),
      tertiary: Color(0xFF7C3AED),
      onTertiary: Colors.white,
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF5EEAD4),
      onPrimary: Color(0xFF042F2E),
      secondary: Color(0xFF93C5FD),
      onSecondary: Color(0xFF172554),
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      surface: Color(0xFF020617),
      onSurface: Color(0xFFE2E8F0),
      surfaceContainerHighest: Color(0xFF1E293B),
      onSurfaceVariant: Color(0xFFCBD5E1),
      outline: Color(0xFF64748B),
      shadow: Color(0x26000000),
      inverseSurface: Color(0xFFE2E8F0),
      onInverseSurface: Color(0xFF0F172A),
      inversePrimary: Color(0xFF115E59),
      tertiary: Color(0xFFC4B5FD),
      onTertiary: Color(0xFF2E1065),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      cardTheme: CardTheme(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
      ),
    );
  }
}
