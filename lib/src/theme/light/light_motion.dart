// lib/src/theme/light/light_motion.dart

import 'package:mix/mix.dart';

import '../../tokens/primitives/app_motion.dart';
import '../../tokens/semantic/motion.dart';

/// The package's built-in default light motion values, one entry per
/// `DurationToken`/`CurveToken` declared in
/// `lib/src/tokens/semantic/motion.dart`.
///
/// Typed as `Map<MixToken, Object>` (rather than a single typed alias)
/// because `DurationToken` and `CurveToken` are different token types with
/// no dedicated typed override param on [MixScope] — matching the `tokens`
/// catch-all param on `AppTokensScope`.
final Map<MixToken, Object> lightMotion = <MixToken, Object>{
  // Duration.
  $motionDurationFast: AppMotion.durationFast,
  $motionDurationNormal: AppMotion.durationNormal,
  $motionDurationSlow: AppMotion.durationSlow,

  // Curve.
  $motionCurveStandard: AppMotion.curveStandard,
  $motionCurveEmphasized: AppMotion.curveEmphasized,
};
