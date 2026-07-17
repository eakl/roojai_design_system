// lib/src/theme/light/light_radius.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/radius.dart';

const $radius000 = RadiusToken('radius.0');
const $radius004 = RadiusToken('radius.4');
const $radius008 = RadiusToken('radius.8');
const $radius012 = RadiusToken('radius.12');
const $radius016 = RadiusToken('radius.16');
const $radiusFull = RadiusToken('radius.full');

/// The package's built-in default light radius values, one entry per
/// [RadiusToken] declared in `lib/src/tokens/semantic/radius.dart`.
final Map<RadiusToken, Radius> lightRadius = <RadiusToken, Radius>{
  $radius000: const Radius.circular(SemRadius.radius000),
  $radius004: const Radius.circular(SemRadius.radius004),
  $radius008: const Radius.circular(SemRadius.radius008),
  $radius012: const Radius.circular(SemRadius.radius012),
  $radius016: const Radius.circular(SemRadius.radius016),
  $radiusFull: const Radius.circular(SemRadius.radiusFull),
};
