import 'package:flutter/material.dart';

abstract class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Hellix';

  static TextStyle _style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle loginTitle({Color color = Colors.white}) =>
      _style(fontSize: 32, fontWeight: FontWeight.w700, color: color);

  static TextStyle screenTitle({Color color = Colors.white}) =>
      _style(fontSize: 18, fontWeight: FontWeight.w700, height: 1.2, color: color);

  static TextStyle drawerHeader({Color color = Colors.white}) =>
      _style(fontSize: 18, fontWeight: FontWeight.w700, color: color);

  static TextStyle drawerItem({Color color = Colors.black}) =>
      _style(fontSize: 16, fontWeight: FontWeight.w500, color: color);

  static TextStyle tabLabel({required Color color, FontWeight weight = FontWeight.w500}) =>
      _style(fontSize: 15, letterSpacing: 1.2, fontWeight: weight, color: color);

  static TextStyle userLabel({Color color = Colors.black54}) =>
      _style(fontSize: 14, fontWeight: FontWeight.w500, color: color);

  static TextStyle userValue({Color color = Colors.black}) =>
      _style(fontSize: 22, fontWeight: FontWeight.w700, color: color);

  static TextStyle cardTitle({Color color = Colors.black}) =>
      _style(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, color: color);

  static TextStyle footer({Color color = Colors.black54}) =>
      _style(fontSize: 13, fontWeight: FontWeight.w500, color: color);

  static TextStyle footerBrand({Color color = Colors.black}) =>
      _style(fontSize: 14, fontWeight: FontWeight.w700, color: color);

  static TextStyle version({Color color = Colors.black, FontWeight weight = FontWeight.w600}) =>
      _style(fontSize: 16, fontWeight: weight, color: color);

  static TextStyle body({Color color = Colors.black87, FontWeight weight = FontWeight.w400}) =>
      _style(fontSize: 14, fontWeight: weight, color: color);

  static TextStyle button({Color color = Colors.white}) =>
      _style(fontSize: 16, fontWeight: FontWeight.w700, color: color);

  static TextTheme textTheme(TextTheme base) {
    return base.apply(fontFamily: fontFamily).copyWith(
      displayLarge: _style(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: _style(fontSize: 18, fontWeight: FontWeight.w700),
      titleLarge: _style(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: _style(fontSize: 15, fontWeight: FontWeight.w600),
      bodyLarge: _style(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium: _style(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: _style(fontSize: 13, fontWeight: FontWeight.w400),
      labelLarge: _style(fontSize: 16, fontWeight: FontWeight.w700),
      labelMedium: _style(fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: _style(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}
