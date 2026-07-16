import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildRadio2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Radio 2',
    sizesBuilder: () =>
        DsRadioSize.values.map((size) => _InteractiveRadioGroup(size: size)).toList(),
    // Radio selection is exclusive within a group, so every showcased entry
    // needs a `DsRadioGroup` ancestor — a bare `DsRadio` throws if rendered
    // without one (see `RemixRadio`'s own `FlutterError`). Like
    // `DsCheckbox`/`DsSwitch`, the group's whole visual signal is driven by
    // the caller-owned `groupValue`, so the interactive entries below are
    // wrapped in `_InteractiveRadioGroup`, a minimal `StatefulWidget` that
    // owns local state and demonstrates the controlled-widget contract
    // every real caller has to implement. Hover/pressed/focus remain
    // transient and Naked-driven, verified interactively in the running
    // app.
    statesBuilder: () => [
      const _InteractiveRadioGroup(),
      const DsRadioGroup<String>(
        groupValue: 'a',
        onChanged: null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsRadio<String>(value: 'a', enabled: false),
            SizedBox(width: 8),
            DsRadio<String>(value: 'b', enabled: false),
          ],
        ),
      ),
    ],
  );
}

/// Owns local selection state for a two-option showcased [DsRadioGroup], so
/// the catalog page can demonstrate real single-select behavior.
/// [DsRadioGroup] itself holds no internal state — see its `groupValue`
/// doc comment — so any caller wanting live interaction (this showcase
/// included) must do the same: track `groupValue` externally and update it
/// from [DsRadioGroup.onChanged].
class _InteractiveRadioGroup extends StatefulWidget {
  const _InteractiveRadioGroup({this.size = DsRadioSize.md});

  final DsRadioSize size;

  @override
  State<_InteractiveRadioGroup> createState() => _InteractiveRadioGroupState();
}

class _InteractiveRadioGroupState extends State<_InteractiveRadioGroup> {
  String _groupValue = 'a';

  @override
  Widget build(BuildContext context) {
    return DsRadioGroup<String>(
      groupValue: _groupValue,
      onChanged: (value) => setState(() => _groupValue = value ?? _groupValue),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DsRadio<String>(value: 'a', size: widget.size),
          const SizedBox(width: 8),
          DsRadio<String>(value: 'b', size: widget.size),
        ],
      ),
    );
  }
}
