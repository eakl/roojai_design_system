import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// [Separator.length] resolves as a percentage of the *bounded* space its
/// parent offers along [Separator.orientation]'s axis (see the doc on
/// `Separator`) — the generic showcase page lays sections out in a `Wrap`,
/// which gives children unbounded constraints. Every entry below supplies
/// that bound explicitly via a fixed-size `SizedBox`, the same way a real
/// caller would size the space a Separator sits in (e.g. a sidebar's
/// width, a toolbar row's height).
const double _horizontalContainerWidth = 160;
const double _verticalContainerHeight = 48;

ComponentShowcaseSpec buildSeparatorShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Separator',
    // Orientation is the "variant" axis: one horizontal, one vertical,
    // both at the default 100% length.
    variantsBuilder: () => const [
      SizedBox(
        width: _horizontalContainerWidth,
        child: Separator(),
      ),
      SizedBox(
        height: _verticalContainerHeight,
        child: Separator(orientation: SeparatorOrientation.vertical),
      ),
    ],
    // Length is the other independent axis this component exposes —
    // shown as ascending percentages of the same fixed-width container so
    // the shrinking line length is directly comparable.
    sizesBuilder: () => const [
      SizedBox(
        width: _horizontalContainerWidth,
        child: Separator(length: 25),
      ),
      SizedBox(
        width: _horizontalContainerWidth,
        child: Separator(length: 50),
      ),
      SizedBox(
        width: _horizontalContainerWidth,
        child: Separator(length: 75),
      ),
      SizedBox(
        width: _horizontalContainerWidth,
        child: Separator(length: 100),
      ),
    ],
  );
}
