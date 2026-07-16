import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCard2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Card 2',
    variantsBuilder: () => DsCardVariant.values
        .map(
          (variant) => DsCard(
            variant: variant,
            child: Text(variant.name),
          ),
        )
        .toList(),
    sizesBuilder: () => DsCardSize.values
        .map(
          (size) => DsCard(
            size: size,
            child: Text(size.name),
          ),
        )
        .toList(),
    // Card has no interactive/public state axis — same as
    // skeleton_2/separator_2 — so statesBuilder is omitted.
  );
}
