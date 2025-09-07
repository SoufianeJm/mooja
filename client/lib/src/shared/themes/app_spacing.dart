import 'package:flutter/material.dart';

/// =========================
/// App Spacing System - 4px Grid
/// =========================
class AppSpacing {
  AppSpacing._();

  // Core spacing values (4px grid)
  static const double s0 = 0; // None
  static const double s1 = 4; // Micro
  static const double s2 = 8; // Tight
  static const double s3 = 12; // Small
  static const double s4 = 16; // Default
  static const double s5 = 20; // Medium
  static const double s6 = 24; // Large
  static const double s8 = 32; // XL
  static const double s10 = 40; // 2XL
  static const double s12 = 48; // 3XL
  static const double s16 = 64; // 4XL
  static const double s20 = 80; // 5XL
  static const double s24 = 96; // 6XL

  // Horizontal spacing widget
  static const Widget h1 = SizedBox(width: s1);
  static const Widget h2 = SizedBox(width: s2);
  static const Widget h3 = SizedBox(width: s3);
  static const Widget h4 = SizedBox(width: s4);
  static const Widget h5 = SizedBox(width: s5);
  static const Widget h6 = SizedBox(width: s6);
  static const Widget h8 = SizedBox(width: s8);

  // Vertical spacing widget
  static const Widget v1 = SizedBox(height: s1);
  static const Widget v2 = SizedBox(height: s2);
  static const Widget v3 = SizedBox(height: s3);
  static const Widget v4 = SizedBox(height: s4);
  static const Widget v5 = SizedBox(height: s5);
  static const Widget v6 = SizedBox(height: s6);
  static const Widget v8 = SizedBox(height: s8);
}

/// =========================
/// Spacing Extensions
/// =========================
extension SpacingX on num {
  // SizedBox shortcuts
  Widget get h => SizedBox(width: toDouble());
  Widget get v => SizedBox(height: toDouble());
  Widget get s => SizedBox(width: toDouble(), height: toDouble());

  // Padding shortcuts
  EdgeInsets get p => EdgeInsets.all(toDouble());
  EdgeInsets get ph => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get pv => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get pt => EdgeInsets.only(top: toDouble());
  EdgeInsets get pb => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get pl => EdgeInsets.only(left: toDouble());
  EdgeInsets get pr => EdgeInsets.only(right: toDouble());

  // Margin shortcuts
  EdgeInsets get m => EdgeInsets.all(toDouble());
  EdgeInsets get mh => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get mv => EdgeInsets.symmetric(vertical: toDouble());
  EdgeInsets get mt => EdgeInsets.only(top: toDouble());
  EdgeInsets get mb => EdgeInsets.only(bottom: toDouble());
  EdgeInsets get ml => EdgeInsets.only(left: toDouble());
  EdgeInsets get mr => EdgeInsets.only(right: toDouble());
}

/// =========================
/// Semantic Spacing
/// =========================
class Spacing {
  Spacing._();

  // To be determined, this is an example
  static const double pageMargin = AppSpacing.s4; // 16px
}
