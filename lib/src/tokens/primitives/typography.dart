// lib/src/tokens/primitives/app_typography.dart

import 'package:flutter/widgets.dart';

/// Raw font-size/weight/line-height/letter-spacing values. Semantic
/// typography tokens (`lib/src/tokens/semantic/typography.dart`) compose
/// these into named `TextStyle`s.
class PrimTypeScale {
  AppTypeScale._();

  static const String ffIos = 'SF Pro';
  static const String ffAndroid = 'Roboto';
  static const String ffWeb = 'Inter';

  static const double fs48 = 48;
  static const double fs40 = 40;
  static const double fs32 = 32;
  static const double fs24 = 24;
  static const double fs20 = 20;
  static const double fs18 = 18;
  static const double fs16 = 16;
  static const double fs14 = 14;
  static const double fs12 = 12;
  static const double fs11 = 11;

  static const FontWeight fwRegular = FontWeight.w400;
  static const FontWeight fwMedium = FontWeight.w500;
  static const FontWeight fwSemibold = FontWeight.w600;
  static const FontWeight fwBold = FontWeight.w700;

  static const double lhTight = 1.2;
  static const double lhNormal = 1.4;
  static const double lhRelaxed = 1.6;
}
