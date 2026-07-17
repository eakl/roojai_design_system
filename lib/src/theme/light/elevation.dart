// lib/src/theme/light/light_elevation.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/elevation.dart';

const $elevationLevel0 = BoxShadowToken('elevation.level0');
const $elevationLevel1 = BoxShadowToken('elevation.level1');
const $elevationLevel2 = BoxShadowToken('elevation.level2');
const $elevationLevel3 = BoxShadowToken('elevation.level3');
const $elevationLevel4 = BoxShadowToken('elevation.level4');

/// The package's built-in default light elevation values, one entry per
/// [BoxShadowToken] declared in `lib/src/tokens/semantic/elevation.dart`.
final Map<BoxShadowToken, List<BoxShadow>> lightElevation =
    <BoxShadowToken, List<BoxShadow>>{
  $elevationLevel0: SemElevation.level0,
  $elevationLevel1: SemElevation.level1,
  $elevationLevel2: SemElevation.level2,
  $elevationLevel3: SemElevation.level3,
  $elevationLevel4: SemElevation.level4,
};
