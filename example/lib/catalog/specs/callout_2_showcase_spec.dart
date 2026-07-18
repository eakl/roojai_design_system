import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCallout2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Callout 2',
    // Each color has both a soft and solid tone, which collapse into one
    // `DsCalloutVariant.values` entry — list combinations explicitly
    // instead of mapping over the enum so solid tones are shown too.
    variantsBuilder: () => [
      for (final variant in DsCalloutVariant.values)
        for (final tone in DsCalloutTone.values)
          DsCallout(
            text: '${variant.name} (${tone.name})',
            icon: PhosphorIcons.info(),
            variant: variant,
            tone: tone,
          ),
    ],
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
