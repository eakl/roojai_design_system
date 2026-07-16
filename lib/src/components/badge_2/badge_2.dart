import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'badge_2_variants.dart';

class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.variant = DsBadgeVariant.primary,
    this.size = DsBadgeSize.md,
    this.style = const RemixBadgeStyler.create(),
    this.styleSpec,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final DsBadgeVariant variant;
  final DsBadgeSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsBadgeStyle]'s output). Replaces
  /// legacy `Badge`'s dedicated `backgroundColor`/`foregroundColor`
  /// params — same convention as [DsButton.style]/[DsSwitch.style]
  /// (`RemixBadgeStyler().backgroundColor(...)`/`.foregroundColor(...)`
  /// cover the same cases).
  final RemixBadgeStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixBadgeSpec] directly, bypassing style resolution entirely —
  /// same convention as [DsButton]/[DsSwitch]'s underlying
  /// `RemixButton`/`RemixSwitch` (plain `StatelessWidget`s with a bare
  /// `RemixButtonSpec?`/`RemixSwitchSpec?` field).
  final RemixBadgeSpec? styleSpec;

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
          : (context, spec, resolvedLabel) =>
              _buildLabelWithIcons(spec, resolvedLabel),
    );
  }

  /// Builds the label content flanked by [leading]/[trailing] icon slots,
  /// using the resolved [TextSpec]'s [TextSpec.style] for the text run so
  /// the label matches [resolveDsBadgeStyle]'s size/variant text styling
  /// exactly. Only invoked by [build] when at least one of [leading]/
  /// [trailing] is non-null — ports legacy `Badge`'s icon-flanked `Row`
  /// build.
  Widget _buildLabelWithIcons(TextSpec spec, String label) {
    final iconExtent = resolveIconSize(size);
    final iconGap = resolveIconToLabelGap(size);

    // `FittedBox` is required, not cosmetic: a caller-supplied `leading`/
    // `trailing` (typically icon_2's `Icon`) paints its glyph at its own
    // configured font size regardless of the `SizedBox`'s layout
    // constraints — `SizedBox` alone clamps the layout box to
    // [iconExtent] but doesn't rescale the glyph, so an icon larger than
    // [iconExtent] (e.g. `DsIconSize.md`'s default 20px against a
    // `sm`/`md` badge's 10-12px extent) overflows the box and visually
    // crowds/overlaps the gap and label instead of shrinking to fit.
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
}
