import 'package:flutter/material.dart';

// Custom gradient background for light mode
final lightGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 255, 255, 255),
      Color.fromARGB(255, 220, 220, 220),
      Color.fromARGB(255, 198, 198, 198),
      Color.fromARGB(255, 138, 138, 138),
    ],
  ),
);

// Custom gradient background for dark mode
final darkGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 11, 11, 17),
      Color.fromARGB(255, 26, 26, 26),
      Color.fromARGB(255, 2, 3, 4),
      Color.fromARGB(255, 8, 8, 23),
    ],
  ),
);

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.transparent,
    onSurface: Colors.black,
    primary: Colors.brown.shade300,
    onPrimary: Colors.black,
    secondary: Colors.brown.shade200,
    onSecondary: Colors.black,
    outline: Color(0xFF424242),
    background: Colors.transparent,
  ),
  scaffoldBackgroundColor: Colors.transparent,
  useMaterial3: true,
  fontFamily: 'Poppins',
  cardColor: Colors.white.withOpacity(0.85),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.transparent,
    onSurface: Colors.white,
    primary: Colors.brown.shade700,
    onPrimary: Colors.white,
    secondary: Colors.brown.shade600,
    onSecondary: Colors.white,
    background: Colors.transparent,
  ),
  scaffoldBackgroundColor: Colors.transparent,
  useMaterial3: true,
  fontFamily: 'Poppins',
  cardColor: Colors.grey.shade900.withOpacity(0.85),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);
