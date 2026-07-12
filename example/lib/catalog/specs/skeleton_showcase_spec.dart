import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSkeletonShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Skeleton',
    variantsBuilder: () => const [
      Skeleton(shape: SkeletonShape.rectangle, width: 160, height: 100),
      Skeleton(shape: SkeletonShape.circle, height: 48),
      Skeleton(shape: SkeletonShape.text, width: 200, height: 12),
    ],
  );
}
