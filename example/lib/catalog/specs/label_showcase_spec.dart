import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildLabelShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Label',
    // Label has no variant/size axis (see the doc on `Label`), so only
    // "States" is populated here — one entry per boolean-modifier
    // combination, so the required/disabled interaction is visible too.
    statesBuilder: () => const [
      Label(text: 'Default'),
      Label(text: 'Required', required: true),
      Label(text: 'Disabled', disabled: true),
      Label(text: 'Required & disabled', required: true, disabled: true),
    ],
  );
}
