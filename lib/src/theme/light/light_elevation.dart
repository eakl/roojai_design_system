// lib/src/theme/light/light_elevation.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/semantic/elevation.dart';

/// The package's built-in default light elevation values, one entry per
/// [BoxShadowToken] declared in `lib/src/tokens/semantic/elevation.dart`.
final Map<BoxShadowToken, List<BoxShadow>> lightElevation = <BoxShadowToken, List<BoxShadow>>{
  $elevationLevel0: AppElevation.level0,
  $elevationLevel1: AppElevation.level1,
  $elevationLevel2: AppElevation.level2,
  $elevationLevel3: AppElevation.level3,
  $elevationLevel4: AppElevation.level4,
};
