import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSliderShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Slider',
    // The two enabled entries are backed by local state (`_InteractiveSlider`
    // below) so dragging or tapping them in the running app actually moves
    // the thumb. AppSlider is fully controlled — unlike Button, it has no
    // internally-derived "pressed" style — so wiring `onChanged` to a
    // no-op here would make interacting with it look broken instead of
    // demonstrating the real behavior. The disabled entry needs no state
    // since it ignores drag/tap entirely.
    statesBuilder: () => const [
      _InteractiveSlider(initialValue: 0.2),
      _InteractiveSlider(initialValue: 0.7),
      AppSlider(value: 0.5, onChanged: null, disabled: true),
    ],
  );
}

class _InteractiveSlider extends StatefulWidget {
  const _InteractiveSlider({required this.initialValue});

  final double initialValue;

  @override
  State<_InteractiveSlider> createState() => _InteractiveSliderState();
}

class _InteractiveSliderState extends State<_InteractiveSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AppSlider(
      value: _value,
      onChanged: (next) => setState(() => _value = next),
    );
  }
}
