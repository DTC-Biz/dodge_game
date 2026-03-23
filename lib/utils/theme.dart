import 'package:flutter/material.dart';

class AppTheme {
  // 배경
  static const Color background = Color(0xFF090909);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceHigh = Color(0xFF1A1A1A);

  // 텍스트
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF666666);
  static const Color textMuted = Color(0xFF333333);

  // 액센트
  static const Color accentBlue = Color(0xFF7B9CFF);
  static const Color accentPurple = Color(0xFF9F99F0);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentGreen = Color(0xFF44FF44);

  // 보더
  static const Color border = Color(0xFF1E1E1E);
  static const Color borderHigh = Color(0xFF2A2A2A);

  // 그리드
  static const Color gridLine = Color(0xFF111111);

  // 게임 오브젝트 (기존 유지)
  static const Color player = Colors.white;
  static const Color playerCenter = Color(0xFF090909);
  static const Color playerRing = Colors.white;
  static const Color obstacle = Color(0xFFE63946);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: Colors.white,
          secondary: accentPurple,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: textPrimary),
          bodySmall: TextStyle(color: textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textPrimary,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: surface,
          contentTextStyle: TextStyle(color: textPrimary),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}
