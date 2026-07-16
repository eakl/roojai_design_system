import 'package:flutter/widgets.dart';

/// Declarative description of a single item in a [DsToggleGroup].
///
/// `DsToggleGroup` rebuilds each entry as a real [DsToggle] at the group's
/// shared `variant`/`size` — the same "rebuild the single component at
/// uniform shared props" approach the legacy `ToggleGroup` uses for
/// `Toggle`. An item therefore carries only its own content and per-item
/// [disabled] flag, never its own visual treatment.
///
/// Mirrors [DsToggle]'s single-icon-slot contract (rather than the legacy
/// `ToggleGroupItem`'s `leading`/`trailing` widget pair): at least one of
/// [label]/[icon] must be provided.
class DsToggleGroupItem {
  const DsToggleGroupItem({
    required this.value,
    this.label,
    this.icon,
    this.disabled = false,
  }) : assert(
         label != null || icon != null,
         'At least one of label or icon must be provided',
       );

  /// Stable identifier used for selection — this is what appears in
  /// [DsToggleGroup.selectedValues], rather than a positional index, so a
  /// caller's selection survives [DsToggleGroup.items] being reordered or
  /// filtered between builds.
  final String value;

  /// The item's text content — passed straight through to `DsToggle.label`.
  final String? label;

  /// The item's icon — passed straight through to `DsToggle.icon`.
  final IconData? icon;

  /// Disables just this item. Independent of [DsToggleGroup.disabled],
  /// which disables every item at once — an item is non-interactive if
  /// *either* is true.
  final bool disabled;
}
