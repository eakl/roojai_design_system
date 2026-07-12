// lib/src/tokens/semantic/semantic_typography.dart

import 'package:flutter/widgets.dart';

import '../primitives/app_typography.dart';

class SemanticTypography {
  const SemanticTypography({
    required this.displayMd,
    required this.displaySm,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodySm,
    required this.labelLg,
    required this.labelMd,
    required this.labelSm,
    required this.captionMd,
    required this.captionSm,
    required this.overline,
    required this.small,
    required this.footnote,
  });

  final TextStyle displayMd;
  final TextStyle displaySm;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodySm;
  final TextStyle labelLg;
  final TextStyle labelMd;
  final TextStyle labelSm;
  final TextStyle captionMd;
  final TextStyle captionSm;
  final TextStyle overline;
  final TextStyle small;
  final TextStyle footnote;

  static const SemanticTypography defaultScale = SemanticTypography(
    displayMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size48,
      fontWeight: AppTypeScale.bold,
      height: AppTypeScale.lineHeightTight,
    ),
    displaySm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size40,
      fontWeight: AppTypeScale.bold,
      height: AppTypeScale.lineHeightTight,
    ),
    h1: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size32,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightTight,
    ),
    h2: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size28,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightTight,
    ),
    h3: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size24,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
    ),
    h4: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size20,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodyLg: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size18,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodyMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size16,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodySm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size14,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelLg: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size16,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size14,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelSm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    captionMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    captionSm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    overline: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
      letterSpacing: 1.2,
    ),
    small: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    footnote: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightRelaxed,
    ),
  );
}
