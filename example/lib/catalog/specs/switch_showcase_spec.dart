import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSwitchShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Switch',
    // The two enabled entries are backed by local state (`_InteractiveSwitch`
    // below) so tapping them in the running app actually flips the value.
    // AppSwitch is fully controlled — unlike Button, it has no internally-
    // derived "pressed" style — so wiring `onChanged` to a no-op here would
    // make tapping look broken instead of demonstrating the real behavior.
    // The disabled entries need no state since they ignore taps entirely.
    statesBuilder: () => const [
      _InteractiveSwitch(initialValue: false),
      _InteractiveSwitch(initialValue: true),
      AppSwitch(value: false, onChanged: null, disabled: true),
      AppSwitch(value: true, onChanged: null, disabled: true),
    ],
  );
}

class _InteractiveSwitch extends StatefulWidget {
  const _InteractiveSwitch({required this.initialValue});

  final bool initialValue;

  @override
  State<_InteractiveSwitch> createState() => _InteractiveSwitchState();
}

class _InteractiveSwitchState extends State<_InteractiveSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AppSwitch(
      value: _value,
      onChanged: (next) => setState(() => _value = next),
    );
  }
}
