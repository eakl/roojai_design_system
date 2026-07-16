// lib/src/tokens/primitives/app_motion.dart

import 'package:flutter/widgets.dart';

/// Raw animation durations and curves.
class PrimMotion {
  AppMotion._();

  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
}
