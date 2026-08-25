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

/// Echelle typographique unique de l'application, en pixels logiques Flutter.
///
/// Le facteur d'accessibilite Android reste applique par Flutter. Aucun style
/// applicatif ne doit depasser [pageTitle].
@immutable
class AppTextScale extends ThemeExtension<AppTextScale> {
  const AppTextScale({
    this.pageTitle = const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    this.sectionTitle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    this.hierarchyTitle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    this.body = const TextStyle(fontSize: 14),
    this.filter = const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    this.metadata = const TextStyle(fontSize: 12),
  });

  final TextStyle pageTitle;
  final TextStyle sectionTitle;
  final TextStyle hierarchyTitle;
  final TextStyle body;
  final TextStyle filter;
  final TextStyle metadata;

  static AppTextScale of(BuildContext context) =>
      Theme.of(context).extension<AppTextScale>()!;

  @override
  AppTextScale copyWith({
    TextStyle? pageTitle,
    TextStyle? sectionTitle,
    TextStyle? hierarchyTitle,
    TextStyle? body,
    TextStyle? filter,
    TextStyle? metadata,
  }) => AppTextScale(
    pageTitle: pageTitle ?? this.pageTitle,
    sectionTitle: sectionTitle ?? this.sectionTitle,
    hierarchyTitle: hierarchyTitle ?? this.hierarchyTitle,
    body: body ?? this.body,
    filter: filter ?? this.filter,
    metadata: metadata ?? this.metadata,
  );

  @override
  AppTextScale lerp(covariant AppTextScale? other, double t) {
    if (other == null) return this;
    return AppTextScale(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      sectionTitle: TextStyle.lerp(sectionTitle, other.sectionTitle, t)!,
      hierarchyTitle: TextStyle.lerp(hierarchyTitle, other.hierarchyTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      filter: TextStyle.lerp(filter, other.filter, t)!,
      metadata: TextStyle.lerp(metadata, other.metadata, t)!,
    );
  }
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
    final contentText = _appTextTheme(baseText);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: colors.surface,
      textTheme: contentText,
      extensions: const [AppTextScale()],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const AppTextScale().pageTitle.copyWith(
          color: colors.onSurface,
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
          const AppTextScale().metadata.copyWith(
            color: colors.onSurface,
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

  static TextTheme _appTextTheme(TextTheme source) {
    TextStyle resolve(TextStyle? style, double size, FontWeight weight) =>
        (style ?? const TextStyle()).copyWith(
          fontSize: size,
          fontWeight: weight,
        );
    return source.copyWith(
      displayLarge: resolve(source.displayLarge, 22, FontWeight.w700),
      displayMedium: resolve(source.displayMedium, 22, FontWeight.w700),
      displaySmall: resolve(source.displaySmall, 22, FontWeight.w700),
      headlineLarge: resolve(source.headlineLarge, 22, FontWeight.w700),
      headlineMedium: resolve(source.headlineMedium, 22, FontWeight.w700),
      headlineSmall: resolve(source.headlineSmall, 22, FontWeight.w700),
      titleLarge: resolve(source.titleLarge, 22, FontWeight.w700),
      titleMedium: resolve(source.titleMedium, 18, FontWeight.w700),
      titleSmall: resolve(source.titleSmall, 16, FontWeight.w700),
      bodyLarge: resolve(source.bodyLarge, 14, FontWeight.w400),
      bodyMedium: resolve(source.bodyMedium, 14, FontWeight.w400),
      bodySmall: resolve(source.bodySmall, 12, FontWeight.w400),
      labelLarge: resolve(source.labelLarge, 14, FontWeight.w400),
      labelMedium: resolve(source.labelMedium, 12, FontWeight.w400),
      labelSmall: resolve(source.labelSmall, 12, FontWeight.w400),
    );
  }
}
