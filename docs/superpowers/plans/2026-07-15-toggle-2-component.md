# Toggle 2 (DsToggle) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsToggle`, a pressable on/off button built on Remix's `RemixToggle`, styled through this design system's Mix semantic tokens — following the same structure as `button_2`/`DsButton` and `switch_2`/`DsSwitch`.

**Architecture:** `DsToggle` is a thin `StatelessWidget` wrapper delegating all interaction handling (tap gesture, hover/press/focus, semantics) to `RemixToggle`. A single `resolveDsToggleStyle()` entry point (in a `part` file) composes a `RemixToggleStyle` from Remix's own `FortalToggleStyles.base()` sizing fragment plus this DS's variant (color) and disabled-state fragments.

**Tech Stack:** Flutter (`package:flutter/widgets.dart`), `package:remix/remix.dart` (`RemixToggle`/`RemixToggleStyle`/`FortalToggleStyles`/`FortalToggleSize`), `package:mix/mix.dart` (tokens/`WidgetModifierConfig`).

## Global Constraints

- Package is managed via FVM; use `fvm flutter analyze` and `fvm flutter run` (not bare `flutter`/`dart`), consistent with `.fvm/fvm_config.json`.
- No `test/` directory exists in this package — `button_2`/`input_2`/`switch_2` shipped without automated widget tests. Verification here is `fvm flutter analyze` (must report "No issues found!") plus visual confirmation in the running `example` catalog app — do not invent a `test/` directory or test framework not already in use.
- Follow the exact file-splitting convention used by `button_2`/`switch_2`: main widget file + `part of` style-resolver file + separate variants-enum file (no single monolithic file).
- Match existing widget doc-comment density and style (see `switch_2.dart`) — explain *why*, not *what*.
- `DsToggleVariant` has two members, `ghost` (default) and `outline`, named to match Remix's own `FortalToggleVariant` vocabulary — not the legacy `Toggle`'s `standard`/`outline` naming. `DsToggleSize` uses `sm`/`md`/`lg` (mapped internally to Remix's `FortalToggleSize.size1/2/3`), matching every other `_2` component's size-enum naming. Per `docs/superpowers/specs/2026-07-15-toggle-2-component-design.md`.
- `selected` and `enabled` are always explicit constructor flags, never inferred from interaction state.
- `onChanged` is nullable (`ValueChanged<bool>?`), unlike Remix's own `RemixToggle.onChanged` (required non-null) — `DsToggle` computes its own effective-enabled flag and forwards a non-null wrapper, same pattern as `DsSwitch`.
- `icon` is a single `IconData?` (not a leading/trailing pair like the legacy `Toggle`) — matches `RemixToggle`'s actual single-icon-slot shape. `label`/`icon` carry Remix's own "at least one required" assert verbatim.
- No leading/trailing icon pair, no `standard` variant alias, no migration of the legacy `Toggle`/`toggle_group` widgets — all out of scope per the design spec.

---

### Task 1: `DsToggleVariant` and `DsToggleSize` enums

**Files:**
- Create: `lib/src/components/toggle_2/toggle_2_variants.dart`

**Interfaces:**
- Produces: `enum DsToggleVariant { ghost, outline }`, `enum DsToggleSize { sm, md, lg }` — consumed by Tasks 2 and 3.

- [ ] **Step 1: Write the enum file**

```dart
enum DsToggleVariant { ghost, outline }

enum DsToggleSize { sm, md, lg }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm flutter analyze lib/src/components/toggle_2/toggle_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/toggle_2/toggle_2_variants.dart
git commit -m "feat(toggle): add DsToggleVariant and DsToggleSize enums"
```

---

### Task 2: Style resolver — `resolveDsToggleStyle`

**Files:**
- Create: `lib/src/components/toggle_2/toggle_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsToggleVariant`, `DsToggleSize` (Task 1). Semantic tokens from `lib/src/tokens/semantic/colors.dart` (already exist — no changes needed there). `FortalToggleStyles`/`FortalToggleSize` from `package:remix/remix.dart`.
- Produces: `RemixToggleStyle resolveDsToggleStyle({required DsToggleVariant variant, required DsToggleSize size, required bool disabled})` — consumed by Task 3.

This file is a `part of 'toggle_2.dart'`, so it cannot be analyzed standalone until Task 3 creates the library file. Steps below create the file now; the analyze check happens at the end of Task 3, once both files exist together. This is called out explicitly so the step doesn't look skipped.

- [ ] **Step 1: Write the resolver file**

```dart
part of 'toggle_2.dart';

// Style resolver for DsToggle.
//
// Single entry point `resolveDsToggleStyle` builds one `RemixToggleStyle` by
// merging fragments — size, then variant, then disabled state — mirroring
// the size/variant/state composition in `button_2_style_resolver.dart` and
// `switch_2_style_resolver.dart`. Sizing reuses Remix's own
// `FortalToggleStyles.base()` fragment (pure layout/metrics, no DS-specific
// color) rather than re-deriving padding/spacing/radius/icon-size/label-size
// per step from scratch.

/// Resolves the full `RemixToggleStyle` for a [DsToggle], given its
/// [variant], [size] and current [disabled] state.
///
/// Order of composition: size (via `FortalToggleStyles.base`), then variant
/// (colors), then interactive state (opacity). Later merges win on
/// overlapping properties, so `stateStyle` — applied last — always has
/// final say (disabled's dimming wins over whatever variant set, including
/// `FortalToggleStyles.base`'s own built-in `onDisabled` fragment).
RemixToggleStyle resolveDsToggleStyle({
  required DsToggleVariant variant,
  required DsToggleSize size,
  required bool disabled,
}) {
  final sizeStyle = switch (size) {
    DsToggleSize.sm => FortalToggleStyles.base(size: FortalToggleSize.size1),
    DsToggleSize.md => FortalToggleStyles.base(size: FortalToggleSize.size2),
    DsToggleSize.lg => FortalToggleStyles.base(size: FortalToggleSize.size3),
  };

  const transparent = Color(0x00000000);

  // Selected color reuses the same `$surfaceInverted`/`$contentOnBrand` pair
  // `DsButton.primary` and `DsSwitch`'s on-track color use, for visual
  // continuity across the migrated `_2` family.
  final variantStyle = switch (variant) {
    DsToggleVariant.ghost => RemixToggleStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand()),
        ),
    DsToggleVariant.outline => RemixToggleStyle()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand())
              .borderAll(color: $surfaceInverted()),
        ),
  };

  // Disabled wins over every other interactive/selected state — a disabled
  // toggle never shows brighter selected/hover feedback regardless of
  // `selected`, matching `resolveDsButtonStyle`/`resolveDsSwitchStyle`'s
  // equivalent comment. This also supersedes `FortalToggleStyles.base`'s own
  // built-in `onDisabled` fragment (a grayed background/foreground swap),
  // since `stateStyle` is merged in last.
  final stateStyle = disabled
      ? RemixToggleStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixToggleStyle();

  return sizeStyle.merge(variantStyle).merge(stateStyle);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/components/toggle_2/toggle_2_style_resolver.dart
git commit -m "feat(toggle): add DsToggle style resolver"
```

---

### Task 3: `DsToggle` widget

**Files:**
- Create: `lib/src/components/toggle_2/toggle_2.dart`

**Interfaces:**
- Consumes: `DsToggleVariant`, `DsToggleSize` (Task 1), `resolveDsToggleStyle` (Task 2).
- Produces: `class DsToggle extends StatelessWidget` — consumed by Task 4 (export) and Task 5 (catalog spec).

- [ ] **Step 1: Write the widget file**

```dart
import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import 'toggle_2_variants.dart';

// The `resolveDsToggleStyle` function consumed by `build()` below lives in
// toggle_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsToggle while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'toggle_2_style_resolver.dart';

/// A pressable button that stays visually active when [selected], built on
/// top of the `remix` package's [RemixToggle], styled through the design
/// system's Mix semantic tokens.
///
/// Unlike [RemixSwitch]/[DsSwitch] (a sliding on/off track), [DsToggle] is
/// the whole button itself acting as the on/off affordance — for formatting
/// controls (e.g. "Bold" in a toolbar), filter chips, and tool-state
/// representation.
///
/// Unlike the legacy hand-rolled `Toggle` (a `GestureDetector` +
/// `AnimatedContainer` pair), [DsToggle] delegates all interaction handling
/// (tap gesture, hover/press/focus, semantics) to [RemixToggle] and only
/// supplies a resolved [RemixToggleStyle] — see [resolveDsToggleStyle] — for
/// [variant] and [size]. See
/// `docs/superpowers/specs/2026-07-15-toggle-2-component-design.md`.
class DsToggle extends StatelessWidget {
  const DsToggle({
    super.key,
    required this.selected,
    this.onChanged,
    this.label,
    this.icon,
    this.variant = DsToggleVariant.ghost,
    this.size = DsToggleSize.md,
    this.enabled = true,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixToggleStyle.create(),
    this.styleSpec,
  }) : assert(
         label != null || icon != null,
         'At least one of label or icon must be provided',
       );

  /// Public state: whether the toggle is currently "on". Always reflects
  /// the caller's state — this widget holds no internal on/off state of
  /// its own. Never inferred, same convention as [DsSwitch.selected].
  final bool selected;

  /// Called with the new value on tap. Ignored (and the toggle rendered
  /// non-interactive) while [enabled] is false, or when null — same
  /// contract as [DsSwitch.onChanged]. Nullable unlike [RemixToggle]'s own
  /// `onChanged` (required non-null): [_isEnabled] folds this null check
  /// in before forwarding to [RemixToggle].
  final ValueChanged<bool>? onChanged;

  /// Optional text label. At least one of [label]/[icon] must be provided
  /// (enforced by this constructor's assert), mirroring [RemixToggle]'s own
  /// contract.
  final String? label;

  /// Optional icon. Unlike [DsButton]'s `leadingIcon`/`trailingIcon` pair,
  /// [RemixToggle] exposes only a single icon slot, so [DsToggle] follows
  /// that shape rather than reintroducing the legacy `Toggle`'s
  /// `leading`/`trailing` pair.
  final IconData? icon;

  /// Visual treatment — see [DsToggleVariant].
  final DsToggleVariant variant;

  /// Physical size — see [DsToggleSize].
  final DsToggleSize size;

  /// Public state: renders muted colors and suppresses taps/focus when
  /// false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to provide platform feedback (e.g. haptics) on toggle.
  final bool enableFeedback;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixToggle]/`NakedToggle`.
  final FocusNode? focusNode;

  /// Whether this toggle should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsToggleStyle]'s output).
  final RemixToggleStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixToggleSpec] directly, bypassing style resolution entirely.
  final RemixToggleSpec? styleSpec;

  /// True when the toggle accepts taps at all. [enabled] always wins, and a
  /// null [onChanged] makes the toggle inert even when [enabled] is true —
  /// mirrors [DsSwitch]'s `_isEnabled` getter.
  bool get _isEnabled => enabled && onChanged != null;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsToggleStyle(
      variant: variant,
      size: size,
      disabled: !_isEnabled,
    ).merge(style);

    return RemixToggle(
      selected: selected,
      // `RemixToggle.onChanged` is non-null; `_isEnabled` already gates
      // real interactivity via `enabled` below, so this fallback is never
      // invoked while non-interactive.
      onChanged: onChanged ?? (_) {},
      enabled: _isEnabled,
      label: label,
      icon: icon,
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

Run: `fvm flutter analyze lib/src/components/toggle_2/`
Expected: `No issues found!`

If it reports unresolved token/method names (e.g. a typo in a token name or a
Mix API that doesn't match the installed `mix`/`remix` package versions),
open the flagged file at the reported line and cross-check the exact method
name against `switch_2_style_resolver.dart`/`button_2_style_resolver.dart`
(for token methods) or the installed package source at
`~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/toggle/toggle_style.dart`
and `~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/toggle/fortal_toggle_styles.dart`
(for `RemixToggleStyle`/`FortalToggleStyles` methods) before changing
anything.

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/toggle_2/toggle_2.dart
git commit -m "feat(toggle): add DsToggle widget"
```

---

### Task 4: Export from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart` (the commented-out legacy toggle export lines, currently reading `// export 'src/components/toggle/toggle.dart';` etc., just below the `switch_2`/`switch` block)

**Interfaces:**
- Consumes: `DsToggle` (Task 3), `DsToggleVariant`, `DsToggleSize` (Task 1).
- Produces: public exports `ui.DsToggle`, `ui.DsToggleVariant`, `ui.DsToggleSize` for Task 5 and any external consumer.

- [ ] **Step 1: Add the two export lines**

In `lib/ui.dart`, change:

```dart
export 'src/components/switch_2/switch_2.dart';
export 'src/components/switch_2/switch_2_variants.dart';
// export 'src/components/switch/switch.dart';
// export 'src/components/textarea/textarea.dart';
// export 'src/components/toggle/toggle.dart';
// export 'src/components/toggle/toggle_interaction_state.dart';
// export 'src/components/toggle/toggle_size.dart';
// export 'src/components/toggle/toggle_variant.dart';
// export 'src/components/toggle_group/toggle_group.dart';
// export 'src/components/toggle_group/toggle_group_item.dart';
// export 'src/components/toggle_group/toggle_group_orientation.dart';
```

to:

```dart
export 'src/components/switch_2/switch_2.dart';
export 'src/components/switch_2/switch_2_variants.dart';
// export 'src/components/switch/switch.dart';
// export 'src/components/textarea/textarea.dart';
// export 'src/components/toggle/toggle.dart';
// export 'src/components/toggle/toggle_interaction_state.dart';
// export 'src/components/toggle/toggle_size.dart';
// export 'src/components/toggle/toggle_variant.dart';
export 'src/components/toggle_2/toggle_2.dart';
export 'src/components/toggle_2/toggle_2_variants.dart';
// export 'src/components/toggle_group/toggle_group.dart';
// export 'src/components/toggle_group/toggle_group_item.dart';
// export 'src/components/toggle_group/toggle_group_orientation.dart';
```

(Leave the commented-out legacy `toggle/`/`toggle_group/` lines as-is — they
stay commented out during the migration, same as every other legacy
component in this file.)

- [ ] **Step 2: Verify the whole package analyzes cleanly**

Run: `fvm flutter analyze lib/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "feat(toggle): export DsToggle from ui.dart"
```

---

### Task 5: Catalog showcase spec + registration

**Files:**
- Create: `example/lib/catalog/specs/toggle_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsToggle`, `DsToggleVariant`, `DsToggleSize` (via `package:ui/ui.dart`), `ComponentShowcaseSpec` (`example/lib/catalog/component_showcase_spec.dart`, already exists — `title`, `variantsBuilder`, `sizesBuilder`, `statesBuilder` fields, all `List<Widget> Function()?`).
- Produces: `ComponentShowcaseSpec buildToggle2ShowcaseSpec()`, registered under `'Toggle 2'` in `componentRegistry`.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToggle2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle 2',
    variantsBuilder: () => DsToggleVariant.values
        .map(
          (variant) => DsToggle(
            label: variant.name,
            variant: variant,
            selected: false,
            onChanged: _noop,
          ),
        )
        .toList(),
    sizesBuilder: () => DsToggleSize.values
        .map(
          (size) => DsToggle(
            label: size.name,
            size: size,
            selected: false,
            onChanged: _noop,
          ),
        )
        .toList(),
    // Selected/disabled are driven by real constructor flags, same as every
    // other showcase spec — but unlike DsButton (whose key interactive
    // feedback lives entirely inside its Remix widget), DsToggle's on/off
    // visual signal is driven by the caller-owned `selected` prop. A static
    // `selected` value would never visibly toggle on tap, so the two
    // enabled entries below are wrapped in `_InteractiveToggle`, a minimal
    // `StatefulWidget` that owns local state and demonstrates the
    // controlled-widget contract every real caller has to implement — same
    // pattern `switch_2_showcase_spec.dart` uses for `_InteractiveSwitch`.
    // Hover/pressed/focus remain transient and Naked-driven, verified
    // interactively in the running app.
    statesBuilder: () => [
      const _InteractiveToggle(initialSelected: true),
      const _InteractiveToggle(initialSelected: false),
      const DsToggle(
        label: 'disabled (selected)',
        selected: true,
        onChanged: null,
        enabled: false,
      ),
      const DsToggle(
        label: 'disabled (unselected)',
        selected: false,
        onChanged: null,
        enabled: false,
      ),
      _InteractiveToggle(
        initialSelected: false,
        icon: PhosphorIcons.textB(),
      ),
      _InteractiveToggle(
        initialSelected: false,
        label: 'Bold',
        icon: PhosphorIcons.textB(),
      ),
    ],
  );
}

void _noop(bool _) {}

/// Owns local on/off state for a single showcased [DsToggle], so the
/// catalog page can demonstrate real toggling. [DsToggle] itself holds no
/// internal state — see [DsToggle.selected]'s doc comment — so any caller
/// wanting live interaction (this showcase included) must do the same:
/// track `selected` externally and update it from [DsToggle.onChanged].
class _InteractiveToggle extends StatefulWidget {
  const _InteractiveToggle({
    required this.initialSelected,
    this.label = 'Label',
    this.icon,
  });

  final bool initialSelected;
  final String? label;
  final IconData? icon;

  @override
  State<_InteractiveToggle> createState() => _InteractiveToggleState();
}

class _InteractiveToggleState extends State<_InteractiveToggle> {
  late bool _selected = widget.initialSelected;

  @override
  Widget build(BuildContext context) {
    return DsToggle(
      selected: _selected,
      label: widget.label,
      icon: widget.icon,
      onChanged: (value) => setState(() => _selected = value),
    );
  }
}
```

- [ ] **Step 2: Register it in `component_registry.dart`**

In `example/lib/catalog/component_registry.dart`, change:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
import 'specs/switch_2_showcase_spec.dart';
```

to:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
import 'specs/switch_2_showcase_spec.dart';
import 'specs/toggle_2_showcase_spec.dart';
```

and change:

```dart
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button 2': buildButton2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
  'Switch 2': buildSwitch2ShowcaseSpec,
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
  'Toggle 2': buildToggle2ShowcaseSpec,
};
```

- [ ] **Step 3: Analyze the example app**

Run: `cd example && fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Visually verify in the running catalog app**

Run: `cd example && fvm flutter run -d macos` (or any available desktop/simulator device — check `fvm flutter devices` first if `macos` isn't available).

In the running app, open the "Toggle 2" entry from the catalog home page and confirm:
- The two variants (`ghost`, `outline`) render with visibly different resting silhouettes — `outline` has a visible border at rest, `ghost` doesn't.
- The three sizes render with visibly different padding/text/icon sizes.
- Clicking an enabled toggle flips its selected state, showing the accent background/foreground color change.
- Both `disabled` entries render muted/dimmed and do not respond to clicks.
- The icon-only entry renders just the icon (no visible label); the label+icon entry renders both side by side.

Stop the app afterward (`q` in the terminal running `flutter run`, or close the window).

- [ ] **Step 5: Commit**

```bash
git add example/lib/catalog/specs/toggle_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(toggle): add Toggle 2 catalog showcase"
```

---

## Self-Review Notes

- **Spec coverage:** file structure (Tasks 1–3), `DsToggleVariant`/`DsToggleSize` enums with `ghost`/`outline` and `sm`/`md`/`lg` naming (Task 1), style resolver built on `FortalToggleStyles.base()` + variant color fragments + `.wrap(opacity)` disabled state (Task 2), single-icon-slot `label`/`icon` assert and nullable `onChanged` → `_isEnabled` forwarding contract (Task 3), `ui.dart` export (Task 4), catalog registration with variant/size/state coverage including icon-only and label+icon states (Task 5) — all covered. Leading/trailing icon pair, `standard` variant alias, and legacy `Toggle`/`toggle_group` migration are explicitly out of scope and not tasked.
- **Placeholder scan:** no TBD/TODO; every step has literal code or an exact command with expected output.
- **Type consistency:** `DsToggleVariant`/`DsToggleSize` (Task 1) used identically in Task 2's `resolveDsToggleStyle` signature, Task 3's `DsToggle.variant`/`.size` fields, and Task 5's `.values` iterations. `resolveDsToggleStyle({required DsToggleVariant variant, required DsToggleSize size, required bool disabled})` (Task 2) matches its one call site in Task 3's `build()` (`disabled: !_isEnabled`). `RemixToggleStyle`/`RemixToggleSpec`/`RemixToggle`/`FortalToggleStyles`/`FortalToggleSize` names and constructor params (`selected`, `onChanged`, `enabled`, `label`, `icon`, `enableFeedback`, `focusNode`, `autofocus`, `semanticLabel`, `mouseCursor`, `style`, `styleSpec`) match the installed `remix` package's public API (verified against `~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/toggle/toggle_widget.dart`, `toggle_style.dart`, and `fortal_toggle_styles.dart`).
