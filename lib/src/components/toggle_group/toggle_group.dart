import 'package:flutter/widgets.dart';

import '../../tokens/primitives/app_spacing.dart';
import '../toggle/toggle.dart';
import '../toggle/toggle_size.dart';
import '../toggle/toggle_variant.dart';
import 'toggle_group_item.dart';
import 'toggle_group_orientation.dart';

// The `_resolve*` functions consumed by `build()` below live in
// toggle_group_style_resolvers.dart, split out as `part of` this library
// (not a separate import) so they stay private to ToggleGroup while living
// in their own file — same split as Toggle's `toggle_style_resolvers.dart`.
part 'toggle_group_style_resolvers.dart';

/// A set of related [Toggle]s that share single- or multiple-selection
/// logic (e.g. text alignment, or a multi-select filter row) — Flutter's
/// counterpart to shadcn/ui's `ToggleGroup`.
///
/// Built by composing real `Toggle` widgets rather than reimplementing
/// their visuals — the same "rebuild the single component at shared props"
/// approach `AvatarGroup` uses for `Avatar`. No Material `ToggleButtons` is
/// involved.
///
/// Fully controlled, like [Toggle] itself: this widget holds no selection
/// state of its own. [selectedValues] always reflects the caller's state,
/// and every tap is reported through [onSelectedValuesChanged] rather than
/// applied internally — see [_handleItemChange].
class ToggleGroup extends StatelessWidget {
  const ToggleGroup({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectedValuesChanged,
    this.multiple = false,
    this.orientation = ToggleGroupOrientation.horizontal,
    this.variant = ToggleVariant.standard,
    this.size = ToggleSize.md,
    this.disabled = false,
  });

  /// The items to render, in display order. Each is rebuilt as a `Toggle`
  /// sharing this group's [variant]/[size] — an individual entry carries no
  /// visual overrides of its own, only content and [ToggleGroupItem.disabled]
  /// (see [ToggleGroupItem]).
  final List<ToggleGroupItem> items;

  /// The [ToggleGroupItem.value]s currently pressed. Always reflects the
  /// caller's state — this widget holds no internal selection state, the
  /// same contract as [Toggle.pressed].
  final Set<String> selectedValues;

  /// Called with the next full selection whenever an item is tapped.
  /// [multiple] governs how a single tap transforms the selection — see
  /// [_handleItemChange].
  final ValueChanged<Set<String>> onSelectedValuesChanged;

  /// When false (the default), pressing an item replaces the whole
  /// selection with just that item — shadcn/ui's `type="single"`. When
  /// true, items are pressed and unpressed independently of one another —
  /// shadcn/ui's `type="multiple"`.
  final bool multiple;

  /// Layout axis for the group — see [ToggleGroupOrientation].
  final ToggleGroupOrientation orientation;

  /// Visual treatment applied uniformly to every item — see [ToggleVariant].
  final ToggleVariant variant;

  /// Physical size applied uniformly to every item — see [ToggleSize].
  final ToggleSize size;

  /// Disables every item at once, regardless of each item's own
  /// [ToggleGroupItem.disabled]. Kept as an explicit constructor param,
  /// never inferred, mirroring [Toggle.disabled].
  final bool disabled;

  /// Resolves the next selection for tapping [value] to [nowPressed].
  ///
  /// Single mode (`multiple: false`) mirrors a radio group: pressing an
  /// unpressed item selects only it, and pressing the already-selected item
  /// again clears the selection rather than leaving it stuck on — matching
  /// shadcn/ui, where a single-type toggle group is deselectable. Multiple
  /// mode adds or removes [value] from the existing selection without
  /// touching any other item.
  void _handleItemChange(String value, bool nowPressed) {
    if (!multiple) {
      onSelectedValuesChanged(nowPressed ? {value} : const <String>{});
      return;
    }
    final next = Set<String>.from(selectedValues);
    nowPressed ? next.add(value) : next.remove(value);
    onSelectedValuesChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    // --- Resolved properties -------------------------------------------
    final gap = _resolveGap(size);

    // --- Layout ---------------------------------------------------------
    // `Wrap` (rather than `Row`/`Column`) so a group with many items still
    // reflows instead of overflowing when the orientation runs out of
    // space — `spacing` covers the main axis, `runSpacing` the cross axis
    // if it ever wraps to a second line.
    return Wrap(
      direction: orientation == ToggleGroupOrientation.horizontal
          ? Axis.horizontal
          : Axis.vertical,
      spacing: gap,
      runSpacing: gap,
      children: [
        for (final item in items)
          Toggle(
            key: ValueKey(item.value),
            label: item.label,
            pressed: selectedValues.contains(item.value),
            onPressedChange: (disabled || item.disabled)
                ? null
                : (nowPressed) => _handleItemChange(item.value, nowPressed),
            variant: variant,
            size: size,
            disabled: disabled || item.disabled,
            leading: item.leading,
            trailing: item.trailing,
          ),
      ],
    );
  }
}
