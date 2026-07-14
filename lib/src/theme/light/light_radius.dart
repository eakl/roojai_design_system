// lib/src/theme/light/light_radius.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/radius.dart';

/// The package's built-in default light radius values, one entry per
/// [RadiusToken] declared in `lib/src/tokens/semantic/radius.dart`.
final Map<RadiusToken, Radius> lightRadius = <RadiusToken, Radius>{
  $radiusSm: const Radius.circular(AppRadius.radius4),
  $radiusMd: const Radius.circular(AppRadius.radius8),
  $radiusLg: const Radius.circular(AppRadius.radius12),
  $radiusXl: const Radius.circular(AppRadius.radius16),
  $radiusFull: const Radius.circular(AppRadius.radiusFull),
};
