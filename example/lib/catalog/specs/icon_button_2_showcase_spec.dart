import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildIconButton2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Icon Button 2',
    variantsBuilder: () => DsIconButtonVariant.values
        .map(
          (variant) => DsIconButton(
            icon: PhosphorIcons.heart(),
            variant: variant,
            onPressed: _noop,
          ),
        )
        .toList(),
    sizesBuilder: () => DsIconButtonSize.values
        .map(
          (size) => DsIconButton(
            icon: PhosphorIcons.heart(),
            size: size,
            onPressed: _noop,
          ),
        )
        .toList(),
    // Public states (loading/disabled) are driven by their real constructor
    // flags. Hover/pressed/focus are handled internally by RemixIconButton
    // and are inherently transient, so verify them interactively in the
    // running app instead (hover/hold/tab-focus any enabled button below).
    statesBuilder: () => [
      DsIconButton(icon: PhosphorIcons.heart(), onPressed: _noop),
      DsIconButton(
        icon: PhosphorIcons.heart(),
        onPressed: null,
        enabled: false,
      ),
      DsIconButton(
        icon: PhosphorIcons.heart(),
        onPressed: _noop,
        loading: true,
      ),
    ],
  );
}

void _noop() {}
