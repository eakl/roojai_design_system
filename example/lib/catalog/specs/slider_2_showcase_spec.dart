import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSlider2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Slider 2',
    sizesBuilder: () => DsSliderSize.values
        .map(
          (size) => SizedBox(
            width: 240,
            child: DsSlider(
              value: 0.5,
              onChanged: (_) {},
              size: size,
            ),
          ),
        )
        .toList(),
    // Public state (enabled/disabled) is driven by the real `enabled`
    // constructor flag. Drag/focus-visible states are transient and
    // Naked-driven, so verify them interactively in the running catalog
    // app instead (drag any enabled slider below).
    statesBuilder: () => [
      SizedBox(
        width: 240,
        child: DsSlider(value: 0.25, onChanged: (_) {}),
      ),
      SizedBox(
        width: 240,
        child: DsSlider(value: 0.75, onChanged: (_) {}),
      ),
      const SizedBox(
        width: 240,
        child: DsSlider(value: 0.5, onChanged: null, enabled: false),
      ),
      SizedBox(
        width: 240,
        child: DsSlider(value: 0.0, onChanged: (_) {}),
      ),
      SizedBox(
        width: 240,
        child: DsSlider(value: 1.0, onChanged: (_) {}),
      ),
      SizedBox(
        width: 240,
        child: DsSlider(value: 0.5, onChanged: (_) {}, snapDivisions: 4),
      ),
    ],
  );
}
