// lib/src/theme/light/light_typography.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/typography.dart';
import '../../tokens/semantic/typography.dart';

/// The package's built-in default light typography values, one entry per
/// [TextStyleToken] declared in `lib/src/tokens/semantic/typography.dart`.
final Map<TextStyleToken, TextStyle> lightTypography =
    <TextStyleToken, TextStyle>{
  $displayMd: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs48,
    fontWeight: AppTypeScale.fwBold,
    height: AppTypeScale.lhTight,
  ),
  $displaySm: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs40,
    fontWeight: AppTypeScale.fwBold,
    height: AppTypeScale.lhTight,
  ),
  $headingH1: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs32,
    fontWeight: AppTypeScale.fwSemibold,
    height: AppTypeScale.lhTight,
  ),
  $headingH2: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs24,
    fontWeight: AppTypeScale.fwSemibold,
    height: AppTypeScale.lhTight,
  ),
  $headingH3: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs20,
    fontWeight: AppTypeScale.fwSemibold,
    height: AppTypeScale.lhNormal,
  ),
  $headingH4: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs16,
    fontWeight: AppTypeScale.fwSemibold,
    height: AppTypeScale.lhNormal,
  ),
  $bodyLg: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs18,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $bodyMd: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs16,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $bodySm: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs14,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $labelLg: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs16,
    fontWeight: AppTypeScale.fwMedium,
    height: AppTypeScale.lhNormal,
  ),
  $labelMd: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs14,
    fontWeight: AppTypeScale.fwMedium,
    height: AppTypeScale.lhNormal,
  ),
  $labelSm: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs12,
    fontWeight: AppTypeScale.fwMedium,
    height: AppTypeScale.lhNormal,
  ),
  $captionMd: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs12,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $captionSm: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs12,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $overline: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs12,
    fontWeight: AppTypeScale.fwSemibold,
    height: AppTypeScale.lhNormal,
    letterSpacing: 1.2,
  ),
  $bodyXs: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs12,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhNormal,
  ),
  $footnote: const TextStyle(
    fontFamily: AppTypeScale.ffWeb,
    fontSize: AppTypeScale.fs11,
    fontWeight: AppTypeScale.fwRegular,
    height: AppTypeScale.lhRelaxed,
  ),
};
