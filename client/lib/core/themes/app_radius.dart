import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // Primitive radius values
  static const double none = 0;
  static const double sm = 5;
  static const double md = 10;
  static const double lg = 15;
  static const double xl = 20;
  static const double xxl = 120;
  static const double xxxl = 300;

  /// Helper to create BorderRadius with all corners, eg. borderRadius: AppRadius.md.radius or 12.radius
  static BorderRadius all(double radius) =>
      BorderRadius.all(Radius.circular(radius));
}

// Extension for convenient usage
extension RadiusExtension on num {
  BorderRadius get radius => BorderRadius.circular(toDouble());
}
