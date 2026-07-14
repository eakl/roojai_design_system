import 'package:flutter/material.dart' show Icons;
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildButton2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Button 2',
    variantsBuilder: () => DsButtonVariant.values
        .map(
          (variant) => DsButton(
            label: variant.name,
            variant: variant,
            onPressed: _noop,
          ),
        )
        .toList(),
    sizesBuilder: () => DsButtonSize.values
        .map(
          (size) => DsButton(
            label: size.name,
            size: size,
            onPressed: _noop,
          ),
        )
        .toList(),
    // Public states (loading/disabled) are driven by their real constructor
    // flags. Hover/pressed/focus are handled internally by RemixButton and
    // are inherently transient, so verify them interactively in the running
    // app instead (hover/hold/tab-focus any enabled button below).
    statesBuilder: () => const [
      DsButton(label: 'enabled', onPressed: _noop),
      DsButton(label: 'disabled', onPressed: null, enabled: false),
      DsButton(label: 'loading', onPressed: _noop, loading: true),
      DsButton(
        label: 'with leading',
        onPressed: _noop,
        leadingIcon: Icons.add,
      ),
      DsButton(
        label: 'with trailing',
        onPressed: _noop,
        trailingIcon: Icons.arrow_forward,
      ),
    ],
  );
}

void _noop() {}
