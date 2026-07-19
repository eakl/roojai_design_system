# label_2 (DsLabel) Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `label_2` (`DsLabel`), the DS-2 replacement for the legacy `Label` widget — a static text caption with `required`/`disabled` modifiers and a new `DsLabelSize` axis, built on Mix's `StyledText`/`TextStyler` and the `_2` token set.

**Architecture:** A plain `StatelessWidget` (no Remix widget wrapped, since Remix has no standalone Label widget) rendering a `Row` of one or two `StyledText`s, styled by a pure `resolveDsLabelStyle()` function. Same three-file shape as `icon_2` (`label_2.dart` + `label_2_style_resolver.dart` part file + `label_2_variants.dart`), registered in the catalog and exported from `lib/ui.dart`.

**Tech Stack:** Flutter, `mix` (`StyledText`, `TextStyler`), the repo's `theme/light/*.dart` Mix token constants (`$labelSm`/`$labelMd`/`$labelLg`, `$contentPrimary`, `$contentPlaceholder`, `$negativeText`, `$spacing002`).

## Global Constraints

- No `variant`/color-skin axis — single visual style only, matching `input_2`'s precedent.
- No click/focus/interaction handling — `DsLabel` is a static caption.
- No `style`/`styleSpec` escape hatch on the widget (no Remix `Styler` type to merge against).
- `disabled` is always an explicit constructor flag, never inferred from a sibling widget's state.
- File structure, widget API, and resolver signature must match `docs/superpowers/specs/2026-07-19-label-2-component-design.md` exactly.

---

## File Structure

```
lib/src/components/label_2/
  label_2.dart                 — DsLabel widget (new)
  label_2_style_resolver.dart  — part of label_2.dart; resolveDsLabelStyle() (new)
  label_2_variants.dart        — DsLabelSize enum (new)
lib/ui.dart                    — add two export lines (modify)
example/lib/catalog/specs/label_2_showcase_spec.dart — catalog spec (new)
example/lib/catalog/component_registry.dart          — register spec (modify)
```

---

### Task 1: `DsLabelSize` enum

**Files:**
- Create: `lib/src/components/label_2/label_2_variants.dart`

**Interfaces:**
- Produces: `enum DsLabelSize { sm, md, lg }`, consumed by Task 2 (widget) and Task 3 (resolver).

- [ ] **Step 1: Create the variants file**

```dart
enum DsLabelSize { sm, md, lg }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `flutter analyze lib/src/components/label_2/label_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/label_2/label_2_variants.dart
git commit -m "feat(label_2): add DsLabelSize enum"
```

---

### Task 2: `resolveDsLabelStyle` style resolver

**Files:**
- Create: `lib/src/components/label_2/label_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsLabelSize` from Task 1 (`lib/src/components/label_2/label_2_variants.dart`).
- Produces: `({TextStyler text, TextStyler marker}) resolveDsLabelStyle({required DsLabelSize size, required bool disabled})`, consumed by Task 3 (widget).

This file is a `part of 'label_2.dart'`, so it has no imports of its own — it inherits whatever `label_2.dart` imports (written in Task 3). Since Dart requires the `part of` target to exist for the file to analyze, write Task 3's `label_2.dart` header (imports + `part` directive + empty class stub) first, then come back and fill in this file's body. To keep the task self-contained and independently testable, this task creates a temporary minimal `label_2.dart` that Task 3 will then flesh out — this avoids a chicken-and-egg ordering problem between the two files.

- [ ] **Step 1: Create a minimal `label_2.dart` stub so the part file has a home**

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'label_2_variants.dart';

part 'label_2_style_resolver.dart';
```

Save this as `lib/src/components/label_2/label_2.dart`.

- [ ] **Step 2: Create the resolver file**

```dart
part of 'label_2.dart';

({TextStyler text, TextStyler marker}) resolveDsLabelStyle({
  required DsLabelSize size,
  required bool disabled,
}) {
  final sizeToken = switch (size) {
    DsLabelSize.sm => $labelSm.mix(),
    DsLabelSize.md => $labelMd.mix(),
    DsLabelSize.lg => $labelLg.mix(),
  };

  final textColor = disabled ? $contentPlaceholder() : $contentPrimary();
  final markerColor = disabled ? $contentPlaceholder() : $negativeText();

  return (
    text: TextStyler().style(sizeToken).color(textColor),
    marker: TextStyler().style(sizeToken).color(markerColor),
  );
}
```

Save this as `lib/src/components/label_2/label_2_style_resolver.dart`.

- [ ] **Step 3: Verify it analyzes cleanly**

Run: `flutter analyze lib/src/components/label_2/`
Expected: `No issues found!` (the stub `label_2.dart` has no unused-import warnings because every import — `widgets.dart`, `mix.dart`, `colors.dart`, `spacing.dart`, `typography.dart`, `label_2_variants.dart` — is used by the resolver's `$labelSm`/`$contentPlaceholder`/`$negativeText`/`TextStyler`/`DsLabelSize` references; `spacing.dart` import is currently unused at this point but is needed by Task 3's `$spacing002` usage — if analyze flags it as unused after Step 1 alone, ignore it, it will be consumed once Task 3 completes the widget body).

- [ ] **Step 4: Commit**

```bash
git add lib/src/components/label_2/label_2.dart lib/src/components/label_2/label_2_style_resolver.dart
git commit -m "feat(label_2): add resolveDsLabelStyle resolver"
```

---

### Task 3: `DsLabel` widget

**Files:**
- Modify: `lib/src/components/label_2/label_2.dart` (fill in the stub from Task 2)

**Interfaces:**
- Consumes: `DsLabelSize` (Task 1), `resolveDsLabelStyle()` (Task 2).
- Produces: `class DsLabel extends StatelessWidget` with constructor `DsLabel({Key? key, required String text, DsLabelSize size = DsLabelSize.md, bool required = false, bool disabled = false})`, consumed by Task 4 (catalog spec) and by `lib/ui.dart`'s export (Task 5).

- [ ] **Step 1: Replace the stub with the full widget**

Replace the full contents of `lib/src/components/label_2/label_2.dart` with:

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'label_2_variants.dart';

// The `resolveDsLabelStyle` function consumed by `build()` below lives in
// label_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsLabel while living in its own
// file — same split as `icon_2`'s `icon_style_resolver.dart`.
part 'label_2_style_resolver.dart';

/// A form-field caption built on Mix's `StyledText`, styled through the
/// design system's `_2` semantic tokens.
///
/// The DS-2 replacement for the legacy hand-rolled `Label`. Unlike
/// `button_2`/`input_2`, there is no Remix widget to wrap — Remix ships a
/// label styling mixin used internally by other components, not a
/// standalone Label widget — so [DsLabel] is a plain `StatelessWidget`
/// rendering directly through Mix's `StyledText`/`TextStyler`, the same
/// approach `icon_2` uses for `StyledIcon`.
///
/// Carries two independent boolean modifiers — [required] (appends a `*`
/// in the negative/error color) and [disabled] (mutes the text to match a
/// disabled sibling field) — plus a [size] axis (new relative to legacy
/// `Label`, which had none) so the caption can be sized to match the
/// `DsInputSize`/`DsButtonSize` of the field it's paired with.
///
/// [disabled] is always an explicit, caller-supplied flag, never inferred
/// from a sibling widget's state — this package has no CSS-`peer-disabled`
/// equivalent, and disabled is never inferred elsewhere in the DS either.
class DsLabel extends StatelessWidget {
  const DsLabel({
    super.key,
    required this.text,
    this.size = DsLabelSize.md,
    this.required = false,
    this.disabled = false,
  });

  /// The label's text content. Always shown.
  final String text;

  /// Physical size — see [DsLabelSize].
  final DsLabelSize size;

  /// Whether the field this label describes is required. When true, a `*`
  /// is appended after [text] in the negative/error color.
  final bool required;

  /// Whether the field this label describes is disabled. When true, the
  /// text (and the `*`, if [required] is also true) is muted to the same
  /// placeholder color a disabled input's own text would use.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsLabelStyle(size: size, disabled: disabled);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StyledText(text, style: resolvedStyle.text),
        if (required) ...[
          SizedBox(width: $spacing002()),
          StyledText('*', style: resolvedStyle.marker),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `flutter analyze lib/src/components/label_2/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/label_2/label_2.dart
git commit -m "feat(label_2): add DsLabel widget"
```

---

### Task 4: Catalog showcase spec

**Files:**
- Create: `example/lib/catalog/specs/label_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsLabel`, `DsLabelSize` (from Task 3/1, imported via `package:ui/ui.dart` once Task 5 adds the exports — do Task 5 before this task if running strictly in order, or run Task 5's export step first as a sub-step here).
- Produces: `ComponentShowcaseSpec Function() buildLabel2ShowcaseSpec`, registered under key `'Label 2'` in `componentRegistry`.

- [ ] **Step 1: Add the two export lines to `lib/ui.dart` first (pulled forward from Task 5 so this task's spec file can import `DsLabel`)**

In `lib/ui.dart`, insert after the `input_2` export block (after line 60, `export 'src/components/input_2/input_2_variants.dart';`, before the `// export 'src/components/input/input.dart';` comment block):

```dart
export 'src/components/label_2/label_2.dart';
export 'src/components/label_2/label_2_variants.dart';
```

- [ ] **Step 2: Create the showcase spec**

```dart
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildLabel2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Label 2',
    sizesBuilder: () => DsLabelSize.values
        .map((size) => DsLabel(text: size.name, size: size))
        .toList(),
    // DsLabel is a static, non-interactive caption — no focus/hover states
    // to call out (unlike input_2's transient Naked-driven states).
    statesBuilder: () => const [
      DsLabel(text: 'Default'),
      DsLabel(text: 'Required', required: true),
      DsLabel(text: 'Disabled', disabled: true),
      DsLabel(text: 'Required + disabled', required: true, disabled: true),
    ],
  );
}
```

Save as `example/lib/catalog/specs/label_2_showcase_spec.dart`.

- [ ] **Step 3: Register the spec in the registry**

In `example/lib/catalog/component_registry.dart`, add the import after the `input_2` import (alphabetically, after `import 'specs/input_2_showcase_spec.dart';`):

```dart
import 'specs/label_2_showcase_spec.dart';
```

And add the registry entry after `'Input 2': buildInput2ShowcaseSpec,` (alphabetically, before `'Notification 2': buildNotification2ShowcaseSpec,`):

```dart
  'Label 2': buildLabel2ShowcaseSpec,
```

- [ ] **Step 4: Verify the example app analyzes and builds cleanly**

Run (from `example/`): `flutter analyze`
Expected: `No issues found!`

Run (from `example/`): `flutter build web --no-tree-shake-icons 2>&1 | tail -20` (or `flutter build macos`/`flutter build linux` if web isn't configured for this project — check `example/` for a `web/` folder first with `ls example/web` to pick the right target)
Expected: build completes without errors.

- [ ] **Step 5: Run the catalog app and visually verify**

Run: `cd example && flutter run -d chrome` (or the appropriate device for this machine)

In the running app, navigate to the "Label 2" entry and confirm:
- The three sizes (sm/md/lg) render at visibly different text sizes.
- "Required" shows a red `*` after the text.
- "Disabled" renders muted/placeholder-colored text.
- "Required + disabled" shows a muted `*` (not red) alongside muted text.

- [ ] **Step 6: Commit**

```bash
git add lib/ui.dart example/lib/catalog/specs/label_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(label_2): add catalog showcase and export DsLabel"
```

---

## Self-Review Notes

- **Spec coverage:** File structure (Tasks 1-3), widget API (Task 3), resolver (Task 2), catalog registration + `lib/ui.dart` exports (Task 4) — all sections of `docs/superpowers/specs/2026-07-19-label-2-component-design.md` are covered. "Out of scope" items (variant enum, interactivity, style escape hatch) are correctly omitted from the widget in Task 3.
- **Ordering fix:** The design doc lists `lib/ui.dart` exports under "Catalog registration," but the showcase spec needs `DsLabel` importable via `package:ui/ui.dart` to be written — Task 4 pulls the export step forward as its own first step rather than leaving it as a dangling Task 5, avoiding an unresolvable import in the showcase spec file.
- **Type consistency:** `DsLabelSize` (Task 1) is referenced identically in Task 2's resolver, Task 3's widget, and Task 4's showcase spec. `resolveDsLabelStyle`'s return record shape (`{text, marker}`) matches its one call site in Task 3's `build()`.
