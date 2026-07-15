import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import 'separator_2_orientation.dart';

part 'separator_2_style_resolver.dart';


class DsSeparator extends StatelessWidget {
  const DsSeparator({
    super.key,
    this.orientation = DsSeparatorOrientation.horizontal,
    this.length = 100,
    this.style = const RemixDividerStyle.create(),
    this.styleSpec,
  }) : assert(
         length > 0 && length <= 100,
         'length is a percentage of the available space and must be in '
         'the range (0, 100].',
       );

  /// Which axis the line is drawn along — see [DsSeparatorOrientation].
  final DsSeparatorOrientation orientation;

  /// How much of the available space (as a percentage, 0 exclusive to 100
  /// inclusive) the line spans along [orientation]'s axis. Defaults to
  /// 100, i.e. the full width (horizontal) or full height (vertical) of
  /// whatever bounded space the parent provides — matching the legacy
  /// `Separator`'s full-bleed default.
  final double length;

  /// Escape hatch merged on top of [resolveDsSeparatorStyle]'s output —
  /// same convention as [DsToggle.style].
  final RemixDividerStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixDividerSpec] directly, bypassing style resolution entirely —
  /// same convention as [DsToggle.styleSpec]. Unlike [RemixToggle]
  /// (a [StatelessWidget] with its own `RemixToggleSpec?` field),
  /// [RemixDivider] extends Mix's `StyleWidget` directly, so this takes
  /// the wrapped `StyleSpec<RemixDividerSpec>?` its `styleSpec` field
  /// actually expects.
  final StyleSpec<RemixDividerSpec>? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSeparatorStyle(
      orientation: orientation,
    ).merge(style);
    final isHorizontal = orientation == DsSeparatorOrientation.horizontal;
    final lengthFactor = length / 100;

    return FractionallySizedBox(
      widthFactor: isHorizontal ? lengthFactor : null,
      heightFactor: isHorizontal ? null : lengthFactor,
      child: RemixDivider(style: resolvedStyle, styleSpec: styleSpec),
    );
  }
}
