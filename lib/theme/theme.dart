import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    onSurface: Colors.black,
    primary: Colors.grey.shade800,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.black,
    outline: Color(0xFF424242),
    background: Colors.grey[50]!,
  ),
  scaffoldBackgroundColor: Colors.grey[50]!,
  useMaterial3: true,
  fontFamily: 'Poppins',
  textTheme: TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -1.5),
    displayMedium: TextStyle(fontWeight: FontWeight.w300, letterSpacing: -0.5),
    displaySmall: TextStyle(fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.25),
    headlineSmall: TextStyle(fontWeight: FontWeight.w500),
    titleLarge: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontWeight: FontWeight.w400, letterSpacing: 0.25),
  ),
  cardColor: Colors.white,
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.black.withOpacity(0.1),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.black,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade800),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade800,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade800, width: 1.5),
    ),
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,
    primary: Colors.grey.shade300,
    onPrimary: Colors.black,
    secondary: Colors.grey.shade700,
    onSecondary: Colors.white,
    outline: Colors.grey.shade500,
    background: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.black,
  useMaterial3: true,
  fontFamily: 'Poppins',
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontWeight: FontWeight.w300, letterSpacing: -1.5, color: Colors.white),
    displayMedium: TextStyle(
        fontWeight: FontWeight.w300, letterSpacing: -0.5, color: Colors.white),
    displaySmall: TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
    headlineMedium: TextStyle(
        fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white),
    headlineSmall: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
    titleLarge: TextStyle(
        fontWeight: FontWeight.w500, letterSpacing: 0.15, color: Colors.white),
    titleMedium: TextStyle(
        fontWeight: FontWeight.w600, letterSpacing: 0.15, color: Colors.white),
    titleSmall: TextStyle(
        fontWeight: FontWeight.w600, letterSpacing: 0.1, color: Colors.white),
    bodyLarge: TextStyle(
        fontWeight: FontWeight.w400, letterSpacing: 0.5, color: Colors.white),
    bodyMedium: TextStyle(
        fontWeight: FontWeight.w400, letterSpacing: 0.25, color: Colors.white),
  ),
  cardColor: Color(0xFF1E1E1E),
  cardTheme: CardTheme(
    elevation: 8,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    shadowColor: Colors.white.withOpacity(0.1),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    elevation: 0,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.grey.shade300),
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.grey.shade300,
      foregroundColor: Colors.black,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E1E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
    ),
  ),
);
