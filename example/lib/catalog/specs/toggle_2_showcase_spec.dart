import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToggle2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle 2',
    variantsBuilder: () => DsToggleVariant.values
        .map(
          (variant) => DsToggle(
            label: variant.name,
            variant: variant,
            selected: false,
            onChanged: _noop,
          ),
        )
        .toList(),
    sizesBuilder: () => DsToggleSize.values
        .map(
          (size) => DsToggle(
            label: size.name,
            size: size,
            selected: false,
            onChanged: _noop,
          ),
        )
        .toList(),
    // Selected/disabled are driven by real constructor flags, same as every
    // other showcase spec — but unlike DsButton (whose key interactive
    // feedback lives entirely inside its Remix widget), DsToggle's on/off
    // visual signal is driven by the caller-owned `selected` prop. A static
    // `selected` value would never visibly toggle on tap, so the two
    // enabled entries below are wrapped in `_InteractiveToggle`, a minimal
    // `StatefulWidget` that owns local state and demonstrates the
    // controlled-widget contract every real caller has to implement — same
    // pattern `switch_2_showcase_spec.dart` uses for `_InteractiveSwitch`.
    // Hover/pressed/focus remain transient and Naked-driven, verified
    // interactively in the running app.
    statesBuilder: () => [
      const _InteractiveToggle(initialSelected: true),
      const _InteractiveToggle(initialSelected: false),
      const DsToggle(
        label: 'disabled (selected)',
        selected: true,
        onChanged: null,
        enabled: false,
      ),
      const DsToggle(
        label: 'disabled (unselected)',
        selected: false,
        onChanged: null,
        enabled: false,
      ),
      _InteractiveToggle(
        initialSelected: false,
        icon: PhosphorIcons.textB(),
      ),
      _InteractiveToggle(
        initialSelected: false,
        label: 'Bold',
        icon: PhosphorIcons.textB(),
      ),
    ],
  );
}

void _noop(bool _) {}

/// Owns local on/off state for a single showcased [DsToggle], so the
/// catalog page can demonstrate real toggling. [DsToggle] itself holds no
/// internal state — see [DsToggle.selected]'s doc comment — so any caller
/// wanting live interaction (this showcase included) must do the same:
/// track `selected` externally and update it from [DsToggle.onChanged].
class _InteractiveToggle extends StatefulWidget {
  const _InteractiveToggle({
    required this.initialSelected,
    this.label = 'Label',
    this.icon,
  });

  final bool initialSelected;
  final String? label;
  final IconData? icon;

  @override
  State<_InteractiveToggle> createState() => _InteractiveToggleState();
}

class _InteractiveToggleState extends State<_InteractiveToggle> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return DsToggle(
      selected: _selected,
      label: widget.label,
      icon: widget.icon,
      onChanged: (value) => setState(() => _selected = value),
    );
  }
}
