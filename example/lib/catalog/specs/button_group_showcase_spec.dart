import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildButtonGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Button Group',
    // ButtonGroup has no variant/size axis of its own — it's a pure layout
    // wrapper around pre-built Buttons (see button_group.dart's doc
    // comment) — so only "Variants" is used here, to demonstrate the one
    // thing that actually varies: which Button variant the group wraps.
    variantsBuilder: () => const [
      ButtonGroup(
        buttons: [
          Button(label: 'Day', variant: ButtonVariant.secondary, onPressed: _noop),
          Button(label: 'Week', variant: ButtonVariant.secondary, onPressed: _noop),
          Button(label: 'Month', variant: ButtonVariant.secondary, onPressed: _noop),
        ],
      ),
      ButtonGroup(
        buttons: [
          Button(label: 'Outline', variant: ButtonVariant.outline, onPressed: _noop),
          Button(label: 'Outline', variant: ButtonVariant.outline, onPressed: _noop),
        ],
      ),
    ],
    statesBuilder: () => const [
      // A single button not disabled next to one that is, to show that
      // ButtonGroup passes each Button's own disabled state through
      // untouched rather than disabling the whole group.
      ButtonGroup(
        buttons: [
          Button(label: 'Enabled', variant: ButtonVariant.secondary, onPressed: _noop),
          Button(
            label: 'Disabled',
            variant: ButtonVariant.secondary,
            onPressed: null,
            disabled: true,
          ),
        ],
      ),
    ],
  );
}

void _noop() {}
