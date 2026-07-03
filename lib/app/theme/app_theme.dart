import 'package:flutter/material.dart';
import 'package:midas/app/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4A23A8);
  static const Color primaryDark = Color(0xFF2B0A76);
  static const Color scaffold = Color(0xFFF2F2F5);

  static ThemeData lightTheme() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffold,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: AppTextStyles.textTheme(base.textTheme),
      primaryColor: primary,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x334A23A8),
        selectionHandleColor: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: AppTextStyles.body(color: Colors.white, weight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          textStyle: AppTextStyles.button(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyles.body(color: Colors.black38),
        labelStyle: AppTextStyles.body(color: Colors.black54),
        prefixIconColor: Colors.black54,
        suffixIconColor: Colors.black54,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C3C3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC3C3C3)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTextStyles.drawerItem(),
        iconColor: Colors.black87,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }
}
