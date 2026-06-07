import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _lightPrimary = Color(0xFF6750A4);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFEADDFF);
  static const Color _lightOnPrimaryContainer = Color(0xFF21005D);
  static const Color _lightSecondary = Color(0xFF625B71);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer = Color(0xFFE8DEF8);
  static const Color _lightOnSecondaryContainer = Color(0xFF1D192B);
  static const Color _lightTertiary = Color(0xFF7D5260);
  static const Color _lightOnTertiary = Color(0xFFFFFFFF);
  static const Color _lightTertiaryContainer = Color(0xFFFFD8E4);
  static const Color _lightOnTertiaryContainer = Color(0xFF31111D);
  static const Color _lightError = Color(0xFFB3261E);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFF9DEDC);
  static const Color _lightOnErrorContainer = Color(0xFF410E0B);
  static const Color _lightBackground = Color(0xFFFFFBFE);
  static const Color _lightOnBackground = Color(0xFF1C1B1F);
  static const Color _lightSurface = Color(0xFFFFFBFE);
  static const Color _lightOnSurface = Color(0xFF1C1B1F);
  static const Color _lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color _lightOnSurfaceVariant = Color(0xFF49454F);
  static const Color _lightOutline = Color(0xFF79747E);
  static const Color _lightOutlineVariant = Color(0xFFCAC4D0);
  static const Color _lightShadow = Color(0xFF000000);
  static const Color _lightScrim = Color(0xFF000000);
  static const Color _lightInverseSurface = Color(0xFF313033);
  static const Color _lightInversePrimary = Color(0xFFD0BCFF);
  static const Color _lightSurfaceTint = Color(0xFF6750A4);

  static const Color _darkPrimary = Color(0xFFD0BCFF);
  static const Color _darkOnPrimary = Color(0xFF381E72);
  static const Color _darkPrimaryContainer = Color(0xFF4F378B);
  static const Color _darkOnPrimaryContainer = Color(0xFFEADDFF);
  static const Color _darkSecondary = Color(0xFFCCC2DC);
  static const Color _darkOnSecondary = Color(0xFF332D41);
  static const Color _darkSecondaryContainer = Color(0xFF4A4458);
  static const Color _darkOnSecondaryContainer = Color(0xFFE8DEF8);
  static const Color _darkTertiary = Color(0xFFEFB8C8);
  static const Color _darkOnTertiary = Color(0xFF492532);
  static const Color _darkTertiaryContainer = Color(0xFF633B48);
  static const Color _darkOnTertiaryContainer = Color(0xFFFFD8E4);
  static const Color _darkError = Color(0xFFF2B8B5);
  static const Color _darkOnError = Color(0xFF601410);
  static const Color _darkErrorContainer = Color(0xFF8C1D18);
  static const Color _darkOnErrorContainer = Color(0xFFF9DEDC);
  static const Color _darkBackground = Color(0xFF1C1B1F);
  static const Color _darkOnBackground = Color(0xFFE6E1E5);
  static const Color _darkSurface = Color(0xFF1C1B1F);
  static const Color _darkOnSurface = Color(0xFFE6E1E5);
  static const Color _darkSurfaceVariant = Color(0xFF49454F);
  static const Color _darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color _darkOutline = Color(0xFF938F99);
  static const Color _darkOutlineVariant = Color(0xFF49454F);
  static const Color _darkShadow = Color(0xFF000000);
  static const Color _darkScrim = Color(0xFF000000);
  static const Color _darkInverseSurface = Color(0xFFE6E1E5);
  static const Color _darkInversePrimary = Color(0xFF6750A4);
  static const Color _darkSurfaceTint = Color(0xFFD0BCFF);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        primaryContainer: _lightPrimaryContainer,
        onPrimaryContainer: _lightOnPrimaryContainer,
        secondary: _lightSecondary,
        onSecondary: _lightOnSecondary,
        secondaryContainer: _lightSecondaryContainer,
        onSecondaryContainer: _lightOnSecondaryContainer,
        tertiary: _lightTertiary,
        onTertiary: _lightOnTertiary,
        tertiaryContainer: _lightTertiaryContainer,
        onTertiaryContainer: _lightOnTertiaryContainer,
        error: _lightError,
        onError: _lightOnError,
        errorContainer: _lightErrorContainer,
        onErrorContainer: _lightOnErrorContainer,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        surfaceContainerHighest: _lightSurfaceVariant,
        onSurfaceVariant: _lightOnSurfaceVariant,
        outline: _lightOutline,
        outlineVariant: _lightOutlineVariant,
        shadow: _lightShadow,
        scrim: _lightScrim,
        inverseSurface: _lightInverseSurface,
        onInverseSurface: _lightOnBackground,
        inversePrimary: _lightInversePrimary,
        surfaceTint: _lightSurfaceTint,
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        primaryContainer: _darkPrimaryContainer,
        onPrimaryContainer: _darkOnPrimaryContainer,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        secondaryContainer: _darkSecondaryContainer,
        onSecondaryContainer: _darkOnSecondaryContainer,
        tertiary: _darkTertiary,
        onTertiary: _darkOnTertiary,
        tertiaryContainer: _darkTertiaryContainer,
        onTertiaryContainer: _darkOnTertiaryContainer,
        error: _darkError,
        onError: _darkOnError,
        errorContainer: _darkErrorContainer,
        onErrorContainer: _darkOnErrorContainer,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        surfaceContainerHighest: _darkSurfaceVariant,
        onSurfaceVariant: _darkOnSurfaceVariant,
        outline: _darkOutline,
        outlineVariant: _darkOutlineVariant,
        shadow: _darkShadow,
        scrim: _darkScrim,
        inverseSurface: _darkInverseSurface,
        onInverseSurface: _darkOnBackground,
        inversePrimary: _darkInversePrimary,
        surfaceTint: _darkSurfaceTint,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
