import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCallout2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Callout 2',
    variantsBuilder: () => DsCalloutVariant.values
        .map(
          (variant) => DsCallout(
            text: variant.name,
            icon: PhosphorIcons.info(),
            variant: variant,
          ),
        )
        .toList(),
    sizesBuilder: () => DsCalloutSize.values
        .map(
          (size) => DsCallout(
            text: size.name,
            icon: PhosphorIcons.info(),
            size: size,
          ),
        )
        .toList(),
    statesBuilder: () => [
      const DsCallout(text: 'plain text callout'),
      DsCallout(
        text: 'with icon',
        icon: PhosphorIcons.info(),
      ),
      const DsCallout(
        child: Text('with custom child content'),
      ),
    ],
  );
}
