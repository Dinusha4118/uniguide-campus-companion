import 'package:flutter/material.dart';

class AppTypography {
  static const String poppinsFont = 'Poppins';
  static const String interFont = 'Inter';
  static const String sinhalaFont = 'NotoSansSinhala';

  static String getFontFamily({required bool isSinhala, bool isHeading = false}) {
    if (isSinhala) return sinhalaFont;
    return isHeading ? poppinsFont : interFont;
  }

  static double getLineHeight({required bool isSinhala}) {
    return isSinhala ? 1.55 : 1.35;
  }

  static TextStyle headingLarge({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: true),
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle headingMedium({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: true),
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle headingSmall({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: true),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle bodyLarge({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: false),
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle bodyMedium({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: false),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle caption({
    required Color color,
    bool isSinhala = false,
  }) {
    return TextStyle(
      fontFamily: getFontFamily(isSinhala: isSinhala, isHeading: false),
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: getLineHeight(isSinhala: isSinhala),
      color: color,
    );
  }

  static TextStyle overlineBadge({
    required Color color,
  }) {
    return TextStyle(
      fontFamily: interFont,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: color,
    );
  }
}
