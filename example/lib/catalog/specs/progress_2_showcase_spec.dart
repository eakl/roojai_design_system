import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildProgress2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Progress 2',
    sizesBuilder: () => DsProgressSize.values
        .map((size) => DsProgress(value: 0.6, size: size))
        .toList(),
    // Public state is driven by the real `value` prop — there is no
    // hover/press/focus to demonstrate (a progress bar isn't interactive),
    // so the states row instead shows a spread of fill levels.
    statesBuilder: () => const [
      DsProgress(value: 0),
      DsProgress(value: 0.3),
      DsProgress(value: 0.6),
      DsProgress(value: 1),
    ],
  );
}
