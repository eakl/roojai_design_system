import 'package:flutter/widgets.dart';

/// Declarative description of a single item in a [ToggleGroup].
///
/// `ToggleGroup` rebuilds each entry as a real `Toggle` at the group's
/// shared `variant`/`size` — the same "rebuild the single component at
/// uniform shared props" approach `AvatarGroup` uses for `Avatar`. An item
/// therefore carries only its own content and per-item [disabled] flag,
/// never its own visual treatment.
class ToggleGroupItem {
  const ToggleGroupItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.disabled = false,
  });

  /// Stable identifier used for selection — this is what appears in
  /// [ToggleGroup.selectedValues], rather than a positional index, so a
  /// caller's selection survives [ToggleGroup.items] being reordered or
  /// filtered between builds.
  final String value;

  /// The item's text content — passed straight through to `Toggle.label`.
  final String label;

  /// Optional widget shown before [label] — passed straight through to
  /// `Toggle.leading`.
  final Widget? leading;

  /// Optional widget shown after [label] — passed straight through to
  /// `Toggle.trailing`.
  final Widget? trailing;

  /// Disables just this item. Independent of [ToggleGroup.disabled], which
  /// disables every item at once — an item is non-interactive if *either*
  /// is true.
  final bool disabled;
}
