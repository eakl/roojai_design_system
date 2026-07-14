# Interaction Primitives

> **Purpose.** A catalogue of reusable interaction behaviours that can be composed into components rather than re-implemented inside each one. Each primitive encapsulates one axis of interactivity — state, gesture, focus, keyboard, etc. — and is completely independent of visual styling.

---

## How to read this document

Each section describes one primitive:

- **What it is** — the behaviour it abstracts  
- **Current state** — whether it is already in the codebase (as duplicated inline code), missing entirely, or partially present  
- **Used by (existing)** — components in `lib/src/components/` that already re-implement it  
- **Used by (future)** — shadcn-equivalent components not yet built that will need it  
- **Proposed API sketch** — the minimal Dart surface (mixin / widget / notifier)

---

## 1. `Pressable`

**What it is.** Wraps a child with tap-down / tap-up / tap-cancel gesture detection and exposes a live `isPressed` state for visual feedback (e.g. darkened background on press). Also owns the `MouseRegion` cursor and the `_interactive` gate (`!disabled && onPressed != null`).

**Current state.** Duplicated in `Button` (`_isPressed`) and `Toggle` (`_isTapped`). The handlers, cursor, and `canRequestFocus` logic are identical in both — only the field name differs.

**Used by (existing).**
| Component | Internal state name | Tap-down feedback |
|---|---|---|
| `Button` | `_isPressed` | Yes |
| `Toggle` | `_isTapped` | Yes |
| `AppCheckbox` | — | No (simple tap only) |
| `AppRadio` | — | No |
| `AppSwitch` | — | No |
| `_FileDropTarget` (inside `Input`) | — | No |
| `InputGroupAddon` | — | No |
| `InputGroupButton` | via `Button` | Yes (inherited) |

> `AppCheckbox`, `AppRadio`, `AppSwitch`, `_FileDropTarget`, and `InputGroupAddon` use a simpler **tap-only** variant (no press-down state). `Pressable` should support both modes via a `trackPressState` flag.

**Used by (future).**
`AlertDialog` (close button), `Dialog`, `Drawer` (dismiss button), `DropdownMenu` items, `Pagination` page buttons, `Tabs` triggers, `Toast` dismiss, `ContextMenu` items, `Menubar` items, `NavigationMenu` triggers, `Carousel` nav arrows.

**Proposed API.**
```dart
// Mixin on State<T extends StatefulWidget>
mixin PressableMixin<T extends StatefulWidget> on State<T> {
  bool isPressed = false;

  void handleTapDown(TapDownDetails _) => setState(() => isPressed = true);
  void handleTapUp(TapUpDetails _)     => setState(() => isPressed = false);
  void handleTapCancel()               => setState(() => isPressed = false);
}
```

Or as a builder widget:
```dart
Pressable(
  onTap: widget.onPressed,
  disabled: widget.disabled,
  cursor: SystemMouseCursors.click,
  builder: (context, isPressed) => ...,
)
```

---

## 2. `Focusable`

**What it is.** Manages the `FocusNode` lifecycle: owns and disposes an internal node when the caller supplies none, and swaps nodes in `didUpdateWidget` when the caller starts or stops supplying their own. This pattern is currently copy-pasted verbatim across every interactive component.

**Current state.** Duplicated identically in `Button`, `Toggle`, `AppCheckbox`, `AppRadio`, `AppSwitch`, `AppSlider`, `Input`, `Textarea` — 8 components, 100 % identical structure (own / dispose / swap in `didUpdateWidget`, all with a debug label).

**Used by (existing).** All interactive components listed above.

**Used by (future).** Every future interactive component.

**Proposed API.**
```dart
// Mixin on State<T extends StatefulWidget>
mixin FocusableMixin<T extends StatefulWidget> on State<T> {
  FocusNode? _internalFocusNode;

  // Subclass provides: widget.focusNode, widget.autofocus, debugLabel
  FocusNode? get externalFocusNode;
  String get focusDebugLabel;

  FocusNode get focusNode => externalFocusNode ?? _internalFocusNode!;

  void initFocusNode() { ... }          // call from initState
  void swapFocusNode(FocusNode? old, FocusNode? next) { ... }  // call from didUpdateWidget
  void disposeFocusNode() { ... }       // call from dispose
}
```

---

## 3. `TextEditable`

**What it is.** Extends `Focusable` with a `FocusNode` *listener* that derives a `isFocused` boolean from `focusNode.hasFocus`. The distinction from plain `Focusable` is that text fields need to *react* to focus changes visually (border/ring), not just *hold* a focus node.

**Current state.** Duplicated in `Input` and `Textarea` (`_isFocused`, `_handleFocusChange`, `addListener`/`removeListener` in `initState`/`didUpdateWidget`/`dispose`).

**Used by (existing).** `Input`, `Textarea`, `InputGroupInput`, `InputGroupTextarea`.

**Used by (future).** `InputOTP` (digit inputs), `Combobox` / `Command` search field, `DatePicker` text field.

**Proposed API.**
```dart
mixin TextEditableMixin<T extends StatefulWidget> on FocusableMixin<T> {
  bool isFocused = false;

  void _handleFocusChange() =>
      setState(() => isFocused = focusNode.hasFocus);

  // Override initFocusNode / swapFocusNode / disposeFocusNode
  // to add/remove the listener automatically.
}
```

---

## 4. `DragControl`

**What it is.** Encapsulates a continuous-drag gesture — start / update / end — over one axis (horizontal or vertical), with a `isDragging` flag for cosmetic feedback and a normalised `fraction` (0–1) computed from pointer position relative to a track size. Also handles tap-down as a "jump to position" equivalent.

**Current state.** Implemented inline in `AppSlider` (`_isDragging`, `_handleDragStart/Update/End`, `_handleTapDown`, `_updateFromLocalX`).

**Used by (existing).** `AppSlider`.

**Used by (future).**
| Component | Axis | Use case |
|---|---|---|
| `RangeSlider` | Horizontal | Two-thumb slider |
| `Carousel` | Horizontal | Swipe between slides |
| `Drawer` / `Sheet` | Vertical (or horizontal) | Swipe-to-dismiss |
| `Resizable` | Both | Panel resize handle |
| `ScrollArea` (custom thumb) | Vertical / Horizontal | Scrollbar drag |

**Proposed API.**
```dart
Draggable(
  axis: Axis.horizontal,
  trackExtent: widget.width,
  min: widget.min,
  max: widget.max,
  disabled: widget.disabled,
  onChanged: widget.onChanged,
  builder: (context, isDragging) => ...,
)
```

---

## 5. `SelectableItem`

**What it is.** A fully-controlled binary (or tri-state) value holder with a single `onChanged` callback. Encapsulates the "flip on tap" logic and enforces that the widget never owns the value — all state lives outside. Think of it as the contract between a selection control and its caller.

**Current state.** Implicit in `Toggle` (`pressed` / `onPressedChange`), `AppCheckbox` (`value: CheckboxValue` / `onChanged`), `AppRadio` (`selected` / `onSelect`), `AppSwitch` (`value` / `onChanged`). Each uses a slightly different field name and callback type — this primitive unifies them.

**Used by (existing).** `Toggle`, `AppCheckbox`, `AppRadio`, `AppSwitch`.

**Used by (future).** `Tabs` (individual tab), `Select` item, `DropdownMenu` item (checked variant), `Menubar` item (checked variant), `ContextMenu` item (checked variant), `NavigationMenu` item.

**Proposed API.**
```dart
// Typed value contract — T is bool, CheckboxValue, String, etc.
class SelectableItemController<T> {
  const SelectableItemController({
    required this.value,
    required this.onChanged,
  });

  final T value;
  final ValueChanged<T>? onChanged;
}
```

---

## 6. `GroupSelection`

**What it is.** Manages single-select or multi-select state across a set of items identified by `String` keys. Currently only `ToggleGroup` implements this logic (`_handleItemChange`, single-deselectable vs. multi-add/remove). The same logic is needed for `Tabs`, `RadioGroup`, `Select`, `ToggleGroup`, and more.

**Current state.** Implemented inline in `ToggleGroup._handleItemChange`. Not shared.

**Used by (existing).** `ToggleGroup`.

**Used by (future).**
| Component | Mode |
|---|---|
| `Tabs` | Single, non-deselectable |
| `RadioGroup` | Single, non-deselectable |
| `Select` | Single, non-deselectable |
| `ToggleGroup` | Single (deselectable) or Multiple |
| `Combobox` / `Command` | Single or Multiple |
| `Table` (row selection) | Single or Multiple |
| `Calendar` | Single or Range (special case) |

**Proposed API.**
```dart
// Standalone controller, usable as an InheritedWidget or plain state object
class GroupSelectionController extends ChangeNotifier {
  GroupSelectionController({
    required Set<String> initialValues,
    this.multiple = false,
    this.deselectable = false, // single-mode: can deselect active item
  });

  Set<String> get selectedValues => ...;

  void toggle(String value) { ... }   // applies single/multiple logic
  void select(String value) { ... }
  void deselect(String value) { ... }
  void clear() { ... }
}
```

---

## 7. `ExpandCollapse`

**What it is.** Controls the expanded / collapsed state of a content region with optional animation. Needed for `Accordion`, `Collapsible`, `NavigationMenu` sub-menus, `Sidebar` expandable sections, and `Sheet` partial-height expansion.

**Current state.** Not implemented — no collapsible component exists yet.

**Used by (future).** `Accordion`, `Collapsible`, `NavigationMenu`, `Sidebar`, `Sheet` (partial expand).

**Proposed API.**
```dart
ExpandCollapse(
  expanded: widget.expanded,
  onExpandedChange: widget.onExpandedChange,
  duration: AppMotion.durationNormal,
  curve: AppMotion.curveStandard,
  builder: (context, isExpanded) => ...,
)
```

---

## 8. `KeyboardNavigable`

**What it is.** Handles arrow-key focus traversal within a list of focusable items (Left/Right for horizontal groups, Up/Down for vertical menus), plus Home / End, and optionally wrapping. Needed for any component that groups multiple interactive items under keyboard control.

**Current state.** Not implemented — no component currently responds to arrow keys.

**Used by (future).**
| Component | Axis | Notes |
|---|---|---|
| `Tabs` | Horizontal | Left/Right between tabs |
| `ToggleGroup` | H or V | Left/Right or Up/Down |
| `RadioGroup` | Vertical | Up/Down between radios |
| `Select` / `DropdownMenu` | Vertical | Up/Down in open listbox |
| `Combobox` / `Command` | Vertical | Up/Down in filtered results |
| `Menubar` | Horizontal | Left/Right between menus |
| `ContextMenu` / `DropdownMenu` | Vertical | Up/Down within open menu |
| `NavigationMenu` | Horizontal + Vertical | Root + sub-items |
| `Calendar` | Both | Date grid navigation |
| `Slider` | Horizontal | Arrow keys ± step |
| `InputOTP` | Horizontal | Digit-to-digit advancement |

**Proposed API.**
```dart
// InheritedWidget that provides a FocusNode list + keyboard handler
KeyboardNavigable(
  axis: Axis.horizontal,
  wrap: false,
  children: [...],   // each child registers itself via context
)
```

---

## 9. `OverlayTrigger`

**What it is.** Manages the lifecycle of a positioned overlay (Popover, Tooltip, Dropdown, Select listbox, ContextMenu): open/close state, positioning relative to the trigger widget, and dismissal on outside-tap or Escape key.

**Current state.** Not implemented — no overlay component exists yet.

**Used by (future).** `Popover`, `Tooltip`, `HoverCard`, `Select`, `DropdownMenu`, `ContextMenu`, `Combobox`, `DatePicker`, `Menubar` menus, `NavigationMenu` sub-panels, `Command` palette.

**Proposed API.**
```dart
OverlayTrigger(
  trigger: (context, open) => Button(onPressed: open, ...),
  overlay: (context, close) => PopoverContent(...),
  placement: OverlayPlacement.bottomStart,
  openOnHover: false,
  openOnFocus: false,
  dismissOnOutsideTap: true,
  dismissOnEscape: true,
)
```

---

## 10. `FocusTrap`

**What it is.** Traps keyboard focus inside a subtree — Tab cycles through the contained focusable widgets and never escapes to the rest of the page. Essential for any blocking overlay (Dialog, AlertDialog, Sheet, Drawer).

**Current state.** Not implemented.

**Used by (future).** `Dialog`, `AlertDialog`, `Sheet`, `Drawer`, `DropdownMenu` (when open), `Select` listbox, `ContextMenu`, `Menubar` open menus, `Command` palette, `Combobox` listbox.

**Proposed API.**
```dart
// Thin wrapper around Flutter's FocusScope with explicit containment
FocusTrap(
  active: isOpen,
  child: ...,
)
```

---

## 11. `HoverIntent`

**What it is.** Wraps `MouseRegion` with an open-delay timer and a close-delay timer, so an overlay opens only after the pointer lingers (avoids accidental hover flashes) and closes only after the pointer has left for a grace period (so the user can move into the overlay itself).

**Current state.** Not implemented.

**Used by (future).** `Tooltip`, `HoverCard`, `NavigationMenu` (hover-open sub-menus).

**Proposed API.**
```dart
HoverIntent(
  openDelay: const Duration(milliseconds: 300),
  closeDelay: const Duration(milliseconds: 150),
  onOpen: () => setState(() => _open = true),
  onClose: () => setState(() => _open = false),
  child: ...,
)
```

---

## 12. `FormField`

**What it is.** Propagates form-level state — `disabled`, `invalid`, `required`, and an optional error message — down an `InheritedWidget` tree so that `Input`, `Textarea`, `Checkbox`, `Radio`, `Switch`, `Select`, etc. automatically inherit the form group's state without each caller threading props manually. Also provides a validation hook.

**Current state.** `disabled`, `invalid`, and `required` are explicit constructor props on `Input` and `Textarea`. `InputGroup` provides a partial version (disabled + invalid for the group box), but there is no tree-wide `Form` context.

**Used by (existing).** `Input`, `Textarea`, `InputGroup` (partial).

**Used by (future).** `Form`, `Select`, `Combobox`, `DatePicker`, `Checkbox` (in a form), `RadioGroup` (in a form), `Switch` (in a form).

**Proposed API.**
```dart
// InheritedWidget broadcasting form state
class FormFieldContext extends InheritedWidget {
  const FormFieldContext({
    required this.disabled,
    required this.invalid,
    required this.required,
    this.errorMessage,
    required super.child,
  });

  final bool disabled;
  final bool invalid;
  final bool required;
  final String? errorMessage;

  static FormFieldContext? maybeOf(BuildContext context) => ...;
}
```

---

## 13. `ScrollControl`

**What it is.** A custom-painted scrollable area with a styled scrollbar thumb (the `ScrollArea` component equivalent). Wraps Flutter's `ScrollController` + `Scrollbar` or a fully custom `CustomPaint` thumb, with hover/drag interaction on the thumb itself.

**Current state.** Not implemented.

**Used by (future).** `ScrollArea`, `Select` listbox (when items overflow), `Combobox` results list, `Command` results list.

---

## Summary table

| # | Primitive | Status | Used by (existing) | Used by (future) |
|---|---|---|---|---|
| 1 | `Pressable` | ⚠️ Duplicated | Button, Toggle (full); Checkbox, Radio, Switch, FileDropTarget, InputGroupAddon (tap-only) | AlertDialog, Dialog, Tabs, Pagination, Drawer, Toast, DropdownMenu items, Menubar items |
| 2 | `Focusable` | ⚠️ Duplicated | All 8 interactive components | Every future interactive component |
| 3 | `TextEditable` | ⚠️ Duplicated | Input, Textarea, InputGroupInput, InputGroupTextarea | InputOTP, Combobox, Command, DatePicker |
| 4 | `DragControl` | ⚠️ Duplicated (1×) | AppSlider | RangeSlider, Carousel, Drawer, Sheet, Resizable, ScrollArea |
| 5 | `SelectableItem` | ⚠️ Implicit | Toggle, Checkbox, Radio, Switch | Tabs item, Select item, DropdownMenu item |
| 6 | `GroupSelection` | ⚠️ Duplicated (1×) | ToggleGroup | Tabs, RadioGroup, Select, Combobox, Command, Table, Calendar |
| 7 | `ExpandCollapse` | ❌ Missing | — | Accordion, Collapsible, NavigationMenu, Sidebar |
| 8 | `KeyboardNavigable` | ❌ Missing | — | Tabs, ToggleGroup, RadioGroup, Select, DropdownMenu, Menubar, ContextMenu, Calendar, Slider (arrow-key step), InputOTP |
| 9 | `OverlayTrigger` | ❌ Missing | — | Popover, Tooltip, HoverCard, Select, DropdownMenu, ContextMenu, Combobox, DatePicker, Menubar, NavigationMenu, Command |
| 10 | `FocusTrap` | ❌ Missing | — | Dialog, AlertDialog, Sheet, Drawer, DropdownMenu, Select, ContextMenu, Menubar, Command |
| 11 | `HoverIntent` | ❌ Missing | — | Tooltip, HoverCard, NavigationMenu |
| 12 | `FormField` | ⚠️ Partial | Input, Textarea, InputGroup | Form, Select, Combobox, DatePicker, Checkbox, RadioGroup, Switch |
| 13 | `ScrollControl` | ❌ Missing | — | ScrollArea, Select listbox, Combobox list, Command list |

**Legend:** ✅ Done · ⚠️ Duplicated / Partial (exists inline, not extracted) · ❌ Missing (not yet in codebase)

---

## Next steps

1. **Implementation plan** — Decide implementation shape for each primitive (mixin, widget, controller, InheritedWidget) and define file locations under `lib/src/primitives/`.
2. **Implement** — Start with `Focusable` and `Pressable` (highest duplication, lowest complexity), then `TextEditable`, `DragControl`, `SelectableItem`, `GroupSelection`.
3. **Refactor existing components** — Replace the 8 inline `FocusNode`-lifecycle blocks, the 2 `isPressed` implementations, and the `ToggleGroup._handleItemChange` implementation with the new primitives.
4. **Build new components** — Use `ExpandCollapse`, `KeyboardNavigable`, `OverlayTrigger`, `FocusTrap`, `HoverIntent`, `FormField`, and `ScrollControl` as the foundation for the remaining shadcn-equivalent components.
