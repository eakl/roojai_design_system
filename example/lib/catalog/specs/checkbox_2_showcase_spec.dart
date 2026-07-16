import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCheckbox2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Checkbox 2',
    sizesBuilder: () => DsCheckboxSize.values
        .map(
          (size) => _InteractiveCheckbox(initialSelected: true, size: size),
        )
        .toList(),
    // Selected/indeterminate/disabled are driven by real constructor flags,
    // same as every other showcase spec — but like `DsSwitch`, `DsCheckbox`'s
    // whole visual signal (glyph shown) is driven by the caller-owned
    // `selected` prop. A static `selected` value would never visibly toggle
    // on tap, so the interactive entries below are wrapped in
    // `_InteractiveCheckbox`, a minimal `StatefulWidget` that owns local
    // state and demonstrates the controlled-widget contract every real
    // caller has to implement. Hover/pressed/focus remain transient and
    // Naked-driven, verified interactively in the running app.
    statesBuilder: () => [
      const _InteractiveCheckbox(initialSelected: false),
      const _InteractiveCheckbox(initialSelected: true),
      const DsCheckbox(selected: null, tristate: true, onChanged: null),
      const DsCheckbox(selected: false, onChanged: null, enabled: false),
      const DsCheckbox(selected: true, onChanged: null, enabled: false),
    ],
  );
}

/// Owns local checked/unchecked state for a single showcased [DsCheckbox],
/// so the catalog page can demonstrate real toggling. [DsCheckbox] itself
/// holds no internal state — see [DsCheckbox.selected]'s doc comment — so
/// any caller wanting live interaction (this showcase included) must do the
/// same: track `selected` externally and update it from
/// [DsCheckbox.onChanged].
class _InteractiveCheckbox extends StatefulWidget {
  const _InteractiveCheckbox({
    required this.initialSelected,
    this.size = DsCheckboxSize.md,
  });

  final bool initialSelected;
  final DsCheckboxSize size;

  @override
  State<_InteractiveCheckbox> createState() => _InteractiveCheckboxState();
}

class _InteractiveCheckboxState extends State<_InteractiveCheckbox> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return DsCheckbox(
      selected: _selected,
      size: widget.size,
      onChanged: (value) => setState(() => _selected = value ?? false),
    );
  }
}
