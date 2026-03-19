import 'package:flutter/material.dart';

class AppTheme {
  static const Color background   = Color(0xFF000000);
  static const Color player       = Color(0xFFFFFFFF); // 흰색으로 변경
  static const Color playerCenter = Color(0xFF000000); // 중앙 검정 점
  static const Color playerRing   = Color(0xFF00E5FF); // 외곽 링 (청록)
  static const Color obstacle     = Color(0xFFE63946);
  static const Color gridLine     = Color(0xFF1A1A1A);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      surface: background,
      primary: Colors.white,
    ),
  );
}