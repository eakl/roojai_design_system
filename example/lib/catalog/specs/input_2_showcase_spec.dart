import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInput2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input 2',
    sizesBuilder: () => DsInputSize.values
        .map(
          (size) => DsInput(
            hintText: size.name,
            size: size,
          ),
        )
        .toList(),
    // Public states (error/disabled) are driven by their real constructor
    // flags. Focus/hover are handled internally by RemixTextField/Naked
    // and are inherently transient, so verify them interactively in the
    // running app instead (tab-focus or click any enabled field below).
    statesBuilder: () => [
      const DsInput(hintText: 'enabled'),
      const DsInput(hintText: 'disabled', enabled: false),
      const DsInput(hintText: 'error', error: true),
      const DsInput(label: 'Label', hintText: 'with label'),
      const DsInput(
        hintText: 'with helper text',
        helperText: 'Helper text goes here',
      ),
      DsInput(
        hintText: 'with leading icon',
        leadingIcon: PhosphorIcons.magnifyingGlass(),
      ),
      DsInput(
        hintText: 'with trailing icon',
        trailingIcon: PhosphorIcons.x(),
      ),
    ],
  );
}
