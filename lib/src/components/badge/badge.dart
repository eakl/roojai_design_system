import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/radius.dart';
import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'badge_size.dart';
import 'badge_variant.dart';

// The `_resolve*` functions consumed by `build()` below live in
// badge_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to Badge while living in their
// own file — same split as Button.
part 'badge_style_resolvers.dart';

/// A small status/label pill built from low-level primitives (`Container`
/// + `BoxDecoration`, no Material `Chip`).
///
/// Unlike [Badge]'s closest sibling, `Button`, this widget is always
/// non-interactive — it has no `onPressed` and derives no pressed/hover/
/// focus state. It exists purely to label or annotate other content
/// (status pills, counts, tags), matching how shadcn's `Badge` is a plain
/// `<span>` rather than a button.
class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.md,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// The badge's text content. Always shown.
  final String label;

  /// Visual treatment — see [BadgeVariant].
  final BadgeVariant variant;

  /// Physical size — see [BadgeSize].
  final BadgeSize size;

  /// Widget shown before [label] (typically an `Icon`), sized to
  /// [BadgeSize]'s icon extent.
  final Widget? leading;

  /// Widget shown after [label] (typically an `Icon`), sized to
  /// [BadgeSize]'s icon extent.
  final Widget? trailing;

  /// Escape hatch to override [variant]'s resolved background color for
  /// one-off cases a semantic variant doesn't cover (e.g. a caller-defined
  /// category color). When null, the color resolved from [variant] is
  /// used. [variant] still governs border presence/shape and padding —
  /// this only replaces the fill.
  final Color? backgroundColor;

  /// Escape hatch to override [variant]'s resolved text/icon color.
  /// Independent of [backgroundColor] — either or both may be supplied.
  /// When null, the color resolved from [variant] is used.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties --------------------------------------------
    // Variant-resolved colors first, then the public overrides (if any)
    // are applied on top — variant always still drives border/shape/
    // padding, only the fill/text color are replaceable.
    final resolvedBackgroundColor =
        backgroundColor ?? _resolveBackgroundColor(colors, variant);
    final resolvedForegroundColor =
        foregroundColor ?? _resolveForegroundColor(colors, variant);
    final borderColor = _resolveBorderColor(colors, variant);
    final textStyle = _resolveTextStyle(typography, size);
    final padding = _resolvePadding(size);
    final iconGap = _resolveIconGap(size);
    final iconExtent = _resolveIconExtent(size);

    // --- Layout -----------------------------------------------------------
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[
          SizedBox(width: iconExtent, height: iconExtent, child: leading),
          SizedBox(width: iconGap),
        ],
        Text(label, style: textStyle.copyWith(color: resolvedForegroundColor)),
        if (trailing != null) ...[
          SizedBox(width: iconGap),
          SizedBox(width: iconExtent, height: iconExtent, child: trailing),
        ],
      ],
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: content,
    );
  }
}
