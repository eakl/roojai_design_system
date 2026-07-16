import 'package:flutter/widgets.dart';

import '../../tokens/semantic/spacing.dart';
import '../toggle_2/toggle_2.dart';
import '../toggle_2/toggle_2_variants.dart';
import 'toggle_group_2_item.dart';
import 'toggle_group_2_orientation.dart';

// The `_resolve*` functions consumed by `build()` below live in
// toggle_group_2_style_resolver.dart, split out as `part of` this library
// (not a separate import) so they stay private to DsToggleGroup while
// living in their own file — same split as `DsToggle`'s
// `toggle_2_style_resolver.dart`.
part 'toggle_group_2_style_resolver.dart';

/// A set of related [DsToggle]s that share single- or multiple-selection
/// logic (e.g. text alignment, or a multi-select filter row) — Flutter's
/// counterpart to shadcn/ui's `ToggleGroup`.
///
/// Built by composing real [DsToggle] widgets rather than reimplementing
/// their visuals — the same "rebuild the single component at shared props"
/// approach the legacy `ToggleGroup` uses for `Toggle`. There is no
/// `RemixToggleGroup` in the currently pinned `remix` package version to
/// delegate to (unlike [DsButton]/[DsInput]/[DsToggle], which wrap a real
/// Remix widget), so this `_2` component instead rebuilds on top of
/// [DsToggle], the `_2` toggle building block, mirroring the legacy
/// `ToggleGroup`'s own composition shape.
///
/// Fully controlled, like [DsToggle] itself: this widget holds no selection
/// state of its own. [selectedValues] always reflects the caller's state,
/// and every tap is reported through [onSelectedValuesChanged] rather than
/// applied internally — see [_handleItemChange].
class DsToggleGroup extends StatelessWidget {
  const DsToggleGroup({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
    this.multiple = false,
    this.orientation = DsToggleGroupOrientation.horizontal,
    this.variant = DsToggleVariant.ghost,
    this.size = DsToggleSize.md,
    this.enabled = true,
  });

  /// The items to render, in display order. Each is rebuilt as a
  /// [DsToggle] sharing this group's [variant]/[size] — an individual
  /// entry carries no visual overrides of its own, only content and
  /// [DsToggleGroupItem.disabled] (see [DsToggleGroupItem]).
  final List<DsToggleGroupItem> items;

  /// The [DsToggleGroupItem.value]s currently selected. Always reflects
  /// the caller's state — this widget holds no internal selection state,
  /// the same contract as [DsToggle.selected].
  final Set<String> selectedValues;

  /// Called with the next full selection whenever an item is tapped.
  /// [multiple] governs how a single tap transforms the selection — see
  /// [_handleItemChange].
  final ValueChanged<Set<String>> onSelectedValuesChanged;

  /// When false (the default), pressing an item replaces the whole
  /// selection with just that item — shadcn/ui's `type="single"`. When
  /// true, items are selected and unselected independently of one another
  /// — shadcn/ui's `type="multiple"`.
  final bool multiple;

  /// Layout axis for the group — see [DsToggleGroupOrientation].
  final DsToggleGroupOrientation orientation;

  /// Visual treatment applied uniformly to every item — see
  /// [DsToggleVariant].
  final DsToggleVariant variant;

  /// Physical size applied uniformly to every item — see [DsToggleSize].
  final DsToggleSize size;

  /// Public state: renders every item muted/non-tappable when false,
  /// regardless of each item's own [DsToggleGroupItem.disabled]. Never
  /// inferred — always driven by this constructor param, mirroring
  /// [DsToggle.enabled].
  final bool enabled;

  /// Resolves the next selection for tapping [value] to [nowSelected].
  ///
  /// Single mode (`multiple: false`) mirrors a radio group: selecting an
  /// unselected item selects only it, and selecting the already-selected
  /// item again clears the selection rather than leaving it stuck on —
  /// matching shadcn/ui, where a single-type toggle group is deselectable.
  /// Multiple mode adds or removes [value] from the existing selection
  /// without touching any other item.
  void _handleItemChange(String value, bool nowSelected) {
    if (!multiple) {
      onSelectedValuesChanged(nowSelected ? {value} : const <String>{});
      return;
    }
    final next = Set<String>.from(selectedValues);
    nowSelected ? next.add(value) : next.remove(value);
    onSelectedValuesChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    // --- Resolved properties -------------------------------------------
    final gap = _resolveGap(context, size);

    // --- Layout ---------------------------------------------------------
    // `Wrap` (rather than `Row`/`Column`) so a group with many items still
    // reflows instead of overflowing when the orientation runs out of
    // space — `spacing` covers the main axis, `runSpacing` the cross axis
    // if it ever wraps to a second line.
    return Wrap(
      direction: orientation == DsToggleGroupOrientation.horizontal
          ? Axis.horizontal
          : Axis.vertical,
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final item in items)
          DsToggle(
            key: ValueKey(item.value),
            selected: selectedValues.contains(item.value),
            onChanged: (enabled && !item.disabled)
                ? (nowSelected) => _handleItemChange(item.value, nowSelected)
                : null,
            label: item.label,
            icon: item.icon,
            variant: variant,
            size: size,
            enabled: enabled && !item.disabled,
          ),
      ],
    );
  }
}
