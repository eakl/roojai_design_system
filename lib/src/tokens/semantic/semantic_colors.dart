// lib/src/tokens/semantic/semantic_colors.dart

import 'package:flutter/widgets.dart';

import '../primitives/app_colors.dart';

class CanvasColors {
  const CanvasColors({required this.base, required this.alternative});

  // Canvas / Default — named `base` because `default` is a reserved word.
  final Color base;
  final Color alternative;
}

class SurfaceColors {
  const SurfaceColors({
    required this.base,
    required this.alternative,
    required this.inverted,
  });

  final Color base; // Surface / Default
  final Color alternative;
  final Color inverted;
}

class ContentColors {
  const ContentColors({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.placeholder,
    required this.onBrand,
    required this.onBrandMuted,
  });

  final Color primary;
  final Color secondary;
  final Color muted;
  final Color placeholder;
  final Color onBrand;
  final Color onBrandMuted;
}

class BorderColors {
  const BorderColors({required this.base, required this.strong});

  final Color base; // Border / Default
  final Color strong;
}

/// Shared shape for Positive / Negative / Warning / Alert / Info.
class StatusColors {
  const StatusColors({
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.ui,
    required this.uiHover,
    required this.text,
    required this.textStrong,
  });

  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color ui;
  final Color uiHover;
  final Color text;
  final Color textStrong;
}

class SemanticColors {
  const SemanticColors({
    required this.canvas,
    required this.surface,
    required this.content,
    required this.border,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.alert,
    required this.info,
  });

  final CanvasColors canvas;
  final SurfaceColors surface;
  final ContentColors content;
  final BorderColors border;
  final StatusColors positive;
  final StatusColors negative;
  final StatusColors warning;
  final StatusColors alert;
  final StatusColors info;

  /// The package's built-in default light theme values.
  static const SemanticColors defaultLight = SemanticColors(
    canvas: CanvasColors(
      base: AppColors.white,
      alternative: AppColors.gray50,
    ),
    surface: SurfaceColors(
      base: AppColors.white,
      alternative: AppColors.gray100,
      inverted: AppColors.gray900,
    ),
    content: ContentColors(
      primary: AppColors.gray900,
      secondary: AppColors.gray600,
      muted: AppColors.gray500,
      placeholder: AppColors.gray400,
      onBrand: AppColors.white,
      onBrandMuted: AppColors.gray300,
    ),
    border: BorderColors(
      base: AppColors.gray200,
      strong: AppColors.gray400,
    ),
    positive: StatusColors(
      surface: AppColors.green50,
      surfaceStrong: AppColors.green500,
      border: AppColors.green500,
      ui: AppColors.green600,
      uiHover: AppColors.green700,
      text: AppColors.green600,
      textStrong: AppColors.green700,
    ),
    negative: StatusColors(
      surface: AppColors.red50,
      surfaceStrong: AppColors.red500,
      border: AppColors.red500,
      ui: AppColors.red600,
      uiHover: AppColors.red700,
      text: AppColors.red600,
      textStrong: AppColors.red700,
    ),
    warning: StatusColors(
      surface: AppColors.amber50,
      surfaceStrong: AppColors.amber500,
      border: AppColors.amber500,
      ui: AppColors.amber600,
      uiHover: AppColors.amber700,
      text: AppColors.amber600,
      textStrong: AppColors.amber700,
    ),
    alert: StatusColors(
      surface: AppColors.orange50,
      surfaceStrong: AppColors.orange500,
      border: AppColors.orange500,
      ui: AppColors.orange600,
      uiHover: AppColors.orange700,
      text: AppColors.orange600,
      textStrong: AppColors.orange700,
    ),
    info: StatusColors(
      surface: AppColors.sky50,
      surfaceStrong: AppColors.sky500,
      border: AppColors.sky500,
      ui: AppColors.sky600,
      uiHover: AppColors.sky700,
      text: AppColors.sky600,
      textStrong: AppColors.sky700,
    ),
  );
}
