import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Simple leading/trailing glyph used in the showcase only — the real `ui`
/// package has no icon set of its own, components accept arbitrary
/// `Widget`s for icon slots. Mirrors Button's showcase-only `_Dot`.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

ComponentShowcaseSpec buildBadgeShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Badge',
    variantsBuilder: () => BadgeVariant.values
        .map((variant) => Badge(label: variant.name, variant: variant))
        .toList(),
    sizesBuilder: () => BadgeSize.values
        .map((size) => Badge(label: size.name, size: size))
        .toList(),
    // Icon slots and the backgroundColor/foregroundColor override escape
    // hatch don't fit neatly under "variant" or "size", so they're shown
    // together here as additional states/configurations.
    statesBuilder: () => [
      const Badge(
        label: 'leading icon',
        leading: _Dot(color: Color(0xFFFFFFFF)),
      ),
      const Badge(
        label: 'trailing icon',
        trailing: _Dot(color: Color(0xFFFFFFFF)),
      ),
      // Overrides only the fill — foreground still resolves from variant
      // (primary's onBrand white), proving the two overrides are
      // independent of each other.
      const Badge(
        label: 'custom background',
        backgroundColor: Color(0xFF7C3AED),
      ),
      // Overrides only the text/icon color on top of the default primary
      // fill.
      const Badge(
        label: 'custom foreground',
        foregroundColor: Color(0xFFFDE047),
      ),
      // Both overrides supplied together.
      const Badge(
        label: 'custom colors',
        backgroundColor: Color(0xFF0D9488),
        foregroundColor: Color(0xFFECFEFF),
      ),
    ],
  );
}
