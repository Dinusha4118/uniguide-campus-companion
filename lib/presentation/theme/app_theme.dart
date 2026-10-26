import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 16.0;
  static const double buttonHeight = 52.0;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.softCloud,
    primaryColor: AppColors.deepNavy,
    colorScheme: const ColorScheme.light(
      primary: AppColors.deepNavy,
      secondary: AppColors.campusOrange,
      surface: AppColors.cardLight,
      error: AppColors.alertRed,
      onPrimary: Colors.white,
      onSecondary: AppColors.deepNavy,
      onSurface: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.poppinsFont,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.deepNavy,
      ),
      iconTheme: IconThemeData(color: AppColors.deepNavy),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.campusOrange,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        minimumSize: const Size.fromHeight(buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.poppinsFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepNavy,
        minimumSize: const Size.fromHeight(buttonHeight),
        side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.poppinsFont,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.campusOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.alertRed),
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.interFont,
        color: AppColors.textLightMuted,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.night,
    primaryColor: AppColors.campusOrange,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.campusOrange,
      secondary: AppColors.campusOrange,
      surface: AppColors.cardDark,
      error: AppColors.alertRed,
      onPrimary: AppColors.deepNavy,
      onSecondary: AppColors.deepNavy,
      onSurface: AppColors.textDarkHigh,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.poppinsFont,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDarkHigh,
      ),
      iconTheme: IconThemeData(color: AppColors.textDarkHigh),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: AppColors.borderDark, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.campusOrange,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        minimumSize: const Size.fromHeight(buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.poppinsFont,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textDarkHigh,
        minimumSize: const Size.fromHeight(buttonHeight),
        side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.poppinsFont,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDarkElevated,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.campusOrange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        borderSide: const BorderSide(color: AppColors.alertRed),
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.interFont,
        color: AppColors.textDarkMuted,
        fontSize: 14,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
