import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSpinnerShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Spinner',
    sizesBuilder: () =>
        SpinnerSize.values.map((size) => Spinner(size: size)).toList(),
    // `inverted` swaps to the on-brand color for placement on dark/brand
    // surfaces. Shown here against a dark container standing in for
    // `colors.surface.inverted` — on the showcase page's light canvas
    // background the inverted spinner would otherwise be invisible.
    statesBuilder: () => [
      const Spinner(),
      Container(
        padding: const EdgeInsets.all(AppSpacing.spacing12),
        color: const Color(0xFF18181B),
        child: const Spinner(inverted: true),
      ),
    ],
  );
}
