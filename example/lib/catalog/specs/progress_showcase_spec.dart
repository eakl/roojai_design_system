import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildProgressShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Progress',
    sizesBuilder: () =>
        ProgressSize.values.map((size) => Progress(percent: 60, size: size)).toList(),
    // Bare percent values (no label/value annotations), custom track/
    // indicator colors, the single label/value header, and the min/max
    // label/value mode — shown together since none of them fit neatly
    // under "variant" the way Button/Badge's states do.
    statesBuilder: () => const [
      Progress(percent: 0),
      Progress(percent: 45),
      Progress(percent: 100),
      Progress(
        percent: 55,
        trackColor: Color(0xFFE0E7FF),
        indicatorColor: Color(0xFF4338CA),
      ),
      Progress(
        percent: 72,
        label: 'Uploading',
        value: '72%',
      ),
      Progress(
        percent: 40,
        minLabel: 'Min',
        minValue: '0',
        maxLabel: 'Max',
        maxValue: '100',
      ),
    ],
  );
}
