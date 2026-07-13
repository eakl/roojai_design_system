import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Simple leading/trailing glyph used in the showcase only — the real `ui`
/// package has no icon set of its own, components accept arbitrary
/// `Widget`s for icon slots. Mirrors Button/Toggle/Badge's showcase-only
/// `_Dot`.
class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

ComponentShowcaseSpec buildInputGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input Group',
    // Each entry demonstrates a different combination of addon content
    // (icon / text label / button) on the leading and/or trailing side —
    // the exact "leading icon/label/button" + "trailing icon/label/button"
    // matrix this component exists to cover.
    variantsBuilder: () => [
      // Leading text-label addon (a unit prefix), no trailing addon.
      const SizedBox(
        width: 220,
        child: InputGroup(
          children: [
            InputGroupAddon(child: Text('\$')),
            InputGroupInput(placeholder: 'Amount', type: InputType.number),
          ],
        ),
      ),
      // No leading addon, trailing text-label addon (a unit suffix).
      const SizedBox(
        width: 220,
        child: InputGroup(
          children: [
            InputGroupInput(placeholder: 'Weight'),
            InputGroupAddon(child: Text('kg')),
          ],
        ),
      ),
      // Leading icon addon, trailing InputGroupButton addon — the
      // "search field with a leading glyph and a trailing action" shape.
      const SizedBox(
        width: 220,
        child: InputGroup(
          children: [
            InputGroupAddon(child: _Dot(color: Color(0xFF71717A))),
            InputGroupInput(placeholder: 'Search'),
            InputGroupAddon(
              child: InputGroupButton(label: 'Go', onPressed: _noop),
            ),
          ],
        ),
      ),
      // InputGroupTextarea instead of InputGroupInput, with a top-aligned
      // leading icon addon — demonstrates `crossAxisAlignment.start` so
      // the addon lines up with the textarea's first line instead of
      // stretching/centering across its full multi-line height.
      const SizedBox(
        width: 220,
        child: InputGroup(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 6),
              child: InputGroupAddon(child: _Dot(color: Color(0xFF71717A))),
            ),
            InputGroupTextarea(placeholder: 'Notes', minLines: 3),
          ],
        ),
      ),
    ],
    // disabled/invalid are explicit constructor flags on InputGroup
    // itself, so a static instance is enough to demonstrate each.
    statesBuilder: () => const [
      SizedBox(
        width: 220,
        child: InputGroup(
          disabled: true,
          children: [
            InputGroupAddon(child: Text('\$')),
            InputGroupInput(placeholder: 'Amount', disabled: true),
          ],
        ),
      ),
      SizedBox(
        width: 220,
        child: InputGroup(
          invalid: true,
          children: [
            InputGroupInput(placeholder: 'Email'),
            InputGroupAddon(child: Text('required')),
          ],
        ),
      ),
    ],
  );
}

void _noop() {}
