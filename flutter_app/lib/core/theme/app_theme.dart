import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 18;
  static const double xl = 24;
}

abstract final class AppRadius {
  static const double field = 12;
  static const double card = 14;
  static const double pill = 999;
}

abstract final class AppTheme {
  static const _primary = Color(0xFF245C4F);
  static const _secondary = Color(0xFFE29B52);

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final generated = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
    );
    final colors = generated.copyWith(
      primary: dark ? generated.primary : _primary,
      secondary: _secondary,
      surface: dark ? const Color(0xFF101613) : const Color(0xFFF8F9F7),
      surfaceContainerLowest: dark ? const Color(0xFF0C110F) : Colors.white,
      surfaceContainerLow: dark
          ? const Color(0xFF18211D)
          : const Color(0xFFF0F2EF),
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: brightness,
      scaffoldBackgroundColor: colors.surface,
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 11,
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearMinHeight: 6,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: colors.primary,
        linearTrackColor: colors.surfaceContainerHighest,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        menuPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        color: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
