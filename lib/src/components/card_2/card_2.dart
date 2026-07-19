import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import 'card_2_variants.dart';

// The `resolveDsCardStyle` function consumed by `build()` below lives in
// card_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsCard while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'card_2_style_resolver.dart';

/// A versatile container for grouping related content, built on top of the
/// `remix` package's [RemixCard], styled through the design system's Mix
/// semantic tokens.
///
/// Unlike [DsButton]/[DsInput], there is no legacy hand-rolled `Card` this
/// replaces — this is a new component, same situation as [DsDialog]. It has
/// no interaction states (hover/press/focus/disabled) to resolve — it only
/// varies along [variant] (surface treatment) and [size] (padding).
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    this.child,
    this.variant = DsCardVariant.base,
    this.size = DsCardSize.md,
    this.style = const RemixCardStyler.create(),
    this.styleSpec,
  });

  /// The widget below this widget in the tree. Non-interactive container
  /// — same single-child constraint as [RemixCard] itself.
  final Widget? child;

  /// Visual treatment — see [DsCardVariant].
  final DsCardVariant variant;

  /// Physical size — see [DsCardSize]. Controls padding only; unlike
  /// [DsButton]/[DsInput], a card has no intrinsic height to vary.
  final DsCardSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsCardStyle]'s output).
  final RemixCardStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixCardSpec] directly, bypassing style resolution entirely.
  final RemixCardSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCardStyle(
      variant: variant,
      size: size,
    ).merge(style);

    // `RemixCardSpec` only exposes a `container` (Box) slot — no text/icon
    // slot of its own (`child` is rendered as-is by `RemixCard`) — so a
    // `child` that doesn't explicitly color itself would inherit whatever
    // ambient `DefaultTextStyle`/`IconTheme` happens to be above it, which
    // is wrong (e.g. black text) on `inverted`'s dark background. Wrapping
    // here pushes the right color down ambiently, same pattern
    // `InputGroupAddon` uses to color a plain `Text` child.
    final foregroundColor = _resolveDsCardForegroundColor(variant);
    final styledChild = child == null
        ? null
        : DefaultTextStyle.merge(
            style: TextStyle(color: foregroundColor),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: child!,
            ),
          );

    return RemixCard(
      style: resolvedStyle,
      styleSpec: styleSpec,
      child: styledChild,
    );
  }
}
