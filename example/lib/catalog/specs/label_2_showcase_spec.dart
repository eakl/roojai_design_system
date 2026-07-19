import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildLabel2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Label 2',
    sizesBuilder: () => DsLabelSize.values
        .map((size) => DsLabel(text: size.name, size: size))
        .toList(),
    // DsLabel is a static, non-interactive caption — no focus/hover states
    // to call out (unlike input_2's transient Naked-driven states).
    statesBuilder: () => const [
      DsLabel(text: 'Default'),
      DsLabel(text: 'Required', required: true),
      DsLabel(text: 'Disabled', disabled: true),
      DsLabel(text: 'Required + disabled', required: true, disabled: true),
    ],
  );
}
