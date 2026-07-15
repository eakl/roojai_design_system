import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSeparator2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Separator 2',
    // No variant or size axis — orientation/length are demonstrated via
    // statesBuilder instead, same no-variant shape skeleton_2's showcase
    // spec uses.
    statesBuilder: () => const [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Line one'),
          SizedBox(height: 8),
          DsSeparator(),
          SizedBox(height: 8),
          Text('Line two'),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Short separator'),
          SizedBox(height: 8),
          DsSeparator(length: 50),
        ],
      ),
      SizedBox(
        height: 24,
        child: Row(
          children: [
            Text('Left'),
            SizedBox(width: 12),
            DsSeparator(orientation: DsSeparatorOrientation.vertical),
            SizedBox(width: 12),
            Text('Right'),
          ],
        ),
      ),
    ],
  );
}
