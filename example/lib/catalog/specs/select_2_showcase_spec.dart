import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:remix/remix.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

const _items = [
  RemixSelectItem(value: 'apple', label: 'Apple'),
  RemixSelectItem(value: 'banana', label: 'Banana'),
  RemixSelectItem(value: 'orange', label: 'Orange'),
];

ComponentShowcaseSpec buildSelect2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Select 2',
    sizesBuilder: () => DsSelectSize.values
        .map((size) => _InteractiveSelect(size: size))
        .toList(),
    // Selected value is driven by the real controlled-widget contract, same
    // as `switch_2`'s showcase — DsSelect holds no internal selection state
    // (see DsSelect.selectedValue's doc comment), so the enabled entry below
    // is wrapped in `_InteractiveSelect`, a minimal `StatefulWidget` that
    // owns local state and demonstrates real selection/toggling. Disabled
    // and error are driven directly by their real constructor flags.
    // Hover/pressed/focus/open remain transient and Naked-driven, verified
    // interactively in the running app.
    statesBuilder: () => [
      const _InteractiveSelect(),
      const DsSelect<String>(items: _items, enabled: false),
      const DsSelect<String>(items: _items, error: true),
      DsSelect<String>(
        items: _items,
        leadingIcon: PhosphorIcons.appleLogo(),
      ),
      const DsSelect<String>(items: _items, selectedValue: 'banana'),
    ],
  );
}

/// Owns local selection state for a single showcased [DsSelect], so the
/// catalog page can demonstrate real selecting. [DsSelect] itself holds no
/// internal state — see [DsSelect.selectedValue]'s doc comment — so any
/// caller wanting live interaction (this showcase included) must do the
/// same: track `selectedValue` externally and update it from
/// [DsSelect.onChanged].
class _InteractiveSelect extends StatefulWidget {
  const _InteractiveSelect({this.size = DsSelectSize.md});

  final DsSelectSize size;

  @override
  State<_InteractiveSelect> createState() => _InteractiveSelectState();
}

class _InteractiveSelectState extends State<_InteractiveSelect> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return DsSelect<String>(
      items: _items,
      size: widget.size,
      selectedValue: _selectedValue,
      onChanged: (value) => setState(() => _selectedValue = value),
    );
  }
}
