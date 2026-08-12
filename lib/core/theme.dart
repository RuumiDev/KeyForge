import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimalist Dark tokens for KeyForge
abstract final class KF {
  // ── Color Tokens ──
  static const scaffold    = Color(0xFF090D16);
  static const surface     = Color(0xFF111827);
  static const surfaceHigh = Color(0xFF1F2937);
  static const primary     = Color(0xFF3B82F6);
  static const secondary   = Color(0xFF10B981);
  static const textPrimary = Color(0xFFF9FAFB);
  static const textMuted   = Color(0xFF9CA3AF);
  static const error       = Color(0xFFEF4444);
  static const border      = Color(0xFF1E293B);

  // ── Radius ──
  static const cardRadius = 14.0;

  // ── Theme ──
  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: scaffold,
    colorScheme: const ColorScheme.dark(
      surface: surface,
      primary: primary,
      secondary: secondary,
      error: error,
      onPrimary: textPrimary,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: border),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: textPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffold,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
    ),
  );
}
