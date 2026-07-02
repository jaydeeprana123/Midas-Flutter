import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4A23A8);
  static const Color primaryDark = Color(0xFF2B0A76);
  static const Color scaffold = Color(0xFFF2F2F5);

  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: scaffold,
      useMaterial3: true,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C3C3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C3C3)),
        ),
      ),
    );
  }
}
