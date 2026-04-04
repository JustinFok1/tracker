import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.background,
    cardColor: AppColors.dark.card,
    dialogBackgroundColor: AppColors.dark.card,
    primaryColor: const Color(0xFFB388FF),
    fontFamily: 'SF Pro',
    extensions: const [AppColors.dark],
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.background,
    cardColor: AppColors.light.card,
    dialogBackgroundColor: AppColors.light.card,
    primaryColor: const Color(0xFFB388FF),
    fontFamily: 'SF Pro',
    extensions: const [AppColors.light],
  );
}
