// lib/src/theme/light/light_colors.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/app_colors.dart';
import '../../tokens/semantic/colors.dart';

/// The package's built-in default light color values, one entry per
/// [ColorToken] declared in `lib/src/tokens/semantic/colors.dart`.
final Map<ColorToken, Color> lightColors = <ColorToken, Color>{
  // Canvas.
  $canvasBase: AppColors.white,
  $canvasAlternative: AppColors.gray50,

  // Surface.
  $surfaceBase: AppColors.white,
  $surfaceAlternative: AppColors.gray100,
  $surfaceInverted: AppColors.gray900,

  // Content.
  $contentPrimary: AppColors.gray900,
  $contentSecondary: AppColors.gray600,
  $contentMuted: AppColors.gray500,
  $contentPlaceholder: AppColors.gray400,
  $contentOnBrand: AppColors.white,
  $contentOnBrandMuted: AppColors.gray300,

  // Border.
  $borderBase: AppColors.gray200,
  $borderStrong: AppColors.gray400,

  // Positive.
  $positiveSurface: AppColors.green50,
  $positiveSurfaceStrong: AppColors.green500,
  $positiveBorder: AppColors.green500,
  $positiveUi: AppColors.green600,
  $positiveUiHover: AppColors.green700,
  $positiveText: AppColors.green600,
  $positiveTextStrong: AppColors.green700,

  // Negative.
  $negativeSurface: AppColors.red50,
  $negativeSurfaceStrong: AppColors.red500,
  $negativeBorder: AppColors.red500,
  $negativeUi: AppColors.red600,
  $negativeUiHover: AppColors.red700,
  $negativeText: AppColors.red600,
  $negativeTextStrong: AppColors.red700,

  // Warning.
  $warningSurface: AppColors.amber50,
  $warningSurfaceStrong: AppColors.amber500,
  $warningBorder: AppColors.amber500,
  $warningUi: AppColors.amber600,
  $warningUiHover: AppColors.amber700,
  $warningText: AppColors.amber600,
  $warningTextStrong: AppColors.amber700,

  // Alert.
  $alertSurface: AppColors.orange50,
  $alertSurfaceStrong: AppColors.orange500,
  $alertBorder: AppColors.orange500,
  $alertUi: AppColors.orange600,
  $alertUiHover: AppColors.orange700,
  $alertText: AppColors.orange600,
  $alertTextStrong: AppColors.orange700,

  // Info.
  $infoSurface: AppColors.sky50,
  $infoSurfaceStrong: AppColors.sky500,
  $infoBorder: AppColors.sky500,
  $infoUi: AppColors.sky600,
  $infoUiHover: AppColors.sky700,
  $infoText: AppColors.sky600,
  $infoTextStrong: AppColors.sky700,
};
