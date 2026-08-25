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

abstract final class AppColors {
  static const primary = Color(0xFF44C3F8);
  static const pink = Color(0xFFE71345);
  static const yellow = Color(0xFFF8AC34);
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final generated = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    );
    final colors = generated.copyWith(
      primary: AppColors.primary,
      onPrimary: const Color(0xFF003545),
      primaryContainer: dark
          ? const Color(0xFF174D61)
          : const Color(0xFFC9F0FF),
      onPrimaryContainer: dark
          ? const Color(0xFFD5F3FF)
          : const Color(0xFF003545),
      secondary: AppColors.pink,
      onSecondary: Colors.white,
      tertiary: AppColors.yellow,
      onTertiary: const Color(0xFF3D2800),
      surface: dark ? const Color(0xFF0B0F11) : const Color(0xFFF0F2F4),
      surfaceContainerLowest: dark ? const Color(0xFF171C1F) : Colors.white,
      surfaceContainerLow: dark ? const Color(0xFF1C2327) : Colors.white,
      surfaceContainer: dark
          ? const Color(0xFF222A2F)
          : const Color(0xFFF7F9FA),
    );
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.field),
      borderSide: BorderSide(color: colors.outlineVariant),
    );
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      brightness: brightness,
    );
    final typography = Typography.material2021(
      platform: TargetPlatform.android,
    );
    final baseText = dark ? typography.white : typography.black;
    final contentText = _scaleContentText(baseText).copyWith(
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontSize: (baseText.headlineSmall?.fontSize ?? 24) * 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: baseText.titleLarge?.copyWith(
        fontSize: (baseText.titleLarge?.fontSize ?? 22) * 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        fontSize: (baseText.titleMedium?.fontSize ?? 16) * 1.2,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: baseText.titleSmall?.copyWith(
        fontSize: (baseText.titleSmall?.fontSize ?? 14) * 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
    return baseTheme.copyWith(
      scaffoldBackgroundColor: colors.surface,
      textTheme: contentText,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: baseText.titleLarge?.copyWith(
          color: colors.onSurface,
          fontSize: baseText.titleLarge?.fontSize ?? 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colors.surfaceContainerLowest,
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
          baseText.labelMedium?.copyWith(
            color: colors.onSurface,
            fontSize: baseText.labelMedium?.fontSize ?? 12,
            fontWeight: FontWeight.w600,
          ),
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

  static TextTheme _scaleContentText(TextTheme source) {
    TextStyle scale(TextStyle? style, double defaultSize) =>
        (style ?? const TextStyle()).copyWith(
          fontSize: (style?.fontSize ?? defaultSize) * 1.2,
        );
    return source.copyWith(
      displayLarge: scale(source.displayLarge, 57),
      displayMedium: scale(source.displayMedium, 45),
      displaySmall: scale(source.displaySmall, 36),
      headlineLarge: scale(source.headlineLarge, 32),
      headlineMedium: scale(source.headlineMedium, 28),
      headlineSmall: scale(source.headlineSmall, 24),
      titleLarge: scale(source.titleLarge, 22),
      titleMedium: scale(source.titleMedium, 16),
      titleSmall: scale(source.titleSmall, 14),
      bodyLarge: scale(source.bodyLarge, 16),
      bodyMedium: scale(source.bodyMedium, 14),
      bodySmall: scale(source.bodySmall, 12),
      labelLarge: scale(source.labelLarge, 14),
      labelMedium: scale(source.labelMedium, 12),
      labelSmall: scale(source.labelSmall, 11),
    );
  }
}
