import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

const _fruitOptions = ['Apple', 'Banana', 'Cherry', 'Durian', 'Elderberry'];

ComponentShowcaseSpec buildSelectShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Select',
    // The two enabled entries are backed by local state
    // (`_InteractiveSelect` below) so tapping them in the running app
    // actually opens the menu and updates the trigger text on pick.
    // AppSelect is fully controlled — like AppCheckbox/AppSwitch — so
    // wiring `onChanged` to a no-op here would make tapping look broken
    // instead of demonstrating the real behavior.
    statesBuilder: () => const [
      _InteractiveSelect(),
      _InteractiveSelect(initialSelected: 'Banana'),
      AppSelect(options: _fruitOptions, onChanged: null, disabled: true),
      _InteractiveSelect(invalid: true),
    ],
  );
}

class _InteractiveSelect extends StatefulWidget {
  const _InteractiveSelect({this.initialSelected, this.invalid = false});

  final String? initialSelected;
  final bool invalid;

  @override
  State<_InteractiveSelect> createState() => _InteractiveSelectState();
}

class _InteractiveSelectState extends State<_InteractiveSelect> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    return AppSelect(
      options: _fruitOptions,
      selected: _selected,
      invalid: widget.invalid,
      onChanged: (next) => setState(() => _selected = next),
    );
  }
}
