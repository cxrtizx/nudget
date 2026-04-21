import 'package:flutter/material.dart';

/// Application theme configuration supporting light and dark modes.
///
/// Both themes derive their color system from [_seedColor] via Material 3
/// [ColorScheme.fromSeed], ensuring consistent tonal palettes in both modes.
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF2196F3);

  static CardThemeData get _cardTheme => CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      );

  /// Light theme.
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: _cardTheme,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        chipTheme: const ChipThemeData(
          showCheckmark: false,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );

  /// Dark theme.
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: _cardTheme,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
        chipTheme: const ChipThemeData(
          showCheckmark: false,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );
}
