# Switch 2 (DsSwitch) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsSwitch`, a binary on/off control built on Remix's `RemixSwitch`, styled through this design system's Mix semantic tokens — following the same structure as `button_2`/`DsButton` and `input_2`/`DsInput`.

**Architecture:** `DsSwitch` is a thin `StatelessWidget` wrapper delegating all interaction handling (toggle gesture, hover/press/focus, semantics) to `RemixSwitch`. A single `resolveDsSwitchStyle()` entry point (in a `part` file) composes a `RemixSwitchStyle` from base + size + disabled-state fragments, using `RemixSwitchStyle`'s own `.onSelected()` helper for the on/off track color.

**Tech Stack:** Flutter (`package:flutter/widgets.dart`), `package:remix/remix.dart` (`RemixSwitch`/`RemixSwitchStyle`), `package:mix/mix.dart` (tokens/`BoxStyler`/`EdgeInsetsGeometryMix`/`WidgetModifierConfig`).

## Global Constraints

- Package is managed via FVM; use `fvm flutter analyze` and `fvm flutter run` (not bare `flutter`/`dart`), consistent with `.fvm/fvm_config.json`.
- No `test/` directory exists in this package — `button_2`/`input_2` shipped without automated widget tests. Verification here is `fvm flutter analyze` (must report "No issues found!") plus visual confirmation in the running `example` catalog app — do not invent a `test/` directory or test framework not already in use.
- Follow the exact file-splitting convention used by `button_2`/`input_2`: main widget file + `part of` style-resolver file + separate variants-enum file (no single monolithic file).
- Match existing widget doc-comment density and style (see `button_2.dart`, `input_2.dart`) — explain *why*, not *what*.
- No `DsSwitchVariant` enum, no label/description slot — out of scope per `docs/superpowers/specs/2026-07-15-switch-2-component-design.md`.
- `selected` and `enabled` are always explicit constructor flags, never inferred from interaction state.
- `onChanged` is nullable (`ValueChanged<bool>?`), unlike Remix's own `RemixSwitch.onChanged` (required non-null) — `DsSwitch` computes its own effective-enabled flag and forwards a non-null wrapper, per the design spec's "onChanged" decision.

---

### Task 1: `DsSwitchSize` enum

**Files:**
- Create: `lib/src/components/switch_2/switch_2_variants.dart`

**Interfaces:**
- Produces: `enum DsSwitchSize { sm, md, lg }` — consumed by Tasks 2 and 3.

- [ ] **Step 1: Write the enum file**

```dart
enum DsSwitchSize { sm, md, lg }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm flutter analyze lib/src/components/switch_2/switch_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/switch_2/switch_2_variants.dart
git commit -m "feat(switch): add DsSwitchSize enum"
```

---

### Task 2: Style resolver — `resolveDsSwitchStyle`

**Files:**
- Create: `lib/src/components/switch_2/switch_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsSwitchSize` (Task 1). Semantic tokens from `lib/src/tokens/semantic/colors.dart` and `lib/src/tokens/semantic/radius.dart` (already exist in this repo — no changes needed there).
- Produces: `RemixSwitchStyle resolveDsSwitchStyle({required DsSwitchSize size, required bool disabled})` — consumed by Task 3.

This file is a `part of 'switch_2.dart'`, so it cannot be analyzed standalone until Task 3 creates the library file. Steps below create the file now; the analyze check happens at the end of Task 3, once both files exist together. This is called out explicitly so the step doesn't look skipped.

- [ ] **Step 1: Write the resolver file**

```dart
part of 'switch_2.dart';

// Style resolver for DsSwitch.
//
// Single entry point `resolveDsSwitchStyle` builds one `RemixSwitchStyle` by
// merging fragments — base, then size, then disabled state — mirroring the
// base/size/variant/state composition in `button_2_style_resolver.dart`
// (minus the variant fragment: DsSwitch has no visual-skin axis, same
// decision `input_2` made — see the design spec's "Variant axis" section).

/// Resolves the full `RemixSwitchStyle` for a [DsSwitch], given its [size]
/// and current [disabled] state.
///
/// Order of composition: base track/thumb colors and on-selected color,
/// then size (track/thumb dimensions), then disabled. Later merges win on
/// overlapping properties, so `stateStyle` — applied last — always has
/// final say (disabled's dimming wins over whatever size/base set,
/// mirroring `resolveDsButtonStyle`'s "disabled always wins" comment).
RemixSwitchStyle resolveDsSwitchStyle({
  required DsSwitchSize size,
  required bool disabled,
}) {
  // Neither `Curve` nor arithmetic on a `Duration` token reference is
  // supported by Mix's inline token-ref mechanism (see
  // `resolveDsButtonStyle`'s identical comment in
  // `button_2_style_resolver.dart`), so the 100ms `Curves.easeInOut`
  // transition is a literal here too, matching the legacy `AppSwitch`'s
  // `AppMotion.durationFast`/`AppMotion.curveStandard` transition.
  final baseStyle = RemixSwitchStyle()
      .trackColor($borderStrong())
      .thumbColor($surfaceDefault())
      .borderRadiusAll($radiusFull())
      .thumb(BoxStyler().borderRadiusAll($radiusFull()))
      .onSelected(RemixSwitchStyle().trackColor($surfaceInverted()))
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // `RemixSwitch._buildStyle()` already sets `alignment(.centerLeft)` /
  // `.onSelected(alignment(.centerRight))` internally to slide the thumb —
  // this resolver only needs to size the track/thumb boxes and inset the
  // thumb via container padding (mirrors legacy `AppSwitch`'s
  // `thumbInset`), not touch alignment itself.
  final sizeStyle = switch (size) {
    DsSwitchSize.sm => RemixSwitchStyle(
        container: BoxStyler()
            .width(32)
            .height(18)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(14, 14),
      ),
    DsSwitchSize.md => RemixSwitchStyle(
        container: BoxStyler()
            .width(40)
            .height(24)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(20, 20),
      ),
    DsSwitchSize.lg => RemixSwitchStyle(
        container: BoxStyler()
            .width(48)
            .height(28)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(24, 24),
      ),
  };

  // Disabled wins over every other interactive/selected state — a disabled
  // switch never shows brighter selected/hover feedback regardless of
  // `selected`, matching `resolveDsButtonStyle`'s equivalent comment.
  final stateStyle = disabled
      ? RemixSwitchStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSwitchStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/components/switch_2/switch_2_style_resolver.dart
git commit -m "feat(switch): add DsSwitch style resolver"
```

---

### Task 3: `DsSwitch` widget

**Files:**
- Create: `lib/src/components/switch_2/switch_2.dart`

**Interfaces:**
- Consumes: `DsSwitchSize` (Task 1), `resolveDsSwitchStyle` (Task 2).
- Produces: `class DsSwitch extends StatelessWidget` — consumed by Task 4 (export) and Task 5 (catalog spec).

- [ ] **Step 1: Write the widget file**

```dart
import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import 'switch_2_variants.dart';

// The `resolveDsSwitchStyle` function consumed by `build()` below lives in
// switch_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsSwitch while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsInput`'s `input_2_style_resolver.dart`.
part 'switch_2_style_resolver.dart';

/// A binary on/off control built on top of the `remix` package's
/// [RemixSwitch], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppSwitch` (a `GestureDetector` +
/// `AnimatedContainer`/`AnimatedAlign` pair), [DsSwitch] delegates all
/// interaction handling (toggle gesture, hover/press/focus, semantics) to
/// [RemixSwitch] and only supplies a resolved [RemixSwitchStyle] — see
/// [resolveDsSwitchStyle] — for [size].
///
/// No label/description slot — same as legacy `AppSwitch`, composing an
/// adjacent label is the caller's responsibility (e.g.
/// `Row([DsSwitch(...), Text(...)])`). See
/// `docs/superpowers/specs/2026-07-15-switch-2-component-design.md`.
class DsSwitch extends StatelessWidget {
  const DsSwitch({
    super.key,
    required this.selected,
    this.onChanged,
    this.size = DsSwitchSize.md,
    this.enabled = true,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixSwitchStyle.create(),
    this.styleSpec,
  });

  /// Public state: whether the switch is on. Always reflects the caller's
  /// state — this widget holds no internal on/off state of its own. Never
  /// inferred, same convention as [DsButton]'s `loading`/`enabled`.
  final bool selected;

  /// Called with the new value on toggle. Ignored (and the switch rendered
  /// non-interactive) while [enabled] is false, or when null — same
  /// contract as [DsButton.onPressed]. Nullable unlike [RemixSwitch]'s own
  /// `onChanged` (required non-null): [_isEnabled] folds this null check
  /// in before forwarding to [RemixSwitch].
  final ValueChanged<bool>? onChanged;

  /// Physical size — see [DsSwitchSize].
  final DsSwitchSize size;

  /// Public state: renders muted track/thumb colors and suppresses toggling
  /// when false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to provide platform feedback (e.g. haptics) on toggle.
  final bool enableFeedback;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixSwitch]/`NakedToggle`.
  final FocusNode? focusNode;

  /// Whether this switch should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsSwitchStyle]'s output).
  final RemixSwitchStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixSwitchSpec] directly, bypassing style resolution entirely.
  final RemixSwitchSpec? styleSpec;

  /// True when the switch accepts toggles at all. [enabled] always wins,
  /// and a null [onChanged] makes the switch inert even when [enabled] is
  /// true — mirrors [DsButton]'s `_interactive` getter.
  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSwitchStyle(
      size: size,
      disabled: !_isEnabled,
    ).merge(style);

    return RemixSwitch(
      selected: selected,
      // `RemixSwitch.onChanged` is non-null; `_isEnabled` already gates
      // real interactivity via `enabled` below, so this fallback is never
      // invoked while non-interactive.
      onChanged: onChanged ?? (_) {},
      enabled: _isEnabled,
      enableFeedback: enableFeedback,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      mouseCursor: mouseCursor,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
```

- [ ] **Step 2: Verify both files analyze cleanly together**

Run: `fvm flutter analyze lib/src/components/switch_2/`
Expected: `No issues found!`

If it reports unresolved token/method names (e.g. a typo in a token name or a
Mix API that doesn't match the installed `mix`/`remix` package versions),
open the flagged file at the reported line and cross-check the exact method
name against `button_2_style_resolver.dart`/`input_2_style_resolver.dart`
(for token methods) or the installed package source at
`~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/switch/switch_style.dart`
(for `RemixSwitchStyle` methods) before changing anything.

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/switch_2/switch_2.dart
git commit -m "feat(switch): add DsSwitch widget"
```

---

### Task 4: Export from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart:69` (the commented-out legacy `// export 'src/components/switch/switch.dart';` line)

**Interfaces:**
- Consumes: `DsSwitch` (Task 3), `DsSwitchSize` (Task 1).
- Produces: public exports `ui.DsSwitch`, `ui.DsSwitchSize` for Task 5 and any external consumer.

- [ ] **Step 1: Add the two export lines**

In `lib/ui.dart`, change:

```dart
// export 'src/components/spinner/spinner.dart';
// export 'src/components/spinner/spinner_size.dart';
// export 'src/components/switch/switch.dart';
// export 'src/components/textarea/textarea.dart';
```

to:

```dart
// export 'src/components/spinner/spinner.dart';
// export 'src/components/spinner/spinner_size.dart';
export 'src/components/switch_2/switch_2.dart';
export 'src/components/switch_2/switch_2_variants.dart';
// export 'src/components/switch/switch.dart';
// export 'src/components/textarea/textarea.dart';
```

(Leave the commented-out legacy `switch/` line as-is — it stays commented
out during the migration, same as every other legacy component in this
file.)

- [ ] **Step 2: Verify the whole package analyzes cleanly**

Run: `fvm flutter analyze lib/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "feat(switch): export DsSwitch from ui.dart"
```

---

### Task 5: Catalog showcase spec + registration

**Files:**
- Create: `example/lib/catalog/specs/switch_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsSwitch`, `DsSwitchSize` (via `package:ui/ui.dart`), `ComponentShowcaseSpec` (`example/lib/catalog/component_showcase_spec.dart`, already exists — `title`, `variantsBuilder`, `sizesBuilder`, `statesBuilder` fields, all `List<Widget> Function()?`).
- Produces: `ComponentShowcaseSpec buildSwitch2ShowcaseSpec()`, registered under `'Switch 2'` in `componentRegistry`.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSwitch2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Switch 2',
    sizesBuilder: () => DsSwitchSize.values
        .map(
          (size) => DsSwitch(
            selected: true,
            size: size,
            onChanged: _noop,
          ),
        )
        .toList(),
    // Public states (selected/disabled) are driven by their real
    // constructor flags. Hover/pressed/focus are handled internally by
    // RemixSwitch and are inherently transient, so verify them
    // interactively in the running app instead (hover/hold/tab-focus any
    // enabled switch below).
    statesBuilder: () => [
      DsSwitch(selected: true, onChanged: _noop),
      DsSwitch(selected: false, onChanged: _noop),
      const DsSwitch(selected: true, onChanged: null, enabled: false),
      const DsSwitch(selected: false, onChanged: null, enabled: false),
    ],
  );
}

void _noop(bool _) {}
```

- [ ] **Step 2: Register it in `component_registry.dart`**

In `example/lib/catalog/component_registry.dart`, change:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
```

to:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
import 'specs/switch_2_showcase_spec.dart';
```

and change:

```dart
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button 2': buildButton2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
};
```

to:

```dart
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button 2': buildButton2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
  'Switch 2': buildSwitch2ShowcaseSpec,
};
```

- [ ] **Step 3: Analyze the example app**

Run: `cd example && fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Visually verify in the running catalog app**

Run: `cd example && fvm flutter run -d macos` (or any available desktop/simulator device — check `fvm flutter devices` first if `macos` isn't available).

In the running app, open the "Switch 2" entry from the catalog home page and confirm:
- The three sizes render with visibly different track/thumb dimensions, all in the "on" position.
- `selected: true`/`selected: false` states show the thumb on the right/left respectively, with the track colored accordingly (dark when on, gray when off).
- Both `disabled` states render muted/dimmed and do not respond to clicks.
- Clicking an enabled switch toggles it and animates the thumb sliding across.

Stop the app afterward (`q` in the terminal running `flutter run`, or close the window).

- [ ] **Step 5: Commit**

```bash
git add example/lib/catalog/specs/switch_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(switch): add Switch 2 catalog showcase"
```

---

## Self-Review Notes

- **Spec coverage:** file structure (Task 1–3), `DsSwitchSize` enum with no variant axis (Task 1), style resolver base/size/disabled composition using `.onSelected()`/`.wrap(opacity)` (Task 2), nullable `onChanged` → `_isEnabled` forwarding contract (Task 3), catalog registration (Task 5), `ui.dart` export (Task 4) — all covered. `DsSwitchVariant` enum and label/description slots are explicitly out of scope and not tasked.
- **Placeholder scan:** no TBD/TODO; every step has literal code or an exact command with expected output.
- **Type consistency:** `DsSwitchSize` (Task 1) used identically in Task 2's `resolveDsSwitchStyle` signature, Task 3's `DsSwitch.size` field, and Task 5's `DsSwitchSize.values` iteration. `resolveDsSwitchStyle({required DsSwitchSize size, required bool disabled})` (Task 2) matches its one call site in Task 3's `build()` (`disabled: !_isEnabled`). `RemixSwitchStyle`/`RemixSwitchSpec`/`RemixSwitch` names and constructor params (`selected`, `onChanged`, `enabled`, `enableFeedback`, `focusNode`, `autofocus`, `semanticLabel`, `mouseCursor`, `style`, `styleSpec`) match the installed `remix` package's public API (verified against `~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/switch/switch_widget.dart` and `switch_style.dart`).
