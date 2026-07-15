import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildBadge2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Badge 2',
    variantsBuilder: () => DsBadgeVariant.values
        .map(
          (variant) => DsBadge(
            label: variant.name,
            variant: variant,
          ),
        )
        .toList(),
    sizesBuilder: () => DsBadgeSize.values
        .map(
          (size) => DsBadge(
            label: size.name,
            size: size,
          ),
        )
        .toList(),
    statesBuilder: () => [
      const DsBadge(label: 'plain'),
      DsBadge(
        label: 'with leading',
        leading: Icon(PhosphorIcons.circle()),
      ),
      DsBadge(
        label: 'with trailing',
        trailing: Icon(PhosphorIcons.circle()),
      ),
    ],
  );
}
