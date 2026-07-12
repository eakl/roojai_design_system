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

ComponentShowcaseSpec buildButtonShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Button',
    variantsBuilder: () => ButtonVariant.values
        .map(
          (variant) => Button(
            label: variant.name,
            variant: variant,
            onPressed: _noop,
          ),
        )
        .toList(),
    sizesBuilder: () => ButtonSize.values
        .map(
          (size) => Button(
            label: size.name,
            size: size,
            onPressed: _noop,
          ),
        )
        .toList(),
    // Public states (loading/disabled) are driven by their real
    // constructor flags. "pressed" is the widget's one internally-derived
    // state and is inherently transient, so it can't be held for a static
    // screenshot here — verify it interactively in the running app instead
    // (hold the pointer down on any enabled button below).
    statesBuilder: () => [
      const Button(label: 'enabled', onPressed: _noop),
      const Button(label: 'disabled', onPressed: null, disabled: true),
      const Button(label: 'loading', onPressed: _noop, loading: true),
      const Button(
        label: 'with leading',
        onPressed: _noop,
        leading: _Dot(color: Color(0xFFFFFFFF)),
      ),
      const Button(
        label: 'with trailing',
        onPressed: _noop,
        trailing: _Dot(color: Color(0xFFFFFFFF)),
      ),
    ],
  );
}

void _noop() {}
