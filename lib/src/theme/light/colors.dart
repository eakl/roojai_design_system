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
const $contentOnBrandSecondary = ColorToken('color.content.onBrandSecondary');
const $contentOnBrandMuted = ColorToken('color.content.onBrandMuted');

// Border.
const $borderDefault = ColorToken('color.border.default');
const $borderStrong = ColorToken('color.border.strong');

// Brand.
const $brandSurface = ColorToken('color.brand.surface');
const $brandSurfaceStrong = ColorToken('color.brand.surfaceStrong');
const $brandBorder = ColorToken('color.brand.border');
const $brandUi = ColorToken('color.brand.ui');
const $brandUiHover = ColorToken('color.brand.uiHover');
const $brandText = ColorToken('color.brand.text');
const $brandTextStrong = ColorToken('color.brand.textStrong');

// Accent.
const $accentSurface = ColorToken('color.accent.surface');
const $accentSurfaceStrong = ColorToken('color.accent.surfaceStrong');
const $accentBorder = ColorToken('color.accent.border');
const $accentUi = ColorToken('color.accent.ui');
const $accentUiHover = ColorToken('color.accent.uiHover');
const $accentText = ColorToken('color.accent.text');
const $accentTextStrong = ColorToken('color.accent.textStrong');

// Positive.
const $positiveSurface = ColorToken('color.positive.surface');
const $positiveSurfaceStrong = ColorToken('color.positive.surfaceStrong');
const $positiveBorder = ColorToken('color.positive.border');
const $positiveUi = ColorToken('color.positive.ui');
const $positiveUiHover = ColorToken('color.positive.uiHover');
const $positiveText = ColorToken('color.positive.text');
const $positiveTextStrong = ColorToken('color.positive.textStrong');

// Negative.
const $negativeSurface = ColorToken('color.negative.surface');
const $negativeSurfaceStrong = ColorToken('color.negative.surfaceStrong');
const $negativeBorder = ColorToken('color.negative.border');
const $negativeUi = ColorToken('color.negative.ui');
const $negativeUiHover = ColorToken('color.negative.uiHover');
const $negativeText = ColorToken('color.negative.text');
const $negativeTextStrong = ColorToken('color.negative.textStrong');

// Warning.
const $warningSurface = ColorToken('color.warning.surface');
const $warningSurfaceStrong = ColorToken('color.warning.surfaceStrong');
const $warningBorder = ColorToken('color.warning.border');
const $warningUi = ColorToken('color.warning.ui');
const $warningUiHover = ColorToken('color.warning.uiHover');
const $warningText = ColorToken('color.warning.text');
const $warningTextStrong = ColorToken('color.warning.textStrong');

// Alert.
const $alertSurface = ColorToken('color.alert.surface');
const $alertSurfaceStrong = ColorToken('color.alert.surfaceStrong');
const $alertBorder = ColorToken('color.alert.border');
const $alertUi = ColorToken('color.alert.ui');
const $alertUiHover = ColorToken('color.alert.uiHover');
const $alertText = ColorToken('color.alert.text');
const $alertTextStrong = ColorToken('color.alert.textStrong');

// Info.
const $infoSurface = ColorToken('color.info.surface');
const $infoSurfaceStrong = ColorToken('color.info.surfaceStrong');
const $infoBorder = ColorToken('color.info.border');
const $infoUi = ColorToken('color.info.ui');
const $infoUiHover = ColorToken('color.info.uiHover');
const $infoText = ColorToken('color.info.text');
const $infoTextStrong = ColorToken('color.info.textStrong');

// Neutral.
const $neutralSurface = ColorToken('color.neutral.surface');
const $neutralSurfaceStrong = ColorToken('color.neutral.surfaceStrong');
const $neutralBorder = ColorToken('color.neutral.border');
const $neutralUi = ColorToken('color.neutral.ui');
const $neutralUiHover = ColorToken('color.neutral.uiHover');
const $neutralText = ColorToken('color.neutral.text');
const $neutralTextStrong = ColorToken('color.neutral.textStrong');




/// The package's built-in default light color values, one entry per
/// [ColorToken] declared in `lib/src/tokens/semantic/colors.dart`.
final Map<ColorToken, Color> lightColors = <ColorToken, Color>{
  // Base.
  $transparent: AppColors.transparent,
  $white: AppColors.white100,
  $black: AppColors.black100,

  // Canvas.
  $canvasDefault: AppColors.white100,
  $canvasAlternative: AppColors.neutral050,

  // Surface.
  $surfaceDefault: AppColors.white100,
  $surfaceAlternative: AppColors.neutral100,
  $surfaceSunken: AppColors.neutral200,
  $surfaceInverted: AppColors.indigo500,

  // Content.
  $contentPrimary: AppColors.neutral1200,
  $contentSecondary: AppColors.neutral900,
  $contentMuted: AppColors.neutral700,
  $contentPlaceholder: AppColors.neutral500,
  $contentOnBrand: AppColors.white100,
  $contentOnBrandMuted: AppColors.neutral400,

  // Border.
  $borderDefault: AppColors.neutral300,
  $borderStrong: AppColors.neutral400,

  // Brand.
  $brandSurface: AppColors.indigo050,
  $brandSurfaceStrong: AppColors.indigo200,
  $brandUi: AppColors.indigo500,
  $brandUiHover: AppColors.indigo600,
  $brandText: AppColors.indigo700,
  $brandTextStrong: AppColors.indigo800,

  // Accent.
  $accentSurface: AppColors.tangerine050,
  $accentSurfaceStrong: AppColors.tangerine200,
  $accentUi: AppColors.tangerine500,
  $accentUiHover: AppColors.tangerine600,
  $accentText: AppColors.tangerine700,
  $accentTextStrong: AppColors.tangerine800,

  // Positive.
  $positiveSurface: AppColors.green050,
  $positiveSurfaceStrong: AppColors.green200,
  $positiveUi: AppColors.green500,
  $positiveUiHover: AppColors.green600,
  $positiveText: AppColors.green700,
  $positiveTextStrong: AppColors.green800,

  // Negative.
  $negativeSurface: AppColors.red050,
  $negativeSurfaceStrong: AppColors.red200,
  $negativeUi: AppColors.red500,
  $negativeUiHover: AppColors.red600,
  $negativeText: AppColors.red700,
  $negativeTextStrong: AppColors.red800,

  // Warning.
  $warningSurface: AppColors.orange050,
  $warningSurfaceStrong: AppColors.orange200,
  $warningUi: AppColors.orange500,
  $warningUiHover: AppColors.orange600,
  $warningText: AppColors.orange700,
  $warningTextStrong: AppColors.orange800,

  // Alert.
  $alertSurface: AppColors.orange050,
  $alertSurfaceStrong: AppColors.orange200,
  $alertUi: AppColors.orange500,
  $alertUiHover: AppColors.orange600,
  $alertText: AppColors.orange700,
  $alertTextStrong: AppColors.orange800,

  // Info.
  $infoSurface: AppColors.blue050,
  $infoSurfaceStrong: AppColors.blue200,
  $infoUi: AppColors.blue500,
  $infoUiHover: AppColors.blue600,
  $infoText: AppColors.blue700,
  $infoTextStrong: AppColors.blue800,

  // Neutral.
  $neutralSurface: AppColors.neutral050,
  $neutralSurfaceStrong: AppColors.neutral200,
  $neutralUi: AppColors.neutral500,
  $neutralUiHover: AppColors.neutral600,
  $neutralText: AppColors.neutral700,
  $neutralTextStrong: AppColors.neutral800,
};
