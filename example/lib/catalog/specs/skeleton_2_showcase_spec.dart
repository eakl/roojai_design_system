import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSkeleton2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Skeleton 2',
    // No variant or size axis — `DsSkeletonShape` is demonstrated via
    // statesBuilder instead, same no-variant shape spinner_2's showcase
    // spec uses.
    statesBuilder: () => const [
      DsSkeleton(),
      DsSkeleton(shape: DsSkeletonShape.circle, width: 40, height: 40),
      DsSkeleton(shape: DsSkeletonShape.text, width: 200, height: 12),
    ],
  );
}
