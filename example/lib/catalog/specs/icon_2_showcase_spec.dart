import 'package:flutter/material.dart' show Icons;
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildIcon2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Icon 2',
    variantsBuilder: () => DsIconVariant.values
        .map((variant) => Icon(Icons.star, variant: variant))
        .toList(),
    sizesBuilder: () =>
        DsIconSize.values.map((size) => Icon(Icons.star, size: size)).toList(),
  );
}
