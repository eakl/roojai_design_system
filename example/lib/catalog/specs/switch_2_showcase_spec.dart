import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSwitch2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Switch 2',
    sizesBuilder: () => DsSwitchSize.values
        .map(
          (size) => _InteractiveSwitch(initialSelected: true, size: size),
        )
        .toList(),
    // Selected/disabled are driven by real constructor flags, same as
    // every other showcase spec — but unlike DsButton/DsInput (whose key
    // interactive feedback — press animation, focus ring — lives entirely
    // inside their Remix widget), DsSwitch's whole visual signal (thumb
    // position) is driven by the caller-owned `selected` prop. A static
    // `selected` value would never visibly toggle on tap, so the two
    // enabled entries below are wrapped in `_InteractiveSwitch`, a
    // minimal `StatefulWidget` that owns local state and demonstrates the
    // controlled-widget contract every real caller has to implement.
    // Hover/pressed/focus remain transient and Naked-driven, verified
    // interactively in the running app.
    statesBuilder: () => [
      const _InteractiveSwitch(initialSelected: true),
      const _InteractiveSwitch(initialSelected: false),
      const DsSwitch(selected: true, onChanged: null, enabled: false),
      const DsSwitch(selected: false, onChanged: null, enabled: false),
    ],
  );
}

/// Owns local on/off state for a single showcased [DsSwitch], so the
/// catalog page can demonstrate real toggling. [DsSwitch] itself holds no
/// internal state — see [DsSwitch.selected]'s doc comment — so any caller
/// wanting live interaction (this showcase included) must do the same:
/// track `selected` externally and update it from [DsSwitch.onChanged].
class _InteractiveSwitch extends StatefulWidget {
  const _InteractiveSwitch({
    required this.initialSelected,
    this.size = DsSwitchSize.md,
  });

  final bool initialSelected;
  final DsSwitchSize size;

  @override
  State<_InteractiveSwitch> createState() => _InteractiveSwitchState();
}

class _InteractiveSwitchState extends State<_InteractiveSwitch> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return DsSwitch(
      selected: _selected,
      size: widget.size,
      onChanged: (value) => setState(() => _selected = value),
    );
  }
}
