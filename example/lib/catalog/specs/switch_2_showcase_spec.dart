import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSwitch2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Switch 2',
    sizesBuilder: () => DsSwitchSize.values
        .map(
          (size) => DsSwitch(
            selected: true,
            size: size,
            onChanged: _noop,
          ),
        )
        .toList(),
    // Public states (selected/disabled) are driven by their real
    // constructor flags. Hover/pressed/focus are handled internally by
    // RemixSwitch and are inherently transient, so verify them
    // interactively in the running app instead (hover/hold/tab-focus any
    // enabled switch below).
    statesBuilder: () => [
      const DsSwitch(selected: true, onChanged: _noop),
      const DsSwitch(selected: false, onChanged: _noop),
      const DsSwitch(selected: true, onChanged: null, enabled: false),
      const DsSwitch(selected: false, onChanged: null, enabled: false),
    ],
  );
}

void _noop(bool _) {}
