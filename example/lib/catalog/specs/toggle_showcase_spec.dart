import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Simple leading/trailing glyph used in the showcase only — the real `ui`
/// package has no icon set of its own, components accept arbitrary
/// `Widget`s for icon slots.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

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
    statesBuilder: () => [
      const _InteractiveToggle(label: 'off', initialPressed: false),
      const _InteractiveToggle(label: 'on', initialPressed: true),
      const Toggle(
        label: 'disabled',
        pressed: false,
        onPressedChange: null,
        disabled: true,
      ),
      const Toggle(
        label: 'disabled',
        pressed: true,
        onPressedChange: null,
        disabled: true,
      ),
      const _InteractiveToggle(
        label: 'with leading',
        initialPressed: true,
        leading: _Dot(color: Color(0xFFFFFFFF)),
      ),
      const _InteractiveToggle(
        label: 'with trailing',
        initialPressed: true,
        trailing: _Dot(color: Color(0xFFFFFFFF)),
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
    this.leading,
    this.trailing,
  });

  final String label;
  final bool initialPressed;
  final ToggleVariant variant;
  final ToggleSize size;
  final Widget? leading;
  final Widget? trailing;

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
      leading: widget.leading,
      trailing: widget.trailing,
    );
  }
}
