import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'badge_2_variants.dart';

// The `resolveDsBadgeStyle` function consumed by `build()` below lives in
// badge_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsBadge while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'badge_2_style_resolver.dart';

/// A small status/label pill built on top of the `remix` package's
/// [RemixBadge], styled through the design system's Mix semantic tokens.
///
/// Unlike [DsBadge]'s closest sibling, [DsButton], this widget is always
/// non-interactive — it has no `onPressed` and derives no pressed/hover/
/// focus state. It exists purely to label or annotate other content
/// (status pills, counts, tags), matching how legacy `Badge` was a plain
/// `Container`/`Row` rather than a button. See
/// `docs/superpowers/specs/2026-07-15-badge-2-component-design.md`.
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.variant = DsBadgeVariant.primary,
    this.size = DsBadgeSize.md,
    this.style = const RemixBadgeStyle.create(),
    this.styleSpec,
  });

  /// The badge's text content. Always shown.
  final String label;

  /// Widget shown before [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent.
  final Widget? leading;

  /// Widget shown after [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent.
  final Widget? trailing;

  /// Visual treatment — see [DsBadgeVariant].
  final DsBadgeVariant variant;

  /// Physical size — see [DsBadgeSize].
  final DsBadgeSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsBadgeStyle]'s output). Replaces
  /// legacy `Badge`'s dedicated `backgroundColor`/`foregroundColor`
  /// params — same convention as [DsButton.style]/[DsSwitch.style]
  /// (`RemixBadgeStyle().backgroundColor(...)`/`.foregroundColor(...)`
  /// cover the same cases).
  final RemixBadgeStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixBadgeSpec] directly, bypassing style resolution entirely.
  ///
  /// Typed `StyleSpec<RemixBadgeSpec>?` (not `RemixBadgeSpec?`): unlike
  /// [DsButton]/[DsSwitch]'s underlying `RemixButton`/`RemixSwitch` (plain
  /// `StatelessWidget`s with a bare `RemixButtonSpec?`/`RemixSwitchSpec?`
  /// field), `RemixBadge` extends Mix's `StyleWidget<RemixBadgeSpec>`,
  /// whose inherited `styleSpec` param is `StyleSpec<RemixBadgeSpec>?`.
  final StyleSpec<RemixBadgeSpec>? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsBadgeStyle(
      variant: variant,
      size: size,
    ).merge(style);

    return RemixBadge(
      label: label,
      style: resolvedStyle,
      styleSpec: styleSpec,
      labelBuilder: (leading == null && trailing == null)
          ? null
          : (context, spec, resolvedLabel) => _buildLabelWithIcons(
                spec: spec,
                label: resolvedLabel,
                leading: leading,
                trailing: trailing,
                size: size,
              ),
    );
  }
}

/// Builds [DsBadge]'s label content flanked by [leading]/[trailing] icon
/// slots, using the resolved [TextSpec]'s [TextSpec.style] for the text
/// run so the label matches [resolveDsBadgeStyle]'s size/variant text
/// styling exactly. Only invoked by [DsBadge.build] when at least one of
/// [leading]/[trailing] is non-null — ports legacy `Badge`'s icon-flanked
/// `Row` build.
Widget _buildLabelWithIcons({
  required TextSpec spec,
  required String label,
  required Widget? leading,
  required Widget? trailing,
  required DsBadgeSize size,
}) {
  final iconExtent = _iconExtentFor(size);
  final iconGap = _iconGapFor(size);

  // `FittedBox` is required, not cosmetic: a caller-supplied `leading`/
  // `trailing` (typically icon_2's `Icon`) paints its glyph at its own
  // configured font size regardless of the `SizedBox`'s layout
  // constraints — `SizedBox` alone clamps the layout box to [iconExtent]
  // but doesn't rescale the glyph, so an icon larger than [iconExtent]
  // (e.g. `DsIconSize.md`'s default 20px against a `sm`/`md` badge's
  // 10-12px extent) overflows the box and visually crowds/overlaps the
  // gap and label instead of shrinking to fit.
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[
        SizedBox(
          width: iconExtent,
          height: iconExtent,
          child: FittedBox(fit: BoxFit.contain, child: leading),
        ),
        SizedBox(width: iconGap),
      ],
      Text(label, style: spec.style),
      if (trailing != null) ...[
        SizedBox(width: iconGap),
        SizedBox(
          width: iconExtent,
          height: iconExtent,
          child: FittedBox(fit: BoxFit.contain, child: trailing),
        ),
      ],
    ],
  );
}

/// Icon slot extent per [DsBadgeSize] — kept as plain `double` literals
/// (not Mix tokens) since icon sizing isn't part of [RemixBadgeStyle]'s
/// schema (`container`/`text` only), same reasoning legacy `Badge`'s
/// `_resolveIconExtent` already establishes.
double _iconExtentFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 10,
      DsBadgeSize.md => 12,
      DsBadgeSize.lg => 14,
    };

/// Icon-to-label gap per [DsBadgeSize] — ports legacy `Badge`'s
/// `_resolveIconGap` values.
double _iconGapFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 4,
      DsBadgeSize.md => 4,
      DsBadgeSize.lg => 6,
    };
