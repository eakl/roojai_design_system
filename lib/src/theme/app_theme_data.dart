// lib/src/theme/app_theme_data.dart

import 'package:mix/mix.dart';

import 'light/light_colors.dart';
import 'light/light_elevation.dart';
import 'light/light_motion.dart';
import 'light/light_radius.dart';
import 'light/light_spacing.dart';
import 'light/light_typography.dart';

/// The package's built-in default light theme, mapping every semantic
/// token declared under `lib/src/tokens/semantic/` to its concrete value.
///
/// Each category (colors, typography, spacing, radius, motion, elevation)
/// is defined independently under `lib/src/theme/light/` — mirroring the
/// typed override params on [MixScope]/`AppTokensScope` — then merged here
/// into a single flat map.
///
/// Passed to `MixScope` by `AppTokensScope`. A consuming app may override
/// any subset of these entries to retheme without touching component code.
final Map<MixToken, Object> defaultLightTokens = <MixToken, Object>{
  ...lightColors.cast<MixToken, Object>(),
  ...lightTypography.cast<MixToken, Object>(),
  ...lightSpacing.cast<MixToken, Object>(),
  ...lightRadius.cast<MixToken, Object>(),
  ...lightMotion,
  ...lightElevation.cast<MixToken, Object>(),
};
