// lib/src/theme/light/light_colors.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';

// Base.
const $transparent = ColorToken('color.base.transparent');
const $white = ColorToken('color.base.white');
const $black = ColorToken('color.base.black');

// Canvas.
const $canvasDefault = ColorToken('color.canvas.default');
const $canvasAlternative = ColorToken('color.canvas.alternative');

// Surface.
const $surfaceDefault = ColorToken('color.surface.default');
const $surfaceAlternative = ColorToken('color.surface.alternative');
const $surfaceSunken = ColorToken('color.surface.sunken');
const $surfaceInverted = ColorToken('color.surface.inverted');

// Content.
const $contentPrimary = ColorToken('color.content.primary');
const $contentSecondary = ColorToken('color.content.secondary');
const $contentMuted = ColorToken('color.content.muted');
const $contentPlaceholder = ColorToken('color.content.placeholder');
const $contentOnBrand = ColorToken('color.content.onBrand');
const $contentOnBrandMuted = ColorToken('color.content.onBrandMuted');

// Border.
const $borderDefault = ColorToken('color.border.default');
const $borderStrong = ColorToken('color.border.strong');

// Brand.
const $brandSurface = ColorToken('color.brand.surface');
const $brandSurfaceStrong = ColorToken('color.brand.surfaceStrong');
const $brandUi = ColorToken('color.brand.ui');
const $brandUiHover = ColorToken('color.brand.uiHover');
const $brandText = ColorToken('color.brand.text');
const $brandTextStrong = ColorToken('color.brand.textStrong');

// Accent.
const $accentSurface = ColorToken('color.accent.surface');
const $accentSurfaceStrong = ColorToken('color.accent.surfaceStrong');
const $accentUi = ColorToken('color.accent.ui');
const $accentUiHover = ColorToken('color.accent.uiHover');
const $accentText = ColorToken('color.accent.text');
const $accentTextStrong = ColorToken('color.accent.textStrong');

// Positive.
const $positiveSurface = ColorToken('color.positive.surface');
const $positiveSurfaceStrong = ColorToken('color.positive.surfaceStrong');
const $positiveUi = ColorToken('color.positive.ui');
const $positiveUiHover = ColorToken('color.positive.uiHover');
const $positiveText = ColorToken('color.positive.text');
const $positiveTextStrong = ColorToken('color.positive.textStrong');

// Negative.
const $negativeSurface = ColorToken('color.negative.surface');
const $negativeSurfaceStrong = ColorToken('color.negative.surfaceStrong');
const $negativeUi = ColorToken('color.negative.ui');
const $negativeUiHover = ColorToken('color.negative.uiHover');
const $negativeText = ColorToken('color.negative.text');
const $negativeTextStrong = ColorToken('color.negative.textStrong');

// Warning.
const $warningSurface = ColorToken('color.warning.surface');
const $warningSurfaceStrong = ColorToken('color.warning.surfaceStrong');
const $warningUi = ColorToken('color.warning.ui');
const $warningUiHover = ColorToken('color.warning.uiHover');
const $warningText = ColorToken('color.warning.text');
const $warningTextStrong = ColorToken('color.warning.textStrong');

// Alert.
const $alertSurface = ColorToken('color.alert.surface');
const $alertSurfaceStrong = ColorToken('color.alert.surfaceStrong');
const $alertUi = ColorToken('color.alert.ui');
const $alertUiHover = ColorToken('color.alert.uiHover');
const $alertText = ColorToken('color.alert.text');
const $alertTextStrong = ColorToken('color.alert.textStrong');

// Info.
const $infoSurface = ColorToken('color.info.surface');
const $infoSurfaceStrong = ColorToken('color.info.surfaceStrong');
const $infoUi = ColorToken('color.info.ui');
const $infoUiHover = ColorToken('color.info.uiHover');
const $infoText = ColorToken('color.info.text');
const $infoTextStrong = ColorToken('color.info.textStrong');

// Neutral.
const $neutralSurface = ColorToken('color.neutral.surface');
const $neutralSurfaceStrong = ColorToken('color.neutral.surfaceStrong');
const $neutralUi = ColorToken('color.neutral.ui');
const $neutralUiHover = ColorToken('color.neutral.uiHover');
const $neutralText = ColorToken('color.neutral.text');
const $neutralTextStrong = ColorToken('color.neutral.textStrong');




/// The package's built-in default light color values, one entry per
/// [ColorToken] declared in `lib/src/tokens/semantic/colors.dart`.
final Map<ColorToken, Color> lightColors = <ColorToken, Color>{
  // Base.
  $transparent: SemColors.baseTransparent,
  $white: SemColors.baseWhite,
  $black: SemColors.baseBlack,

  // Canvas.
  $canvasDefault: SemColors.canvasDefault,
  $canvasAlternative: SemColors.canvasAlternative,

  // Surface.
  $surfaceDefault: SemColors.surfaceDefault,
  $surfaceAlternative: SemColors.surfaceAlternative,
  $surfaceSunken: SemColors.surfaceSunken,
  $surfaceInverted: SemColors.surfaceInverted,

  // Content.
  $contentPrimary: SemColors.contentPrimary,
  $contentSecondary: SemColors.contentSecondary,
  $contentMuted: SemColors.contentMuted,
  $contentPlaceholder: SemColors.contentPlaceholder,
  $contentOnBrand: SemColors.contentOnBrand,
  $contentOnBrandMuted: SemColors.contentOnBrandMuted,

  // Border.
  $borderDefault: SemColors.borderDefault,
  $borderStrong: SemColors.borderStrong,

  // Brand.
  $brandSurface: SemColors.brandSurface,
  $brandSurfaceStrong: SemColors.brandSurfaceStrong,
  $brandUi: SemColors.brandUi,
  $brandUiHover: SemColors.brandUiHover,
  $brandText: SemColors.brandText,
  $brandTextStrong: SemColors.brandTextStrong,

  // Accent.
  $accentSurface: SemColors.accentSurface,
  $accentSurfaceStrong: SemColors.accentSurfaceStrong,
  $accentUi: SemColors.accentUi,
  $accentUiHover: SemColors.accentUiHover,
  $accentText: SemColors.accentText,
  $accentTextStrong: SemColors.accentTextStrong,

  // Positive.
  $positiveSurface: SemColors.positiveSurface,
  $positiveSurfaceStrong: SemColors.positiveSurfaceStrong,
  $positiveUi: SemColors.positiveUi,
  $positiveUiHover: SemColors.positiveUiHover,
  $positiveText: SemColors.positiveText,
  $positiveTextStrong: SemColors.positiveTextStrong,

  // Negative.
  $negativeSurface: SemColors.negativeSurface,
  $negativeSurfaceStrong: SemColors.negativeSurfaceStrong,
  $negativeUi: SemColors.negativeUi,
  $negativeUiHover: SemColors.negativeUiHover,
  $negativeText: SemColors.negativeText,
  $negativeTextStrong: SemColors.negativeTextStrong,

  // Warning.
  $warningSurface: SemColors.warningSurface,
  $warningSurfaceStrong: SemColors.warningSurfaceStrong,
  $warningUi: SemColors.warningUi,
  $warningUiHover: SemColors.warningUiHover,
  $warningText: SemColors.warningText,
  $warningTextStrong: SemColors.warningTextStrong,

  // Alert.
  $alertSurface: SemColors.alertSurface,
  $alertSurfaceStrong: SemColors.alertSurfaceStrong,
  $alertUi: SemColors.alertUi,
  $alertUiHover: SemColors.alertUiHover,
  $alertText: SemColors.alertText,
  $alertTextStrong: SemColors.alertTextStrong,

  // Info.
  $infoSurface: SemColors.infoSurface,
  $infoSurfaceStrong: SemColors.infoSurfaceStrong,
  $infoUi: SemColors.infoUi,
  $infoUiHover: SemColors.infoUiHover,
  $infoText: SemColors.infoText,
  $infoTextStrong: SemColors.infoTextStrong,

  // Neutral.
  $neutralSurface: SemColors.neutralSurface,
  $neutralSurfaceStrong: SemColors.neutralSurfaceStrong,
  $neutralUi: SemColors.neutralUi,
  $neutralUiHover: SemColors.neutralUiHover,
  $neutralText: SemColors.neutralText,
  $neutralTextStrong: SemColors.neutralTextStrong,
};
