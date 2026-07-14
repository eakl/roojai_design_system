// lib/src/theme/light/light_typography.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/app_typography.dart';
import '../../tokens/semantic/typography.dart';

/// The package's built-in default light typography values, one entry per
/// [TextStyleToken] declared in `lib/src/tokens/semantic/typography.dart`.
final Map<TextStyleToken, TextStyle> lightTypography = <TextStyleToken, TextStyle>{
  $displayMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size48,
    fontWeight: AppTypeScale.bold,
    height: AppTypeScale.lineHeightTight,
  ),
  $displaySm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size40,
    fontWeight: AppTypeScale.bold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h1: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size32,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h2: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size28,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h3: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size24,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
  ),
  $h4: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size20,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodyLg: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size18,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodyMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size16,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodySm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size14,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelLg: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size16,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size14,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelSm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $captionMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $captionSm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $overline: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
    letterSpacing: 1.2,
  ),
  $small: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $footnote: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightRelaxed,
  ),
};
