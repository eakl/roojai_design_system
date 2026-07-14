// lib/src/theme/light/light_radius.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/radius.dart';
import '../../tokens/semantic/radius.dart';

/// The package's built-in default light radius values, one entry per
/// [RadiusToken] declared in `lib/src/tokens/semantic/radius.dart`.
final Map<RadiusToken, Radius> lightRadius = <RadiusToken, Radius>{
  $radius000: const Radius.circular(AppRadius.rd000),
  $radius004: const Radius.circular(AppRadius.rd004),
  $radius008: const Radius.circular(AppRadius.rd008),
  $radius012: const Radius.circular(AppRadius.rd012),
  $radius016: const Radius.circular(AppRadius.rd016),
  $radiusFull: const Radius.circular(AppRadius.rdFull),
};
