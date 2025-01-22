import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    onSurface: Colors.black,
    primary: Colors.grey.shade300,
    onPrimary: Colors.black,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.black,
    outline: Color(0xFF424242),
  ),
  useMaterial3: true,
  fontFamily: 'Poppins',
);

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    onSurface: Colors.white,
    primary: Colors.grey.shade800,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade700,
    onSecondary: Colors.white,
  ),
  useMaterial3: true,
  fontFamily: 'Poppins',
);
