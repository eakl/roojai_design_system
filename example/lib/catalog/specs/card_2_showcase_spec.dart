import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCard2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Card 2',
    // `filled` has three tones (base/alternative/inverted) that collapse
    // into one `DsCardVariant.values` entry, so list combinations
    // explicitly instead of mapping over the enum — otherwise the
    // alternative/inverted tones would never be shown.
    variantsBuilder: () => [
      DsCard(
        variant: DsCardVariant.elevated,
        child: const Text('elevated'),
      ),
      DsCard(
        variant: DsCardVariant.bordered,
        child: const Text('bordered'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.base,
        child: const Text('filled (base)'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.alternative,
        child: const Text('filled (alternative)'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.inverted,
        child: const Text('filled (inverted)'),
      ),
    ],
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
