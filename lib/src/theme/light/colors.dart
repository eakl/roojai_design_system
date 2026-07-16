// lib/src/theme/light/light_colors.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/colors.dart';
import '../../tokens/semantic/colors.dart';

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
