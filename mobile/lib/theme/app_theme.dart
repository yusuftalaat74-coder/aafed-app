import 'package:flutter/material.dart';

/// هوية AAFED البصرية — كحلي + أخضر
class AppColors {
  static const navy = Color(0xFF0E3449);
  static const navyLight = Color(0xFF16475C);
  static const green = Color(0xFF2E7D43);
  static const greenBright = Color(0xFF7CB342);
  static const lime = Color(0xFF8DC044);
  static const gold = Color(0xFFCF9A33);
  static const cream = Color(0xFFFAF9F5);
  static const ink = Color(0xFF1B2A22);
  static const muted = Color(0xFF728076);
  static const line = Color(0xFFE6ECE8);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navy,
          primary: AppColors.navy,
          secondary: AppColors.green,
        ),
        fontFamily: 'Tajawal',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}
