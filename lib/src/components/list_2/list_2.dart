import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import '../separator_2/separator_2.dart';
import 'list_2_variants.dart';

// The `resolveDsListItemStyle`/`resolveDsListStyle` functions consumed by
// `build()` below live in list_2_style_resolver.dart, split out as `part
// of` this library so they stay private to this file's widgets while
// living in their own file — same split as `card_2`'s
// `card_2_style_resolver.dart`. Dart requires a `part of` file's imports to
// be declared in the library file itself, which is why `colors.dart`/
// `spacing.dart`/`typography.dart` are imported here even though only the
// style resolver uses them directly.
part 'list_2_style_resolver.dart';

/// A single row within a [DsList] — an optional leading widget, a title,
/// an optional subtitle, and an optional trailing widget.
///
/// Unlike `card_2`/`label_2`, there is no Remix widget to wrap (no
/// `RemixListItem` exists), so [DsListItem] is a plain `StatelessWidget`
/// built directly on Mix's `Box`/`PressableBox`/`StyledText` primitives —
/// the same approach `label_2` uses for `StyledText`/`TextStyler`.
///
/// [onTap] being non-null (and [enabled] being true) is what makes a row
/// interactive — same "presence of the callback decides interactivity"
/// convention `DsIconButton.onPressed`/`RemixButton.onPressed` already
/// use. A non-interactive row renders as a plain `Box` with no
/// hover/press styling and no button semantics, since it has no tap
/// affordance to show.
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

/// A vertical list container — an optional bordered outline, an optional
/// header [DsListItem] set apart by an unconditional separator, and a
/// body of [children] with size-driven padding/gap and an optional
/// [DsSeparator] between consecutive rows.
///
/// Single widget, not split into a separate "list body" type — the outer
/// container concerns ([bordered], [header]) and the body concerns
/// (padding, gap, [separated]) are all just configuration of the one
/// container, matching `card_2`'s single-widget shape.
class DsList extends StatelessWidget {
  const DsList({
    super.key,
    required this.children,
    this.header,
    this.bordered = false,
    this.separated = false,
    this.size = DsListSize.md,
  });

  /// The rows shown in the list body, in order.
  final List<DsListItem> children;

  /// Optional row shown above the body, visually set apart by an
  /// unconditional separator — independent of [separated].
  final DsListItem? header;

  /// Outer border treatment. `true` draws a `$radius008`/`$borderStrong`
  /// border around the whole container (background stays transparent),
  /// same tokens `card_2`'s `bordered` variant uses. `false` draws
  /// neither — the list sits flush in its parent's surface.
  final bool bordered;

  /// Whether consecutive body rows are separated by a `DsSeparator`
  /// (`separator_2`). Does not affect the header/body divider, which is
  /// always drawn when [header] is set.
  final bool separated;

  /// Physical size — see [DsListSize]. Controls the body's outer padding
  /// and the gap between rows.
  final DsListSize size;

  @override
  Widget build(BuildContext context) {
    final containerStyle = resolveDsListStyle(bordered: bordered, size: size);
    final gap = switch (size) {
      DsListSize.sm => $spacing008.resolve(context),
      DsListSize.md => $spacing012.resolve(context),
      DsListSize.lg => $spacing016.resolve(context),
    };

    final rows = <Widget>[];
    if (header != null) {
      rows.add(header!);
      rows.add(const DsSeparator());
    }
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        if (separated) {
          rows.add(SizedBox(height: gap / 2));
          rows.add(const DsSeparator());
          rows.add(SizedBox(height: gap / 2));
        } else {
          rows.add(SizedBox(height: gap));
        }
      }
      rows.add(children[i]);
    }

    return Box(
      style: containerStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
