import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Shared item set for the alignment-style demos below (single-select).
const _alignItems = [
  DsToggleGroupItem(value: 'left', label: 'Left'),
  DsToggleGroupItem(value: 'center', label: 'Center'),
  DsToggleGroupItem(value: 'right', label: 'Right'),
];

/// Shared item set for the formatting-style demos below (multi-select).
const _formatItems = [
  DsToggleGroupItem(value: 'bold', label: 'Bold'),
  DsToggleGroupItem(value: 'italic', label: 'Italic'),
  DsToggleGroupItem(value: 'underline', label: 'Underline'),
];

ComponentShowcaseSpec buildToggleGroup2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle Group 2',
    // Each entry is backed by local state (`_InteractiveToggleGroup` below)
    // so tapping it in the running app actually changes the selection —
    // same rationale as Toggle2ShowcaseSpec's `_InteractiveToggle`: wiring
    // `onSelectedValuesChanged` to a no-op here would make tapping look
    // broken instead of demonstrating the real controlled behavior.
    variantsBuilder: () => const [
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        variant: DsToggleVariant.ghost,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        variant: DsToggleVariant.outline,
      ),
    ],
    sizesBuilder: () => const [
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: DsToggleSize.sm,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: DsToggleSize.md,
      ),
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'left'},
        size: DsToggleSize.lg,
      ),
    ],
    statesBuilder: () => const [
      // Single-select: exactly one (or zero) item selected at a time, and
      // selecting the selected item again clears it — shadcn's
      // `type="single"`.
      _InteractiveToggleGroup(
        items: _alignItems,
        initialSelectedValues: {'center'},
      ),
      // Multiple-select: any number of items selected independently —
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
        orientation: DsToggleGroupOrientation.vertical,
      ),
      // Disabled at the group level: every item is muted and non-tappable
      // regardless of the (still-honored) selection it's showing.
      DsToggleGroup(
        items: _alignItems,
        selectedValues: {'left'},
        onSelectedValuesChanged: _noop,
        enabled: false,
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
    this.orientation = DsToggleGroupOrientation.horizontal,
    this.variant = DsToggleVariant.ghost,
    this.size = DsToggleSize.md,
  });

  final List<DsToggleGroupItem> items;
  final Set<String> initialSelectedValues;
  final bool multiple;
  final DsToggleGroupOrientation orientation;
  final DsToggleVariant variant;
  final DsToggleSize size;

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
    return DsToggleGroup(
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
