# Input 2 (DsInput) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsInput`, a text-only single-line input built on Remix's `RemixTextField`, styled through this design system's Mix semantic tokens — following the same structure as `button_2`/`DsButton`.

**Architecture:** `DsInput` is a thin `StatelessWidget` wrapper delegating all text-editing/IME/focus mechanics to `RemixTextField`. A single `resolveDsInputStyle()` entry point (in a `part` file) composes a `RemixTextFieldStyle` from base + size + error fragments. Leading/trailing icons render through the DS `Icon` widget (`icon_2`), not raw widgets, with a builder escape hatch.

**Tech Stack:** Flutter (`package:flutter/widgets.dart`), `package:remix/remix.dart` (`RemixTextField`/`RemixTextFieldStyle`), `package:mix/mix.dart` (tokens/`TextStyler`/`EdgeInsetsGeometryMix`), this package's `icon_2` component.

## Global Constraints

- Package is managed via FVM; use `fvm flutter analyze` and `fvm flutter run` (not bare `flutter`/`dart`), consistent with `.fvm/fvm_config.json` (Flutter 3.19.0 SDK... actual resolved version 3.41.9 per `fvm flutter --version`).
- No `test/` directory exists in this package — `button_2`/`icon_container_2` shipped without automated widget tests. Verification here is `fvm flutter analyze` (must report "No issues found!") plus visual confirmation in the running `example` catalog app — do not invent a `test/` directory or test framework not already in use.
- Follow the exact file-splitting convention used by `button_2`: main widget file + `part of` style-resolver file + separate variants-enum file (no single monolithic file).
- Match existing widget doc-comment density and style (see `button_2.dart`, `icon_container.dart`) — explain *why*, not *what*.
- No `DsInputVariant` enum, no file-drop variant, no multiline/textarea support — out of scope per `docs/superpowers/specs/2026-07-14-input-2-component-design.md`.
- `error` and `enabled` are always explicit constructor flags, never inferred from focus/hover state.

---

### Task 1: `DsInputSize` enum

**Files:**
- Create: `lib/src/components/input_2/input_2_variants.dart`

**Interfaces:**
- Produces: `enum DsInputSize { sm, md, lg }` — consumed by Tasks 2 and 3.

- [ ] **Step 1: Write the enum file**

```dart
enum DsInputSize { sm, md, lg }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm flutter analyze lib/src/components/input_2/input_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/input_2/input_2_variants.dart
git commit -m "feat(input): add DsInputSize enum"
```

---

### Task 2: Style resolver — `resolveDsInputStyle`

**Files:**
- Create: `lib/src/components/input_2/input_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsInputSize` (Task 1). Semantic tokens from `lib/src/tokens/semantic/colors.dart`, `radius.dart`, `spacing.dart`, `typography.dart` (already exist in this repo — no changes needed there).
- Produces: `RemixTextFieldStyle resolveDsInputStyle({required DsInputSize size, required bool error})` — consumed by Task 3.

This file is a `part of 'input_2.dart'`, so it cannot be analyzed standalone until Task 3 creates the library file. Steps below create the file now; the analyze check happens at the end of Task 3, once both files exist together. This is called out explicitly so the step doesn't look skipped.

- [ ] **Step 1: Write the resolver file**

```dart
part of 'input_2.dart';

// Style resolver for DsInput.
//
// Single entry point `resolveDsInputStyle` builds one `RemixTextFieldStyle`
// by merging fragments — base, then size, then error state — mirroring the
// base/size/variant/state composition in `button_2_style_resolver.dart`
// (minus the variant fragment: DsInput has no visual-skin axis, see the
// design spec's "Variant axis" decision).

/// Resolves the full `RemixTextFieldStyle` for a [DsInput], given its
/// [size] and current [error] state.
///
/// Order of composition: base metrics/colors/focus-disabled states, then
/// size (padding/typography), then error. Later merges win on overlapping
/// properties, so `stateStyle` — applied last — always has final say (e.g.
/// an errored field's red border wins over the size fragment, which sets
/// no border color of its own).
RemixTextFieldStyle resolveDsInputStyle({
  required DsInputSize size,
  required bool error,
}) {
  // Focus/disabled use Remix's own `.onFocused()`/`.onDisabled()`
  // widget-state variant helpers (from `WidgetStateVariantMixin`, mixed
  // into `RemixTextFieldStyle` via `RemixFlexContainerStyle`) — Naked's
  // `NakedTextFieldState` already derives these live, so (unlike the
  // legacy `Input`) this widget never needs to track a `FocusNode`
  // listener itself.
  final baseStyle = RemixTextFieldStyle()
      .borderRadiusAll($radius008())
      .borderAll(color: $borderDefault(), width: 1)
      .backgroundColor($surfaceDefault())
      .color($contentPrimary())
      .hintColor($contentPlaceholder())
      .cursorColor($surfaceInverted())
      .onFocused(
        RemixTextFieldStyle().borderAll(color: $surfaceInverted(), width: 1),
      )
      .onDisabled(
        RemixTextFieldStyle()
            .backgroundColor($surfaceAlternative())
            .color($contentMuted())
            .hintColor($contentMuted()),
      );

  final sizeStyle = switch (size) {
    DsInputSize.sm => RemixTextFieldStyle(
        text: TextStyler(style: $bodySm.mix()),
        hintText: TextStyler(style: $bodySm.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelSm.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing006())
        .spacing($spacing004()),
    DsInputSize.md => RemixTextFieldStyle(
        text: TextStyler(style: $bodyMd.mix()),
        hintText: TextStyler(style: $bodyMd.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing008())
        .spacing($spacing004()),
    DsInputSize.lg => RemixTextFieldStyle(
        text: TextStyler(style: $bodyLg.mix()),
        hintText: TextStyler(style: $bodyLg.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing016())
        .paddingY($spacing012())
        .spacing($spacing006()),
  };

  // `error` has no built-in `.onError()` helper on `RemixTextFieldStyle`
  // (`WidgetStateVariantMixin` only ships hovered/pressed/focused/disabled/
  // enabled) — it's a plain top-level merge instead, driven by the same
  // explicit `error` bool the widget also forwards to
  // `RemixTextField.error` directly. See the design spec's "Style
  // resolver" section for the full rationale.
  final stateStyle = error
      ? RemixTextFieldStyle().borderAll(color: $negativeBorder(), width: 1)
      : RemixTextFieldStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/src/components/input_2/input_2_style_resolver.dart
git commit -m "feat(input): add DsInput style resolver"
```

---

### Task 3: `DsInput` widget

**Files:**
- Create: `lib/src/components/input_2/input_2.dart`

**Interfaces:**
- Consumes: `DsInputSize` (Task 1), `resolveDsInputStyle` (Task 2), DS `Icon` widget from `lib/src/components/icon_2/icon.dart` (constructor `Icon(IconData glyph, {DsIconVariant variant, DsIconSize size, IconStyler? style})`).
- Produces: `class DsInput extends StatelessWidget` — consumed by Task 4 (export) and Task 5 (catalog spec).

- [ ] **Step 1: Write the widget file**

```dart
import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variants.dart';
import 'input_2_variants.dart';

// The `resolveDsInputStyle` function consumed by `build()` below lives in
// input_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsInput while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'input_2_style_resolver.dart';

/// Maps [DsInput]'s own size enum onto [Icon]'s, so leading/trailing
/// glyphs scale with the field instead of needing a second size prop from
/// callers — same pattern as `IconContainer`'s `_resolveGlyphSize`.
DsIconSize _resolveDsInputIconSize(DsInputSize size) {
  return switch (size) {
    DsInputSize.sm => DsIconSize.sm,
    DsInputSize.md => DsIconSize.md,
    DsInputSize.lg => DsIconSize.lg,
  };
}

/// A single-line text field built on top of the `remix` package's
/// [RemixTextField], styled through the design system's Mix semantic
/// tokens.
///
/// Unlike the legacy hand-rolled `Input`, [DsInput] delegates all
/// interaction handling (focus/hover, IME, selection, semantics) to
/// [RemixTextField] and only supplies a resolved [RemixTextFieldStyle] —
/// see [resolveDsInputStyle] — for [size] and [error].
///
/// Text-only: there is no file-drop or multiline/textarea variant here —
/// see `docs/superpowers/specs/2026-07-14-input-2-component-design.md`
/// for why those are separate future components.
class DsInput extends StatelessWidget {
  const DsInput({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.helperText,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingIconBuilder,
    this.trailingIconBuilder,
    this.size = DsInputSize.md,
    this.error = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticHint,
    this.style = const RemixTextFieldStyle.create(),
    this.styleSpec,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Hint text shown when the field is empty.
  final String? hintText;

  /// Label text shown above the field, styled via [resolveDsInputStyle].
  final String? label;

  /// Helper text shown below the field, styled via [resolveDsInputStyle].
  /// Not shown when [error] is true and no dedicated error message slot
  /// exists — see the design spec's "Label/helper text" decision.
  final String? helperText;

  /// Icon shown at the field's leading edge, rendered through the DS
  /// [Icon] widget. Ignored when [leadingIconBuilder] is set.
  final IconData? leadingIcon;

  /// Icon shown at the field's trailing edge, rendered through the DS
  /// [Icon] widget. Ignored when [trailingIconBuilder] is set.
  final IconData? trailingIcon;

  /// Full override for the leading accessory, bypassing [leadingIcon] and
  /// the default DS-[Icon] rendering entirely.
  final WidgetBuilder? leadingIconBuilder;

  /// Full override for the trailing accessory, bypassing [trailingIcon]
  /// and the default DS-[Icon] rendering entirely.
  final WidgetBuilder? trailingIconBuilder;

  /// Physical size — see [DsInputSize].
  final DsInputSize size;

  /// Public state: renders the negative/error border color. Mirrors the
  /// legacy `Input.invalid` — this widget doesn't validate its own
  /// content, the caller decides when a value is invalid. Never inferred.
  final bool error;

  /// Public state: disables input and renders muted colors when false.
  /// Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to hide the text being edited (e.g. password fields).
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// The maximum number of lines for the text to span. Kept at `1` by
  /// default — multiline entry is out of scope, see class doc.
  final int? maxLines;

  /// The minimum number of lines to occupy.
  final int? minLines;

  /// The maximum number of characters to allow in the field.
  final int? maxLength;

  /// Called on every edit to the field's value.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits editable content (e.g. keyboard's
  /// "done"/"go" action).
  final ValueChanged<String>? onSubmitted;

  /// Called when the user indicates they are done editing.
  final VoidCallback? onEditingComplete;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixTextField]/`NakedTextField`.
  final FocusNode? focusNode;

  /// Whether this field should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [label] when null (same fallback [RemixTextField] applies).
  final String? semanticLabel;

  /// Additional semantic hint. Defaults to [hintText] when null.
  final String? semanticHint;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsInputStyle]'s output).
  final RemixTextFieldStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixTextFieldSpec] directly, bypassing style resolution entirely.
  final RemixTextFieldSpec? styleSpec;

  Widget? _buildLeading(BuildContext context) {
    if (leadingIconBuilder != null) return leadingIconBuilder!(context);
    if (leadingIcon == null) return null;
    return Icon(leadingIcon!, size: _resolveDsInputIconSize(size));
  }

  Widget? _buildTrailing(BuildContext context) {
    if (trailingIconBuilder != null) return trailingIconBuilder!(context);
    if (trailingIcon == null) return null;
    return Icon(trailingIcon!, size: _resolveDsInputIconSize(size));
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsInputStyle(
      size: size,
      error: error,
    ).merge(style);

    return RemixTextField(
      controller: controller,
      hintText: hintText,
      label: label,
      helperText: helperText,
      error: error,
      leading: _buildLeading(context),
      trailing: _buildTrailing(context),
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
```

- [ ] **Step 2: Verify both files analyze cleanly together**

Run: `fvm flutter analyze lib/src/components/input_2/`
Expected: `No issues found!`

If it reports unresolved token/method names (e.g. a typo in a token name or a
Mix API that doesn't match the installed `mix`/`remix` package versions),
open the flagged file at the reported line and cross-check the exact method
name against `button_2_style_resolver.dart` (for token/`RemixButtonStyle`
methods) or the installed package source at
`~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/textfield/textfield_style.dart`
(for `RemixTextFieldStyle` methods) before changing anything.

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/input_2/input_2.dart
git commit -m "feat(input): add DsInput widget"
```

---

### Task 4: Export from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart:41-42` (immediately after the existing `icon_container_2` exports, before the commented-out legacy `input/` block)

**Interfaces:**
- Consumes: `DsInput` (Task 3), `DsInputSize` (Task 1).
- Produces: public exports `ui.DsInput`, `ui.DsInputSize` for Task 5 and any external consumer.

- [ ] **Step 1: Add the two export lines**

In `lib/ui.dart`, change:

```dart
export 'src/components/icon_container_2/icon_container.dart';
export 'src/components/icon_container_2/icon_container_variants.dart';
// export 'src/components/input/input.dart';
```

to:

```dart
export 'src/components/icon_container_2/icon_container.dart';
export 'src/components/icon_container_2/icon_container_variants.dart';
export 'src/components/input_2/input_2.dart';
export 'src/components/input_2/input_2_variants.dart';
// export 'src/components/input/input.dart';
```

(Leave the commented-out legacy `input/` line as-is — it stays commented out during the migration, same as every other legacy component below it.)

- [ ] **Step 2: Verify the whole package analyzes cleanly**

Run: `fvm flutter analyze lib/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "feat(input): export DsInput from ui.dart"
```

---

### Task 5: Catalog showcase spec + registration

**Files:**
- Create: `example/lib/catalog/specs/input_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsInput`, `DsInputSize` (via `package:ui/ui.dart`), `ComponentShowcaseSpec` (`example/lib/catalog/component_showcase_spec.dart`, already exists — `title`, `variantsBuilder`, `sizesBuilder`, `statesBuilder` fields, all `List<Widget> Function()?`).
- Produces: `ComponentShowcaseSpec buildInput2ShowcaseSpec()`, registered under `'Input 2'` in `componentRegistry`.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInput2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input 2',
    sizesBuilder: () => DsInputSize.values
        .map(
          (size) => DsInput(
            hintText: size.name,
            size: size,
          ),
        )
        .toList(),
    // Public states (error/disabled) are driven by their real constructor
    // flags. Focus/hover are handled internally by RemixTextField/Naked
    // and are inherently transient, so verify them interactively in the
    // running app instead (tab-focus or click any enabled field below).
    statesBuilder: () => [
      const DsInput(hintText: 'enabled'),
      const DsInput(hintText: 'disabled', enabled: false),
      const DsInput(hintText: 'error', error: true),
      const DsInput(label: 'Label', hintText: 'with label'),
      const DsInput(
        hintText: 'with helper text',
        helperText: 'Helper text goes here',
      ),
      DsInput(
        hintText: 'with leading icon',
        leadingIcon: PhosphorIcons.magnifyingGlass(),
      ),
      DsInput(
        hintText: 'with trailing icon',
        trailingIcon: PhosphorIcons.x(),
      ),
    ],
  );
}
```

- [ ] **Step 2: Register it in `component_registry.dart`**

In `example/lib/catalog/component_registry.dart`, change:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
```

to:

```dart
import 'component_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
```

and change:

```dart
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button 2': buildButton2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
};
```

to:

```dart
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button 2': buildButton2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
};
```

- [ ] **Step 3: Analyze the example app**

Run: `cd example && fvm flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Visually verify in the running catalog app**

Run: `cd example && fvm flutter run -d macos` (or any available desktop/simulator device — check `fvm flutter devices` first if `macos` isn't available).

In the running app, open the "Input 2" entry from the catalog home page and confirm:
- The three sizes render with visibly different padding/text size.
- `disabled` renders muted/non-interactive.
- `error` renders a red/negative border.
- `with label` shows label text above the field; `with helper text` shows helper text below.
- `with leading icon`/`with trailing icon` show a Phosphor glyph at the respective edge.
- Clicking into an enabled field shows a visible focus border, and typing updates the field.

Stop the app afterward (`q` in the terminal running `flutter run`, or close the window).

- [ ] **Step 5: Commit**

```bash
git add example/lib/catalog/specs/input_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(input): add Input 2 catalog showcase"
```

---

## Self-Review Notes

- **Spec coverage:** file structure (Task 1–3), style resolver base/size/error composition (Task 2), icon-through-DS-Icon with builder override (Task 3), label/helper wiring (Task 3), catalog registration (Task 5), `ui.dart` export (Task 4) — all covered. File-drop/textarea/variant-enum are explicitly out of scope and not tasked.
- **Placeholder scan:** no TBD/TODO; every step has literal code or an exact command with expected output.
- **Type consistency:** `DsInputSize` (Task 1) used identically in Task 2's `resolveDsInputStyle` signature, Task 3's `_resolveDsInputIconSize`/`DsInput.size`, and Task 5's `DsInputSize.values` iteration. `resolveDsInputStyle({required DsInputSize size, required bool error})` (Task 2) matches its one call site in Task 3's `build()`. `RemixTextFieldStyle`/`RemixTextFieldSpec` names match the installed `remix` package's public API (verified against `~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/textfield/`).
