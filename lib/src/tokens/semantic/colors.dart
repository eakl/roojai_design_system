// lib/src/tokens/semantic/colors.dart

import '../primitives/colors.dart';

/// Semantic color values, composed from the raw palette in
/// `lib/src/tokens/primitives/colors.dart`. Only the light theme layer
/// (`lib/src/theme/light/colors.dart`) may reference these directly —
/// components must use the theme's `ColorToken`s instead.
class SemColors {
  SemColors._();

  // Base.
  static const baseTransparent = PrimColors.transparent;
  static const baseWhite = PrimColors.white100;
  static const baseBlack = PrimColors.black100;

  // Canvas.
  static const canvasDefault = PrimColors.white100;
  static const canvasAlternative = PrimColors.neutral050;

  // Surface.
  static const surfaceDefault = PrimColors.white100;
  static const surfaceAlternative = PrimColors.neutral100;
  static const surfaceSunken = PrimColors.neutral200;
  static const surfaceInverted = PrimColors.indigo500;

  // Content.
  static const contentPrimary = PrimColors.neutral1200;
  static const contentSecondary = PrimColors.neutral900;
  static const contentMuted = PrimColors.neutral700;
  static const contentPlaceholder = PrimColors.neutral500;
  static const contentOnBrand = PrimColors.white100;
  static const contentOnBrandMuted = PrimColors.neutral400;

  // Border.
  static const borderDefault = PrimColors.neutral300;
  static const borderStrong = PrimColors.neutral400;

  // Brand.
  static const brandSurface = PrimColors.indigo050;
  static const brandSurfaceStrong = PrimColors.indigo200;
  static const brandUi = PrimColors.indigo500;
  static const brandUiHover = PrimColors.indigo600;
  static const brandText = PrimColors.indigo700;
  static const brandTextStrong = PrimColors.indigo800;

  // Accent.
  static const accentSurface = PrimColors.tangerine050;
  static const accentSurfaceStrong = PrimColors.tangerine200;
  static const accentUi = PrimColors.tangerine500;
  static const accentUiHover = PrimColors.tangerine600;
  static const accentText = PrimColors.tangerine700;
  static const accentTextStrong = PrimColors.tangerine800;

  // Positive.
  static const positiveSurface = PrimColors.green050;
  static const positiveSurfaceStrong = PrimColors.green200;
  static const positiveUi = PrimColors.green500;
  static const positiveUiHover = PrimColors.green600;
  static const positiveText = PrimColors.green700;
  static const positiveTextStrong = PrimColors.green800;

  // Negative.
  static const negativeSurface = PrimColors.red050;
  static const negativeSurfaceStrong = PrimColors.red200;
  static const negativeUi = PrimColors.red500;
  static const negativeUiHover = PrimColors.red600;
  static const negativeText = PrimColors.red700;
  static const negativeTextStrong = PrimColors.red800;

  // Warning.
  static const warningSurface = PrimColors.orange050;
  static const warningSurfaceStrong = PrimColors.orange200;
  static const warningUi = PrimColors.orange500;
  static const warningUiHover = PrimColors.orange600;
  static const warningText = PrimColors.orange700;
  static const warningTextStrong = PrimColors.orange800;

  // Alert.
  static const alertSurface = PrimColors.orange050;
  static const alertSurfaceStrong = PrimColors.orange200;
  static const alertUi = PrimColors.orange500;
  static const alertUiHover = PrimColors.orange600;
  static const alertText = PrimColors.orange700;
  static const alertTextStrong = PrimColors.orange800;

  // Info.
  static const infoSurface = PrimColors.blue050;
  static const infoSurfaceStrong = PrimColors.blue200;
  static const infoUi = PrimColors.blue500;
  static const infoUiHover = PrimColors.blue600;
  static const infoText = PrimColors.blue700;
  static const infoTextStrong = PrimColors.blue800;

  // Neutral.
  static const neutralSurface = PrimColors.neutral050;
  static const neutralSurfaceStrong = PrimColors.neutral200;
  static const neutralUi = PrimColors.neutral500;
  static const neutralUiHover = PrimColors.neutral600;
  static const neutralText = PrimColors.neutral700;
  static const neutralTextStrong = PrimColors.neutral800;
}
