import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const primary = Color(0xFF245C4F);
    const secondary = Color(0xFFE29B52);
    final colors = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(secondary: secondary);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: const Color(0xFFF8F9F7),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
