import 'package:flutter/material.dart';

class AppTheme {
  // 배경 블랙
  static const Color background   = Color(0xFF000000);
  static const Color player       = Color(0xFF111111);
  static const Color playerCenter = Color(0xFFFFFFFF);
  static const Color obstacle     = Color(0xFFE63946);
  static const Color gridLine     = Color(0xFF1A1A1A);
  static const Color scoreText    = Color(0xFFFFFFFF);
  static const Color levelText    = Color(0xFF888888);
  static const Color progressBar  = Color(0xFF333333);
  static const Color progressFill = Color(0xFFFFFFFF);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    fontFamily: 'SF Pro Display',
    colorScheme: const ColorScheme.dark(
      surface: background,
      primary: Colors.white,
    ),
  );
}