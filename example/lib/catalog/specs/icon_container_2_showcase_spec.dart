import 'package:flutter/material.dart' show Icons;
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildIconContainer2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Icon Container 2',
    variantsBuilder: () => DsIconContainerVariant.values
        .map((variant) => IconContainer(Icons.star, variant: variant))
        .toList(),
    sizesBuilder: () => DsIconContainerSize.values
        .map((size) => IconContainer(Icons.star, size: size))
        .toList(),
  );
}
