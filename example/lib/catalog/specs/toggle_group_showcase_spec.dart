import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Shared item set for the alignment-style demos below (single-select).
const _alignItems = [
  ToggleGroupItem(value: 'left', label: 'Left'),
  ToggleGroupItem(value: 'center', label: 'Center'),
  ToggleGroupItem(value: 'right', label: 'Right'),
];

/// Shared item set for the formatting-style demos below (multi-select).
const _formatItems = [
  ToggleGroupItem(value: 'bold', label: 'Bold'),
  ToggleGroupItem(value: 'italic', label: 'Italic'),
  ToggleGroupItem(value: 'underline', label: 'Underline'),
];

ComponentShowcaseSpec buildToggleGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle Group',
    // Each entry is backed by local state (`_InteractiveToggleGroup` below)
    // so tapping it in the running app actually changes the selection —
    // same rationale as ToggleShowcaseSpec's `_InteractiveToggle`: wiring
    // `onSelectedValuesChanged` to a no-op here would make tapping look
    // broken instead of demonstrating the real controlled behavior.
    variantsBuilder: () => const [
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        variant: ToggleVariant.standard,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        variant: ToggleVariant.outline,
      ),
    ],
    sizesBuilder: () => const [
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: ToggleSize.sm,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: ToggleSize.md,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: ToggleSize.lg,
      ),
    ],
    statesBuilder: () => const [
      // Single-select: exactly one (or zero) item pressed at a time, and
      // pressing the selected item again clears it — shadcn's
      // `type="single"`.
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'center'},
      ),
      // Multiple-select: any number of items pressed independently —
      // shadcn's `type="multiple"`.
      _InteractiveToggleGroup(
        items: _formatItems,
        initialSelectedValues: {'bold', 'underline'},
        multiple: true,
      ),
      // Vertical orientation — items stack top-to-bottom instead of
      // left-to-right.
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        orientation: ToggleGroupOrientation.vertical,
      ),
      // Disabled at the group level: every item is muted and non-tappable
      // regardless of the (still-honored) selection it's showing.
      ToggleGroup(
        items: _alignItems,
        selectedValues: {'left'},
        onSelectedValuesChanged: _noop,
        disabled: true,
      ),
    ],
  );
}

void _noop(Set<String> _) {}

class _InteractiveToggleGroup extends StatefulWidget {
  const _InteractiveToggleGroup({
    required this.items,
    required this.initialSelectedValues,
    this.multiple = false,
    this.orientation = ToggleGroupOrientation.horizontal,
    this.variant = ToggleVariant.standard,
    this.size = ToggleSize.md,
  });

  final List<ToggleGroupItem> items;
  final Set<String> initialSelectedValues;
  final bool multiple;
  final ToggleGroupOrientation orientation;
  final ToggleVariant variant;
  final ToggleSize size;

  @override
  State<_InteractiveToggleGroup> createState() =>
      _InteractiveToggleGroupState();
}

class _InteractiveToggleGroupState extends State<_InteractiveToggleGroup> {
  late Set<String> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = widget.initialSelectedValues;
  }

  @override
  Widget build(BuildContext context) {
    return ToggleGroup(
      items: widget.items,
      selectedValues: _selectedValues,
      onSelectedValuesChanged: (next) => setState(() => _selectedValues = next),
      multiple: widget.multiple,
      orientation: widget.orientation,
      variant: widget.variant,
      size: widget.size,
    );
  }
}
