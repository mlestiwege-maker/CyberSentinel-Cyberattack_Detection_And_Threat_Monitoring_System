import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF0A0E27);
  static const Color secondaryBlack = Color(0xFF1A1F3A);
  static const Color accentBlue = Color(0xFF0099FF);
  static const Color dangerRed = Color(0xFFFF3333);
  static const Color warningOrange = Color(0xFFFF9900);
  static const Color successGreen = Color(0xFF00DD88);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B5C0);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryBlack,
    primaryColor: accentBlue,
    cardColor: secondaryBlack,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: textWhite),
      bodySmall: TextStyle(color: textGrey),
      headlineSmall: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF3F5FA),
    primaryColor: accentBlue,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: accentBlue,
      secondary: accentBlue,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1F2430)),
      bodySmall: TextStyle(color: Color(0xFF5D6472)),
      headlineSmall: TextStyle(color: Color(0xFF1F2430), fontWeight: FontWeight.bold),
    ),
  );
}
