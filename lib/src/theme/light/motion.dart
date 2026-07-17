// lib/src/theme/light/light_motion.dart

import 'package:mix/mix.dart';

import '../curve_token.dart';
import '../../tokens/semantic/motion.dart';

// Curve.
const $motionCurveStandard = CurveToken('motion.curve.standard');
const $motionCurveEmphasized = CurveToken('motion.curve.emphasized');

// Duration.
const $motionDurationFast = DurationToken('motion.duration.fast');
const $motionDurationNormal = DurationToken('motion.duration.normal');
const $motionDurationSlow = DurationToken('motion.duration.slow');

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
  $motionDurationFast: SemMotion.durationFast,
  $motionDurationNormal: SemMotion.durationNormal,
  $motionDurationSlow: SemMotion.durationSlow,

  // Curve.
  $motionCurveStandard: SemMotion.curveStandard,
  $motionCurveEmphasized: SemMotion.curveEmphasized,
};
