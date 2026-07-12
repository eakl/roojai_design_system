// lib/src/tokens/primitives/app_typography.dart

import 'package:flutter/widgets.dart';

/// Raw font-size/weight/line-height/letter-spacing values. Semantic
/// typography (`SemanticTypography`) composes these into named `TextStyle`s.
class AppTypeScale {
  AppTypeScale._();

  static const String fontFamily = 'Roboto';

  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size16 = 16;
  static const double size18 = 18;
  static const double size20 = 20;
  static const double size24 = 24;
  static const double size28 = 28;
  static const double size32 = 32;
  static const double size40 = 40;
  static const double size48 = 48;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
}
