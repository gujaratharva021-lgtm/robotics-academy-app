import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color + text token system for the app.
/// Mirrors the poster's dark navy / electric blue / gold identity.
class AppColors {
  static const bg0 = Color(0xFF070B16);
  static const bg1 = Color(0xFF0C1326);
  static const panel = Color(0xFF141D38);
  static const panelHi = Color(0xFF1A2544);
  static const line = Color(0x12FFFFFF); // ~7% white
  static const lineHi = Color(0x24FFFFFF); // ~14% white

  static const blue = Color(0xFF4C6FFF);
  static const blueHi = Color(0xFF6E8CFF);
  static const cyan = Color(0xFF35D2E8);
  static const purple = Color(0xFF8B5CF6);
  static const gold = Color(0xFFF5B942);
  static const green = Color(0xFF34D399);
  static const red = Color(0xFFF0576B);

  static const text0 = Color(0xFFF3F6FF);
  static const text1 = Color(0xFFB7C1DE);
  static const text2 = Color(0xFF7987A8);
}

class AppText {
  static TextStyle display({
    double size = 20,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.text0,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.2,
      );

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.text0,
  }) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static TextStyle muted({double size = 12.5}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w400, color: AppColors.text2);

  static TextStyle mono({double size = 12, Color color = AppColors.text1}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: FontWeight.w500, color: color);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg1,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.purple,
      surface: AppColors.panel,
    ),
    splashFactory: InkRipple.splashFactory,
  );
}

/// Reusable rounded-rect gradient card decoration.
BoxDecoration panelDecoration({double radius = 22}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.panelHi, AppColors.panel],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.line),
  );
}