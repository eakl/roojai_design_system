import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'list_2_variants.dart';

part 'list_item_2_style_resolver.dart';

class DsListItem extends StatelessWidget {
  const DsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.size = DsListSize.md,
    this.enabled = true,
    this.onTap,
  });

  /// Primary text, always shown.
  final String title;

  /// Optional secondary text shown below [title].
  final String? subtitle;

  /// Optional leading slot — icon, `DsAvatar`, or any other widget.
  final Widget? leading;

  /// Optional trailing slot — icon, badge, switch, or any other widget.
  final Widget? trailing;

  /// Physical size — see [DsListSize]. Controls row padding and
  /// title/subtitle text scale. Applied per-item since each [DsListItem]
  /// is an independent sibling — callers composing a [DsList] should pass
  /// the same [size] to each item and to the list itself, same convention
  /// as `DsTabsSize`/`DsTab.size`.
  final DsListSize size;

  /// Public state: renders muted and suppresses [onTap] when false. Never
  /// inferred — always driven by this constructor param, same convention
  /// as [DsIconButton.enabled].
  final bool enabled;

  /// Called on tap. When null, the row renders as a static (non-pressable)
  /// row. Ignored while [enabled] is false.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onTap != null;
    final resolved = resolveDsListItemStyle(
      size: size,
      disabled: !enabled,
      interactive: interactive,
    );

    // A per-size, fixed gap between leading/title-block/trailing — not a
    // separately requested axis, so it isn't its own field, just derived
    // from `size` alongside the row's own padding.
    final iconGap = switch (size) {
      DsListSize.none => $spacing008.resolve(context),
      DsListSize.sm => $spacing008.resolve(context),
      DsListSize.md => $spacing008.resolve(context),
      DsListSize.lg => $spacing012.resolve(context),
    };

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, SizedBox(width: iconGap)],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(title, style: resolved.title),
              if (subtitle != null)
                StyledText(subtitle!, style: resolved.subtitle),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: iconGap), trailing!],
      ],
    );

    if (!interactive) {
      return Box(style: resolved.container, child: content);
    }

    return PressableBox(
      style: resolved.container,
      onPress: onTap,
      enabled: enabled,
      child: content,
    );
  }
}
