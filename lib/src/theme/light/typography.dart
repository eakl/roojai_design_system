// lib/src/theme/light/light_typography.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/typography.dart';

// Display.
const $displayMd = TextStyleToken('typography.display.md');
const $displaySm = TextStyleToken('typography.display.sm');

// Heading.
const $headingH1 = TextStyleToken('typography.heading.h1');
const $headingH2 = TextStyleToken('typography.heading.h2');
const $headingH3 = TextStyleToken('typography.heading.h3');
const $headingH4 = TextStyleToken('typography.heading.h4');

// Body.
const $bodyLg = TextStyleToken('typography.body.lg');
const $bodyMd = TextStyleToken('typography.body.md');
const $bodySm = TextStyleToken('typography.body.sm');
const $bodyXs = TextStyleToken('typography.body.xs');

// Label.
const $labelLg = TextStyleToken('typography.label.lg');
const $labelMd = TextStyleToken('typography.label.md');
const $labelSm = TextStyleToken('typography.label.sm');
const $overline = TextStyleToken('typography.overline');

// Caption.
const $captionMd = TextStyleToken('typography.caption.md');
const $captionSm = TextStyleToken('typography.caption.sm');
const $footnote = TextStyleToken('typography.footnote');

/// The package's built-in default light typography values, one entry per
/// [TextStyleToken] declared in `lib/src/tokens/semantic/typography.dart`.
final Map<TextStyleToken, TextStyle> lightTypography =
    <TextStyleToken, TextStyle>{
  $displayMd: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.displayMDFontSize,
    height: SemTypography.displayMDLineHeight,
    fontWeight: SemTypography.displayMDFontWeight,
  ),
  $displaySm: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.displaySMFontSize,
    height: SemTypography.displaySMLineHeight,
    fontWeight: SemTypography.displaySMFontWeight,
  ),
  $headingH1: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.headingH1FontSize,
    height: SemTypography.headingH1LineHeight,
    fontWeight: SemTypography.headingH1FontWeight,
  ),
  $headingH2: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.headingH2FontSize,
    height: SemTypography.headingH2LineHeight,
    fontWeight: SemTypography.headingH2FontWeight,
  ),
  $headingH3: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.headingH3FontSize,
    height: SemTypography.headingH3LineHeight,
    fontWeight: SemTypography.headingH3FontWeight,
  ),
  $headingH4: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.headingH4FontSize,
    height: SemTypography.headingH4LineHeight,
    fontWeight: SemTypography.headingH4FontWeight,
  ),
  $bodyLg: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.bodyLGFontSize,
    height: SemTypography.bodyLGLineHeight,
    fontWeight: SemTypography.bodyLGFontWeight,
  ),
  $bodyMd: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.bodyMDFontSize,
    height: SemTypography.bodyMDLineHeight,
    fontWeight: SemTypography.bodyMDFontWeight,
  ),
  $bodySm: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.bodySMFontSize,
    height: SemTypography.bodySMLineHeight,
    fontWeight: SemTypography.bodySMFontWeight,
  ),
  $labelLg: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.labelLGFontSize,
    height: SemTypography.labelLGLineHeight,
    fontWeight: SemTypography.labelLGFontWeight,
  ),
  $labelMd: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.labelMDFontSize,
    height: SemTypography.labelMDLineHeight,
    fontWeight: SemTypography.labelMDFontWeight,
  ),
  $labelSm: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.labelSMFontSize,
    height: SemTypography.labelSMLineHeight,
    fontWeight: SemTypography.labelSMFontWeight,
  ),
  $captionMd: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.captionMDFontSize,
    height: SemTypography.captionMDLineHeight,
    fontWeight: SemTypography.captionMDFontWeight,
  ),
  $captionSm: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.captionSMFontSize,
    height: SemTypography.captionSMLineHeight,
    fontWeight: SemTypography.captionSMFontWeight,
  ),
  $overline: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.overlineFontSize,
    height: SemTypography.overlineLineHeight,
    fontWeight: SemTypography.overlineFontWeight,
    letterSpacing: SemTypography.overlineLetterSpacing,
  ),
  $bodyXs: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.bodyXSFontSize,
    height: SemTypography.bodyXSLineHeight,
    fontWeight: SemTypography.bodyXSFontWeight,
  ),
  $footnote: const TextStyle(
    fontFamily: SemTypography.fontFamilyWeb,
    fontSize: SemTypography.footnoteFontSize,
    height: SemTypography.footnoteLineHeight,
    fontWeight: SemTypography.footnoteFontWeight,
  ),
};
