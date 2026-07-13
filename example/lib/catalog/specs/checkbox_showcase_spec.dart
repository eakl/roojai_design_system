import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCheckboxShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Checkbox',
    // The three enabled entries are backed by local state
    // (`_InteractiveCheckbox` below) so tapping them in the running app
    // actually cycles the value. AppCheckbox is fully controlled — unlike
    // Button, it has no internally-derived "pressed" style — so wiring
    // `onChanged` to a no-op here would make tapping look broken instead
    // of demonstrating the real behavior: tapping cycles
    // unchecked <-> checked, and resolves indeterminate straight to
    // unchecked, per _AppCheckboxState._handleTap. The disabled entries
    // need no state since they ignore taps entirely.
    statesBuilder: () => const [
      _InteractiveCheckbox(initialValue: CheckboxValue.unchecked),
      _InteractiveCheckbox(initialValue: CheckboxValue.checked),
      _InteractiveCheckbox(initialValue: CheckboxValue.indeterminate),
      AppCheckbox(
        value: CheckboxValue.unchecked,
        onChanged: null,
        disabled: true,
      ),
      AppCheckbox(
        value: CheckboxValue.checked,
        onChanged: null,
        disabled: true,
      ),
    ],
  );
}

class _InteractiveCheckbox extends StatefulWidget {
  const _InteractiveCheckbox({required this.initialValue});

  final CheckboxValue initialValue;

  @override
  State<_InteractiveCheckbox> createState() => _InteractiveCheckboxState();
}

class _InteractiveCheckboxState extends State<_InteractiveCheckbox> {
  late CheckboxValue _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AppCheckbox(
      value: _value,
      onChanged: (next) => setState(() => _value = next),
    );
  }
}
