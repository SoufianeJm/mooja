import 'package:flutter/material.dart';

/// =========================
/// App Typography System - General Sans - 8 styles - 2 weights
/// =========================
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'General Sans';

  // =========================
  // H1 - 26px
  // =========================
  static const TextStyle h1Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.52, // -2% of font size
    height: 1.2,
  );

  static const TextStyle h1SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.52,
    height: 1.2,
  );

  // =========================
  // H2 - 22px
  // =========================
  static const TextStyle h2Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.44,
    height: 1.25,
  );

  static const TextStyle h2SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.44,
    height: 1.25,
  );

  // =========================
  // H3 - 20px
  // =========================
  static const TextStyle h3Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static const TextStyle h3SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.3,
  );

  // =========================
  // Subheading - 18px
  // =========================
  static const TextStyle subheadingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.36,
    height: 1.35,
  );

  static const TextStyle subheadingSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.36,
    height: 1.35,
  );

  // =========================
  // Body - 16px
  // =========================
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.32,
    height: 1.4,
  );

  static const TextStyle bodySemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
    height: 1.4,
  );

  // =========================
  // Body Sub - 14px
  // =========================
  static const TextStyle bodySubMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.28,
    height: 1.45,
  );

  static const TextStyle bodySubSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.28,
    height: 1.45,
  );

  // =========================
  // Caption 1 - 12px
  // =========================
  static const TextStyle caption1Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.48, // -4% for captions
    height: 1.5,
  );

  static const TextStyle caption1SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.48,
    height: 1.5,
  );

  // =========================
  // Caption 2 - 11px
  // =========================
  static const TextStyle caption2Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.44, // -4% for captions
    height: 1.5,
  );

  static const TextStyle caption2SemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.44,
    height: 1.5,
  );
}

/// =========================
/// TextStyle Extensions
/// =========================
/// Common modifications you'll actually use
extension TextStyleX on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle withAlpha(double alpha) =>
      copyWith(color: color?.withValues(alpha: alpha));
}

/// =========================
/// Semantic Text Styles
/// =========================
class TextStyles {
  TextStyles._();

  // To be defined, here is an example of a semantic style
  static const TextStyle pageTitle = AppTypography.h1SemiBold;
}
