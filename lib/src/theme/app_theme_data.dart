// lib/src/theme/app_theme_data.dart

import 'package:mix/mix.dart';

import 'light/colors.dart';
import 'light/elevation.dart';
import 'light/motion.dart';
import 'light/radius.dart';
import 'light/spacing.dart';
import 'light/typography.dart';

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
