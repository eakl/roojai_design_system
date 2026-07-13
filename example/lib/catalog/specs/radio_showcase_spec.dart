import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildRadioShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Radio',
    // The two enabled radios are grouped under shared local state
    // (`_InteractiveRadioGroup` below) so tapping them in the running app
    // demonstrates real exclusive-select behavior. AppRadio never flips
    // its own value (see its class doc) — it only reports "I was
    // tapped" — so two independently no-op-driven radios would just look
    // broken to tap; grouping them is what actually exercises the
    // widget's contract. The disabled entries need no state since they
    // ignore taps entirely.
    statesBuilder: () => const [
      _InteractiveRadioGroup(),
      AppRadio(selected: false, onSelect: null, disabled: true),
      AppRadio(selected: true, onSelect: null, disabled: true),
    ],
  );
}

class _InteractiveRadioGroup extends StatefulWidget {
  const _InteractiveRadioGroup();

  @override
  State<_InteractiveRadioGroup> createState() =>
      _InteractiveRadioGroupState();
}

class _InteractiveRadioGroupState extends State<_InteractiveRadioGroup> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppRadio(
          selected: _selectedIndex == 0,
          onSelect: () => setState(() => _selectedIndex = 0),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        AppRadio(
          selected: _selectedIndex == 1,
          onSelect: () => setState(() => _selectedIndex = 1),
        ),
      ],
    );
  }
}
