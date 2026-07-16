import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'notification_2_variants.dart';

// The `resolveDsNotification*` functions consumed by `build()` below live
// in notification_2_style_resolver.dart, split out as `part of` this
// library (not a separate import) so they stay private to DsNotification
// while living in their own file — same split as `DsButton`'s
// `button_2_style_resolver.dart`.
part 'notification_2_style_resolver.dart';

/// A content block combining an optional leading visual, an optional
/// title, mandatory body text, and an optional trailing-aligned action
/// row — e.g. an inline alert or notification card.
///
/// Unlike [DsCallout] (built on `remix`'s `RemixCallout`, which only lays
/// out a flat `[icon, text]` row), [DsNotification] is hand-rolled on top
/// of Mix's [Box] plus plain [Row]/[Column]: `RemixCalloutSpec` has no
/// title or actions slot, so extending it would mean bypassing its
/// built-in icon/text rendering anyway. [DsCallout] itself is untouched —
/// this is a new, separate component, not a replacement.
///
/// No interaction states (hover/press/focus/disabled) to resolve — like
/// [DsCallout], this only varies along [variant] (semantic color
/// treatment) and [size]. No `child` escape hatch either: [text] is always
/// required and always rendered.
class DsNotification extends StatelessWidget {
  const DsNotification({
    super.key,
    this.leading,
    this.title,
    required this.text,
    this.actions,
    this.variant = DsNotificationVariant.neutral,
    this.size = DsNotificationSize.md,
    this.style,
    this.titleStyle,
    this.textStyle,
  });

  /// Leading visual, top-aligned with the title/text column. A caller-built
  /// widget (typically [Icon] or [IconContainer]) rather than an
  /// `IconData` — the caller decides whether it renders as a bare glyph or
  /// a background-square icon container.
  final Widget? leading;

  /// Optional heading, rendered above [text].
  final String? title;

  /// Body message. Always required and always rendered.
  final String text;

  /// Optional action widgets (typically [DsButton]s), rendered in a
  /// trailing-aligned row below [text].
  final List<Widget>? actions;

  /// Semantic color treatment — see [DsNotificationVariant].
  final DsNotificationVariant variant;

  /// Physical size — see [DsNotificationSize].
  final DsNotificationSize size;

  /// Escape hatch merged onto the resolved container style.
  final BoxStyler? style;

  /// Escape hatch merged onto the resolved title text style.
  final TextStyler? titleStyle;

  /// Escape hatch merged onto the resolved body text style.
  final TextStyler? textStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedContainerStyle = resolveDsNotificationContainerStyle(
      variant: variant,
      size: size,
    ).merge(style);

    final resolvedTitleStyle = resolveDsNotificationTitleStyle(
      variant: variant,
      size: size,
    ).merge(titleStyle);

    final resolvedTextStyle = resolveDsNotificationTextStyle(
      variant: variant,
      size: size,
    ).merge(textStyle);

    final gap = resolveDsNotificationGap(context, size);
    final hasActions = actions != null && actions!.isNotEmpty;

    return Box(
      style: resolvedContainerStyle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: AppSpacing.sp020),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  StyledText(title!, style: resolvedTitleStyle),
                  SizedBox(height: gap), // ERROR: doesn't work
                ],
                StyledText(text, style: resolvedTextStyle),
                if (hasActions) ...[
                  SizedBox(height: gap), // ERROR: doesn't work
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: gap, // ERROR: doesn't work
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
