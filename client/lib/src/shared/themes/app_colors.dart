import 'package:flutter/material.dart';

/// =========================
/// Core App Colors
/// =========================
class AppColors {
  AppColors._();

  // BRAND COLORS
  static const Color lemon = Color(0xFFE2FE52);
  static const Color lemon900 = Color(0xFF4D5745);
  static const Color lavender = Color(0xFFDFD3F4);
  static const Color lavender900 = Color(0xFF8D61D7);
  static const Color mustard = Color(0xFFF8D3B1);
  static const Color mustard900 = Color(0xFF4A403A);
  static const Color aqua = Color(0xFFD1F2EB);
  static const Color aqua900 = Color(0xFF3D4852);
  static const Color foggy = Color(0xFFF0F4EF);
  static const Color foggy900 = Color(0xFF3E4E50);
  static const Color cyan = Color(0xFFE0FBFC);
  static const Color cyan900 = Color(0xFF35524A);
  static const Color lightGreen = Color(0xFFE5F6DF);
  static const Color lightGreen900 = Color(0xFF4A4E4D);
  static const Color olive = Color(0xFFFDFCDC);
  static const Color olive900 = Color(0xFF595D47);
  static const Color mint = Color(0xFFCAF7E3);
  static const Color mint900 = Color(0xFF2B2D42);
  static const Color skies = Color(0xFFBDE0FE);
  static const Color skies900 = Color(0xFF2B303A);
  static const Color frost = Color(0xFFD3F8E2);
  static const Color frost900 = Color(0xFF36413E);
  static const Color breeze = Color(0xFFA0E7E5);
  static const Color breeze900 = Color(0xFF2F3E46);
  static const Color rose = Color(0xFFFFC8DD);
  static const Color rose900 = Color(0xFF3D3A4B);
  static const Color purple = Color(0xFFC8B6FF);
  static const Color purple900 = Color(0xFF2B2D42);
  static const Color cream = Color(0xFFFBE7C6);
  static const Color cream900 = Color(0xFF3B302A);
  static const Color cottonCandy = Color(0xFFFDE2E4);
  static const Color cottonCandy900 = Color(0xFF3A3335);
  static const Color red500 = Color(0xFFFF0000);

  // GRAYSCALE
  static const Color gray50 = Color(0xFFFFFFFF);
  static const Color gray100 = Color(0xFFF4F4F4);
  static const Color gray200 = Color(0xFFF0F0F0);
  static const Color gray300 = Color(0xFFEDEBEE);
  static const Color gray400 = Color(0xFF9D9B9E);
  static const Color gray600 = Color(0xFF8C919E);
  static const Color gray700 = Color(0xFF343434);
  static const Color gray800 = Color(0xFF242424);
  static const Color gray900 = Color(0xFF000000);

  // HELPER METHODS
  static bool isLight(Color color) => color.computeLuminance() > 0.5;
  static bool isDark(Color color) => !isLight(color);
  static Color getTextColorFor(Color background) =>
      isLight(background) ? gray900 : gray50;
}

/// =========================
/// Color Utility Extensions
/// =========================
extension ColorExtensions on Color {
  bool get isLight => AppColors.isLight(this);
  bool get isDark => AppColors.isDark(this);
  Color get foregroundColor => AppColors.getTextColorFor(this);

  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(a * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).round().toRadixString(16).padLeft(2, '0')}';
}

/// =========================
/// Light / Dark Theme Colors
/// =========================
class LightThemeColors {
  static const Color textPrimary = AppColors.gray800;
  static const Color textSecondary = AppColors.gray600;
  static const Color textInvert = AppColors.gray50;
  static const Color backgroundPrimary = AppColors.gray50;
  static const Color backgroundSecondary = AppColors.gray300;
  static const Color backgroundInvert = AppColors.gray900;
  static const Color borderPrimary = AppColors.gray700;
  static const Color borderSecondary = AppColors.gray600;
}

class DarkThemeColors {
  static const Color textPrimary = AppColors.gray50;
  static const Color textSecondary = AppColors.gray400;
  static const Color textInvert = AppColors.gray800;
  static const Color backgroundPrimary = AppColors.gray900;
  static const Color backgroundSecondary = AppColors.gray800;
  static const Color backgroundInvert = AppColors.gray50;
  static const Color borderPrimary = AppColors.gray700;
  static const Color borderSecondary = AppColors.gray600;
}

/// =========================
/// Theme Adaptive Helper
/// =========================
class ThemeColors {
  static Color textPrimary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.textPrimary,
    DarkThemeColors.textPrimary,
  );
  static Color textSecondary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.textSecondary,
    DarkThemeColors.textSecondary,
  );
  static Color textInvert(BuildContext context) => _adaptive(
    context,
    LightThemeColors.textInvert,
    DarkThemeColors.textInvert,
  );
  static Color backgroundPrimary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.backgroundPrimary,
    DarkThemeColors.backgroundPrimary,
  );
  static Color backgroundSecondary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.backgroundSecondary,
    DarkThemeColors.backgroundSecondary,
  );
  static Color backgroundInvert(BuildContext context) => _adaptive(
    context,
    LightThemeColors.backgroundInvert,
    DarkThemeColors.backgroundInvert,
  );
  static Color borderPrimary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.borderPrimary,
    DarkThemeColors.borderPrimary,
  );
  static Color borderSecondary(BuildContext context) => _adaptive(
    context,
    LightThemeColors.borderSecondary,
    DarkThemeColors.borderSecondary,
  );

  static Color _adaptive(BuildContext context, Color light, Color dark) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
