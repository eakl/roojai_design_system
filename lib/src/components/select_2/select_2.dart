import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'select_2_variants.dart';

// The `resolveDsSelectStyle`/`resolveDsSelectItemStyle` functions consumed by
// `build()` below live in select_2_style_resolver.dart, split out as `part
// of` this library (not a separate import) so they stay private to
// DsSelect while living in their own file — same split as `DsInput`'s
// `input_2_style_resolver.dart`.
part 'select_2_style_resolver.dart';

/// A single-select dropdown built on top of the `remix` package's
/// [RemixSelect], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppSelect` (a `CompositedTransformTarget`/
/// `OverlayEntry` dropdown built from scratch), [DsSelect] delegates all
/// interaction handling (overlay open/close, hover/press/focus, keyboard
/// navigation, semantics) to [RemixSelect] and only supplies a resolved
/// [RemixSelectStyler] — see [resolveDsSelectStyle] — for [size]/[error],
/// plus a resolved [RemixSelectMenuItemStyler] — see
/// [resolveDsSelectItemStyle] — applied to every item before
/// [RemixSelectItem.style] merges on top as a row-level override.
///
/// See `docs/superpowers/specs/2026-07-15-select-2-component-design.md` for
/// the full design rationale.
class DsSelect<T> extends StatelessWidget {
  const DsSelect({
    super.key,
    required this.items,
    this.selectedValue,
    this.placeholder = 'Select…',
    this.leadingIcon,
    this.onChanged,
    this.onOpen,
    this.onClose,
    this.size = DsSelectSize.md,
    this.error = false,
    this.enabled = true,
    this.closeOnSelect = true,
    this.targetAnchor,
    this.followerAnchor,
    this.focusNode,
    this.semanticLabel,
    this.style = const RemixSelectStyler.create(),
  });

  /// The full list of selectable options shown in the dropdown menu, in
  /// display order. Reuses Remix's own [RemixSelectItem] data class
  /// directly rather than a parallel `DsSelectItem` — see the design spec's
  /// "widget API" section for why.
  final List<RemixSelectItem<T>> items;

  /// The currently selected value, or null when nothing is selected yet.
  /// This widget holds no selection state of its own — it always reflects
  /// this value, the same "fully controlled" convention as legacy
  /// `AppSelect.selected`.
  final T? selectedValue;

  /// Shown in the trigger in place of the selected item's label when
  /// [selectedValue] is null.
  final String placeholder;

  /// Optional icon shown at the trigger's leading edge, forwarded to
  /// [RemixSelectTrigger.icon].
  final IconData? leadingIcon;

  /// Called with the newly selected value when the caller picks an item
  /// from the open menu.
  final ValueChanged<T?>? onChanged;

  /// Called when the dropdown menu opens.
  final VoidCallback? onOpen;

  /// Called when the dropdown menu closes.
  final VoidCallback? onClose;

  /// Physical size — see [DsSelectSize]. Drives both the trigger's and the
  /// menu rows' padding/text/icon sizing.
  final DsSelectSize size;

  /// Public state: renders the negative/error border color. Mirrors
  /// [DsInput.error] — this widget doesn't validate [selectedValue] itself,
  /// the caller decides when a value is invalid and passes this flag
  /// explicitly.
  final bool error;

  /// Public state: disables the trigger and suppresses the menu entirely
  /// when false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to automatically close the dropdown when an item is selected.
  final bool closeOnSelect;

  /// The target anchor for the dropdown overlay. Forwarded to
  /// [RemixSelect.positioning]'s `targetAnchor`.
  final Alignment? targetAnchor;

  /// The follower anchor for the dropdown overlay. Forwarded to
  /// [RemixSelect.positioning]'s `followerAnchor`.
  final Alignment? followerAnchor;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixSelect]/`NakedSelect`.
  final FocusNode? focusNode;

  /// Semantic label read by screen readers.
  final String? semanticLabel;

  /// Escape hatch for callers that need to further customize the resolved
  /// trigger/menu style (merged on top of [resolveDsSelectStyle]'s output).
  /// There is no `styleSpec` param here — [DsSelect] only exposes the
  /// fluent styler API, not `RemixSelect`'s raw `styleSpec` bypass.
  final RemixSelectStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSelectStyle(
      size: size,
      error: error,
    ).merge(style);

    final resolvedItemStyle = resolveDsSelectItemStyle(size: size);
    final resolvedItems = [
      for (final item in items)
        RemixSelectItem<T>(
          value: item.value,
          label: item.label,
          enabled: item.enabled,
          semanticLabel: item.semanticLabel,
          style: resolvedItemStyle.merge(item.style),
        ),
    ];

    return RemixSelect<T>(
      trigger: RemixSelectTrigger(placeholder: placeholder, icon: leadingIcon),
      items: resolvedItems,
      selectedValue: selectedValue,
      positioning: OverlayPositionConfig(
        targetAnchor: targetAnchor ?? Alignment.bottomCenter,
        followerAnchor: followerAnchor ?? Alignment.topCenter,
      ),
      onChanged: onChanged,
      onOpen: onOpen,
      onClose: onClose,
      enabled: enabled,
      semanticLabel: semanticLabel,
      closeOnSelect: closeOnSelect,
      focusNode: focusNode,
      style: resolvedStyle,
    );
  }
}
