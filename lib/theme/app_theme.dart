import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Color(0xFF5B6CF0);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    return _buildTheme(scheme, Brightness.light);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    return _buildTheme(scheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: scheme.onSurface,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        height: 1.5,
        color: scheme.onSurface,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      labelMedium: base.textTheme.labelMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLow,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(isDark ? 0.30 : 0.45),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? scheme.surfaceContainer : scheme.surface,
        surfaceTintColor: Colors.transparent,
        height: 72,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        textColor: scheme.onSurface,
        subtitleTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.6),
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
