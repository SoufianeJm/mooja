import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  static final _lightColorScheme = ColorScheme.light(
    primary: AppColors.gray800,
    secondary: AppColors.gray600,
    error: AppColors.red500,
    surface: LightThemeColors.backgroundPrimary,
    onPrimary: AppColors.gray50,
    onSecondary: AppColors.gray900,
    onSurface: LightThemeColors.textPrimary,
    onError: AppColors.gray900,
    outline: LightThemeColors.borderSecondary,
    outlineVariant: LightThemeColors.borderPrimary,
  );

  static final _darkColorScheme = ColorScheme.dark(
    primary: AppColors.gray50,
    secondary: AppColors.gray400,
    error: AppColors.red500,
    surface: DarkThemeColors.backgroundPrimary,
    onPrimary: AppColors.gray900,
    onSecondary: AppColors.gray900,
    onSurface: DarkThemeColors.textPrimary,
    onError: AppColors.gray50,
    outline: DarkThemeColors.borderSecondary,
    outlineVariant: DarkThemeColors.borderPrimary,
  );

  static ElevatedButtonThemeData _elevatedButtonTheme(bool isDark) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          padding: 20.ph + 15.pv,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg.radius),
          elevation: 0,
          backgroundColor: isDark
              ? LightThemeColors.backgroundPrimary
              : DarkThemeColors.backgroundPrimary,
          foregroundColor: isDark
              ? LightThemeColors.textPrimary
              : DarkThemeColors.textPrimary,
        ),
      );

  static TextButtonThemeData _textButtonTheme(bool isDark) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          padding: 20.ph + 15.pv,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg.radius),

          foregroundColor: isDark
              ? DarkThemeColors.textPrimary
              : LightThemeColors.textPrimary,
        ),
      );

  static final _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      fixedSize: const Size(52, 52),
      padding: 20.ph + 15.pv,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xxl.radius),
    ),
  );

  // Input Decoration Theme
  static InputDecorationTheme _inputDecorationTheme(bool isDark) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? DarkThemeColors.backgroundSecondary.withValues(alpha: 0.5)
            : LightThemeColors.backgroundSecondary.withValues(alpha: 0.5),
        contentPadding: 20.ph + 15.pv,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg.radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg.radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg.radius,
          borderSide: BorderSide(color: AppColors.lemon, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg.radius,
          borderSide: BorderSide(color: AppColors.red500, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg.radius,
          borderSide: BorderSide(color: AppColors.red500, width: 1),
        ),
        labelStyle: AppTypography.bodySubMedium,
        hintStyle: AppTypography.bodySubMedium.withAlpha(128),
        errorStyle: AppTypography.caption2Medium,
      );

  // Chip Theme
  static ChipThemeData _chipTheme(bool isDark) => ChipThemeData(
    backgroundColor: isDark
        ? DarkThemeColors.backgroundSecondary
        : LightThemeColors.backgroundSecondary,
    disabledColor: isDark
        ? DarkThemeColors.backgroundSecondary.withValues(alpha: 0.4)
        : LightThemeColors.backgroundSecondary.withValues(alpha: 0.4),
    padding: 8.pv + 10.ph,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.md.radius),
    labelStyle: AppTypography.bodySubSemiBold.copyWith(
      color: isDark
          ? DarkThemeColors.textPrimary
          : LightThemeColors.textPrimary,
    ),
  );

  //Todo: we should add others based on whether we need them or no

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    fontFamily: AppTypography.fontFamily,
    elevatedButtonTheme: _elevatedButtonTheme(false),
    textButtonTheme: _textButtonTheme(false),
    iconButtonTheme: _iconButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(false),
    chipTheme: _chipTheme(false),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    fontFamily: AppTypography.fontFamily,
    elevatedButtonTheme: _elevatedButtonTheme(true),
    textButtonTheme: _textButtonTheme(true),
    iconButtonTheme: _iconButtonTheme,
    inputDecorationTheme: _inputDecorationTheme(true),
    chipTheme: _chipTheme(true),
  );
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  bool get isDark => theme.brightness == Brightness.dark;
}
