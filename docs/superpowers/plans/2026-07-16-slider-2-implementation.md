# Slider 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsSlider`, a thin wrapper around `package:remix`'s `RemixSlider`, replacing the legacy `AppSlider` per `docs/superpowers/specs/2026-07-16-slider-2-component-design.md`.

**Architecture:** Three files under `lib/src/components/slider_2/` (widget, style resolver as a `part of`, size enum), exported from `lib/ui.dart`, plus a catalog showcase spec registered in `example/lib/catalog/component_registry.dart`. No new tests directory exists for `_2` components in this repo — verification is `flutter analyze` + running the catalog app, matching how `button_2`/`input_2`/`switch_2` were verified.

**Tech Stack:** Flutter, `package:remix` (`RemixSlider`, `RemixSliderStyle`), `package:mix` (`BoxStyler`, `BorderSideMix`, `WidgetModifierConfig`), this repo's semantic tokens (`lib/src/tokens/semantic/colors.dart`).

## Global Constraints

- Package root is `/Users/eakl/dev/projects/roojai` (the `ui` package); the example/catalog app lives in `/Users/eakl/dev/projects/roojai/example` as its own Flutter package that depends on `ui` via a path dependency. Run `flutter analyze`/`flutter pub get` from whichever directory a task's files live in.
- `DsSliderSize` has exactly three values: `sm`, `md`, `lg` — no variant enum (see spec's "Out of scope").
- Range/fill color is `$accentUi()` (not a neutral token) — confirmed deliberate divergence in the spec, do not "fix" it to match `input_2`/`switch_2`'s neutral look.
- `md` size must render with an 18×18 thumb and 4px track/range thickness — this matches legacy `AppSlider`'s only size exactly.
- Disabled state uses `.wrap(WidgetModifierConfig.opacity(0.5))`, not per-color muting.
- No `semanticLabel`/`semanticHint`/`width` params on `DsSlider` — see spec for why.

---

### Task 1: `DsSliderSize` enum

**Files:**
- Create: `lib/src/components/slider_2/slider_2_variants.dart`

**Interfaces:**
- Produces: `enum DsSliderSize { sm, md, lg }`, consumed by Task 2 (widget) and Task 3 (style resolver).

- [ ] **Step 1: Write the file**

```dart
enum DsSliderSize { sm, md, lg }
```

- [ ] **Step 2: Verify it parses**

Run (from `/Users/eakl/dev/projects/roojai`): `dart format --output=none --set-exit-if-changed lib/src/components/slider_2/slider_2_variants.dart`
Expected: exits 0, no output (already correctly formatted).

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/slider_2/slider_2_variants.dart
git commit -m "feat(slider_2): add DsSliderSize enum"
```

---

### Task 2: `resolveDsSliderStyle` style resolver

**Files:**
- Create: `lib/src/components/slider_2/slider_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsSliderSize` from Task 1 (`slider_2_variants.dart`); semantic token accessors `$surfaceAlternative`, `$accentUi`, `$surfaceDefault`, `$borderStrong` from `lib/src/tokens/semantic/colors.dart` (already exported wherever `slider_2.dart`'s `import` brings them in — see Task 3).
- Produces: `RemixSliderStyle resolveDsSliderStyle({required DsSliderSize size, required bool disabled})`, consumed by Task 3 (`DsSlider.build`).

This file is a `part of 'slider_2.dart'` (not a standalone library) — it cannot be analyzed in isolation until Task 3 creates `slider_2.dart` with the matching `part 'slider_2_style_resolver.dart';` directive. Write this file now; verification happens at the end of Task 3.

- [ ] **Step 1: Write the resolver**

```dart
part of 'slider_2.dart';

// Style resolver for DsSlider.
//
// Single entry point `resolveDsSliderStyle` builds one `RemixSliderStyle` by
// merging fragments — base, then size, then disabled state — mirroring the
// base/size/state composition in `switch_2_style_resolver.dart` (no variant
// fragment: DsSlider has no visual-skin axis, same decision `input_2` and
// `switch_2` made — see the design spec's "DsSliderSize" section).

/// Resolves the full `RemixSliderStyle` for a [DsSlider], given its [size]
/// and current [disabled] state.
///
/// Order of composition: base track/range/thumb colors, then size
/// (thumb dimensions + track/range thickness), then disabled. Later merges
/// win on overlapping properties, so `stateStyle` — applied last — always
/// has final say, mirroring `resolveDsButtonStyle`'s "disabled always wins"
/// comment.
RemixSliderStyle resolveDsSliderStyle({
  required DsSliderSize size,
  required bool disabled,
}) {
  // Track color and thumb ring treatment are a direct port of legacy
  // `AppSlider`'s `_resolveTrackColor`/`_resolveThumbRingColor`
  // (`colors.surface.alternative` -> `$surfaceAlternative`, `colors.surface.
  // base` -> `$surfaceDefault` thumb fill). Range/fill color is
  // `$accentUi()` — a deliberate divergence from legacy's neutral
  // `colors.surface.inverted` fill, confirmed during design (see spec's
  // style-resolver notes).
  final baseStyle = RemixSliderStyle()
      .trackColor($surfaceAlternative())
      .rangeColor($accentUi())
      .thumb(
        BoxStyler()
            .color($surfaceDefault())
            .shapeCircle(
              side: BorderSideMix()
                  .color($borderStrong())
                  .strokeAlign(BorderSide.strokeAlignOutside),
            ),
      );

  // `md` matches legacy `AppSlider`'s only size (18px thumb, 4px track)
  // exactly, so the default size renders identically to the widget it
  // replaces. `sm`/`lg` scale down/up from there.
  final sizeStyle = switch (size) {
    DsSliderSize.sm => RemixSliderStyle(
        thumb: BoxStyler().size(14, 14),
        trackWidth: 3,
        rangeWidth: 3,
      ),
    DsSliderSize.md => RemixSliderStyle(
        thumb: BoxStyler().size(18, 18),
        trackWidth: 4,
        rangeWidth: 4,
      ),
    DsSliderSize.lg => RemixSliderStyle(
        thumb: BoxStyler().size(22, 22),
        trackWidth: 5,
        rangeWidth: 5,
      ),
  };

  // Disabled wins over every other state — a disabled slider never shows
  // brighter feedback regardless of value, matching `resolveDsButtonStyle`'s
  // equivalent comment. Opacity wrap is the established `_2`-migration
  // convention (`button_2`/`switch_2`), replacing legacy `AppSlider`'s
  // separate muted-fill-color approach.
  final stateStyle = disabled
      ? RemixSliderStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSliderStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

- [ ] **Step 2: Commit** (bundled with Task 3, since this file can't compile standalone — see Task 3's commit step)

---

### Task 3: `DsSlider` widget

**Files:**
- Create: `lib/src/components/slider_2/slider_2.dart`

**Interfaces:**
- Consumes: `DsSliderSize` (Task 1), `resolveDsSliderStyle` (Task 2, via `part` directive), `RemixSlider`/`RemixSliderStyle`/`RemixSliderSpec` from `package:remix`.
- Produces: `class DsSlider extends StatelessWidget` with constructor `DsSlider({Key? key, required double value, required ValueChanged<double>? onChanged, double min = 0.0, double max = 1.0, ValueChanged<double>? onChangeStart, ValueChanged<double>? onChangeEnd, DsSliderSize size = DsSliderSize.md, bool enabled = true, bool enableHapticFeedback = true, int? snapDivisions, FocusNode? focusNode, bool autofocus = false, RemixSliderStyle style = const RemixSliderStyle.create(), RemixSliderSpec? styleSpec})`, consumed by Task 4 (catalog spec) and Task 5 (`ui.dart` export).

- [ ] **Step 1: Write the widget**

```dart
import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import 'slider_2_variants.dart';

// The `resolveDsSliderStyle` function consumed by `build()` below lives in
// slider_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsSlider while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'slider_2_style_resolver.dart';

/// A continuous-value drag control built on top of the `remix` package's
/// [RemixSlider], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `AppSlider`, [DsSlider] delegates all
/// interaction handling (drag/tap, haptics, focus, semantics) to
/// [RemixSlider] and only supplies a resolved [RemixSliderStyle] — see
/// [resolveDsSliderStyle] — for [size] and the disabled state.
class DsSlider extends StatelessWidget {
  const DsSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.onChangeStart,
    this.onChangeEnd,
    this.size = DsSliderSize.md,
    this.enabled = true,
    this.enableHapticFeedback = true,
    this.snapDivisions,
    this.focusNode,
    this.autofocus = false,
    this.style = const RemixSliderStyle.create(),
    this.styleSpec,
  });

  /// The slider's current value. Always reflects the caller's state — this
  /// widget holds no internal value of its own. Must fall within
  /// [min]..[max] (asserted by the underlying [RemixSlider]).
  final double value;

  /// Called during drag (and on track tap) with the new value. Ignored
  /// (and the slider rendered non-interactive) while [enabled] is false, or
  /// when null.
  final ValueChanged<double>? onChanged;

  /// The lower bound of the slider's range.
  final double min;

  /// The upper bound of the slider's range.
  final double max;

  /// Called when the user starts dragging the thumb.
  final ValueChanged<double>? onChangeStart;

  /// Called when the user is done dragging the thumb.
  final ValueChanged<double>? onChangeEnd;

  /// Physical size — see [DsSliderSize].
  final DsSliderSize size;

  /// Public state: disables drag/tap/focus and renders a dimmed slider when
  /// false. [value] still governs thumb position while disabled, so the
  /// slider keeps communicating where it's set. Never inferred — always
  /// driven by this constructor param.
  final bool enabled;

  /// Whether to provide haptic feedback during value changes.
  final bool enableHapticFeedback;

  /// Optional interaction-only step snapping — the thumb snaps to this many
  /// discrete steps between [min] and [max], but no visual tick marks are
  /// rendered (matches [RemixSlider.snapDivisions]'s own doc comment).
  final int? snapDivisions;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixSlider]/`NakedSlider`.
  final FocusNode? focusNode;

  /// Whether this slider should request focus when first built.
  final bool autofocus;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsSliderStyle]'s output).
  final RemixSliderStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixSliderSpec] directly, bypassing style resolution entirely.
  final RemixSliderSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSliderStyle(
      size: size,
      disabled: !enabled,
    ).merge(style);

    return RemixSlider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      enabled: enabled,
      enableHapticFeedback: enableHapticFeedback,
      snapDivisions: snapDivisions,
      focusNode: focusNode,
      autofocus: autofocus,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
```

- [ ] **Step 2: Run static analysis to verify Tasks 1-3 compile together**

Run (from `/Users/eakl/dev/projects/roojai`): `flutter analyze lib/src/components/slider_2/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/slider_2/slider_2.dart lib/src/components/slider_2/slider_2_style_resolver.dart
git commit -m "feat(slider_2): add DsSlider widget and style resolver"
```

---

### Task 4: Export `DsSlider` from `ui.dart`

**Files:**
- Modify: `lib/ui.dart:75` (currently `// export 'src/components/slider/slider.dart';`)

**Interfaces:**
- Consumes: `DsSlider`, `DsSliderSize` (Tasks 1 & 3).
- Produces: public exports `package:ui/ui.dart` showing `DsSlider`/`DsSliderSize`, consumed by Task 5 (catalog spec).

- [ ] **Step 1: Add the two export lines directly above the commented-out legacy export**

In `lib/ui.dart`, find this line (currently line 75):

```dart
// export 'src/components/slider/slider.dart';
```

Replace it with:

```dart
export 'src/components/slider_2/slider_2.dart';
export 'src/components/slider_2/slider_2_variants.dart';
// export 'src/components/slider/slider.dart';
```

- [ ] **Step 2: Run static analysis on the whole `ui` package**

Run (from `/Users/eakl/dev/projects/roojai`): `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "feat(slider_2): export DsSlider from ui.dart"
```

---

### Task 5: Catalog showcase spec

**Files:**
- Create: `example/lib/catalog/specs/slider_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsSlider`, `DsSliderSize` (via `package:ui/ui.dart`, Task 4); `ComponentShowcaseSpec` from `../component_showcase_spec.dart` (existing file, unmodified).
- Produces: `ComponentShowcaseSpec buildSlider2ShowcaseSpec()`, registered under the key `'Slider 2'` in `componentRegistry`.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSlider2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Slider 2',
    sizesBuilder: () => DsSliderSize.values
        .map(
          (size) => DsSlider(
            value: 0.5,
            onChanged: (_) {},
            size: size,
          ),
        )
        .toList(),
    // Public state (enabled/disabled) is driven by the real `enabled`
    // constructor flag. Drag/focus-visible states are transient and
    // Naked-driven, so verify them interactively in the running catalog
    // app instead (drag any enabled slider below).
    statesBuilder: () => [
      DsSlider(value: 0.25, onChanged: (_) {}),
      DsSlider(value: 0.75, onChanged: (_) {}),
      const DsSlider(value: 0.5, onChanged: null, enabled: false),
      DsSlider(value: 0.0, onChanged: (_) {}),
      DsSlider(value: 1.0, onChanged: (_) {}),
      DsSlider(value: 0.5, onChanged: (_) {}, snapDivisions: 4),
    ],
  );
}
```

- [ ] **Step 2: Register the spec**

In `example/lib/catalog/component_registry.dart`, add the import alphabetically among the existing `specs/*_showcase_spec.dart` imports (after `separator_2`, before `skeleton_2`):

```dart
import 'specs/separator_2_showcase_spec.dart';
import 'specs/skeleton_2_showcase_spec.dart';
```

becomes:

```dart
import 'specs/separator_2_showcase_spec.dart';
import 'specs/skeleton_2_showcase_spec.dart';
import 'specs/slider_2_showcase_spec.dart';
```

Wait — `slider_2` sorts after `skeleton_2` alphabetically (`sk` < `sl`), so insert after `skeleton_2_showcase_spec.dart` instead:

```dart
import 'specs/skeleton_2_showcase_spec.dart';
import 'specs/slider_2_showcase_spec.dart';
import 'specs/spinner_2_showcase_spec.dart';
```

And add the registry entry alphabetically in the `componentRegistry` map (between `'Skeleton 2'` and `'Spinner 2'`):

```dart
  'Skeleton 2': buildSkeleton2ShowcaseSpec,
  'Slider 2': buildSlider2ShowcaseSpec,
  'Spinner 2': buildSpinner2ShowcaseSpec,
```

- [ ] **Step 3: Run static analysis on the example app**

Run (from `/Users/eakl/dev/projects/roojai/example`): `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Launch the catalog app and visually verify**

Run (from `/Users/eakl/dev/projects/roojai/example`): `flutter run -d macos` (or any available desktop/web device)
Navigate to the "Slider 2" entry in the catalog. Confirm:
- Three sizes render with visibly increasing thumb/track scale, all at 50% fill.
- States row shows: two enabled sliders at different fill levels, one visibly dimmed disabled slider, one at minimum (thumb at far left, no accent fill), one at maximum (thumb at far right, full accent fill), one with 4-step snap divisions.
- Dragging an enabled slider's thumb updates its position live.
- The accent-colored range/fill is visually distinct from the neutral track.

Stop the app after verifying (`q` in the terminal running `flutter run`, or close the window).

- [ ] **Step 5: Commit**

```bash
git add example/lib/catalog/specs/slider_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(slider_2): add catalog showcase spec"
```

---

## Post-plan checklist

- [ ] `flutter analyze` clean in both `/Users/eakl/dev/projects/roojai` and `/Users/eakl/dev/projects/roojai/example`.
- [ ] Catalog app visually verified per Task 5 Step 4.
- [ ] All 5 tasks committed as separate commits.
