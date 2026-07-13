import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToggleShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle',
    // Each entry is backed by local state (`_InteractiveToggle` below) so
    // tapping it in the running app actually flips `pressed`. Toggle is
    // fully controlled — like AppSwitch, it has no internally-derived
    // "selected" style — so wiring `onPressedChange` to a no-op here would
    // make tapping look broken instead of demonstrating the real behavior.
    variantsBuilder: () => const [
      _InteractiveToggle(
        label: 'standard',
        initialPressed: true,
        variant: ToggleVariant.standard,
      ),
      _InteractiveToggle(
        label: 'outline',
        initialPressed: true,
        variant: ToggleVariant.outline,
      ),
    ],
    sizesBuilder: () => const [
      _InteractiveToggle(label: 'sm', initialPressed: true, size: ToggleSize.sm),
      _InteractiveToggle(label: 'md', initialPressed: true, size: ToggleSize.md),
      _InteractiveToggle(label: 'lg', initialPressed: true, size: ToggleSize.lg),
    ],
    // The disabled entries need no state since they ignore taps entirely.
    statesBuilder: () => const [
      _InteractiveToggle(label: 'off', initialPressed: false),
      _InteractiveToggle(label: 'on', initialPressed: true),
      Toggle(
        label: 'disabled',
        pressed: false,
        onPressedChange: null,
        disabled: true,
      ),
      Toggle(
        label: 'disabled',
        pressed: true,
        onPressedChange: null,
        disabled: true,
      ),
    ],
  );
}

class _InteractiveToggle extends StatefulWidget {
  const _InteractiveToggle({
    required this.label,
    required this.initialPressed,
    this.variant = ToggleVariant.standard,
    this.size = ToggleSize.md,
  });

  final String label;
  final bool initialPressed;
  final ToggleVariant variant;
  final ToggleSize size;

  @override
  State<_InteractiveToggle> createState() => _InteractiveToggleState();
}

class _InteractiveToggleState extends State<_InteractiveToggle> {
  late bool _pressed;

  @override
  void initState() {
    super.initState();
    _pressed = widget.initialPressed;
  }

  @override
  Widget build(BuildContext context) {
    return Toggle(
      label: widget.label,
      pressed: _pressed,
      onPressedChange: (next) => setState(() => _pressed = next),
      variant: widget.variant,
      size: widget.size,
    );
  }
}
