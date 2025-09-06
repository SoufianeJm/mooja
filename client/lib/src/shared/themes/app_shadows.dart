import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> shadow1 = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 10, color: Color(0x0F000000)),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(offset: Offset(0, 16), blurRadius: 20, color: Color(0x2604CFD9)),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(offset: Offset(0, -4), blurRadius: 20, color: Color(0x0A101010)),
  ];

  static const List<BoxShadow> shadow4 = [
    BoxShadow(blurRadius: 20, color: Color(0x40E2FE52)),
  ];

  // ============= SEMANTIC SHADOW ALIASES =============
  static const List<BoxShadow> none = [];
  static const List<BoxShadow> sm = shadow1;
  static const List<BoxShadow> md = shadow2;
  static const List<BoxShadow> up = shadow3;
  static const List<BoxShadow> glow = shadow4;
}
