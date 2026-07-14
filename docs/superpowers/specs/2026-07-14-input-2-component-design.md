# `input_2` (`DsInput`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`) and
`icon_container_2`. This spec covers `input_2` (`DsInput`), a thin wrapper
around Remix's `RemixTextField`, replacing the legacy hand-rolled `Input`
widget for single-line text entry.

The legacy `input/` component had two structural variants: a text field and a
dashed-border file-drop target (`InputVariant.text` / `InputVariant.file`).
Remix's `RemixTextField` only covers the text-field case. Per discussion,
`input_2` is **text-only**. The file-drop case and multiline/textarea case
will become their own separate future components (`file_input`, `textarea`),
out of scope here.

## File structure

Mirrors `button_2`:

```
lib/src/components/input_2/
  input_2.dart                 — DsInput widget + doc comments
  input_2_style_resolver.dart  — part of input_2.dart; resolveDsInputStyle()
  input_2_variants.dart        — DsInputSize enum
```

No loading-spinner part file — text fields have no async "loading" concept
analogous to buttons.

## `DsInputSize` (`input_2_variants.dart`)

```dart
enum DsInputSize { sm, md, lg }
```

Matches legacy `InputSize` and `DsButtonSize`. There is no `DsInputVariant`
enum: unlike `DsButton` (which has visual skins — primary/secondary/outline/
ghost/destructive), the legacy `Input` had only one visual look, varying by
size and interaction state. `input_2` keeps that: single style, states only.

## `DsInput` widget API

```dart
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
}
```

- A thin wrapper delegating to `RemixTextField` for all text-editing/IME/
  focus mechanics — the same relationship `DsButton` has to `RemixButton`.
  Widget-level props are a curated subset of `RemixTextField`'s (not the full
  surface), covering what real usage needs (text input, keyboard control,
  length limit); `style`/`styleSpec` are the escape hatch for the rest, same
  as `DsButton`.
- `error` is an explicit bool flag, never inferred — same convention as
  legacy `Input.invalid`. `enabled` is likewise always explicit, never
  derived.
- `leadingIcon`/`trailingIcon` are `IconData`, rendered through the DS `Icon`
  widget (`icon_2`) via a default builder (mirroring `_dsButtonIconBuilder`
  in `button_2.dart`), passed to `RemixTextField.leading`/`.trailing` as
  built widgets. `leadingIconBuilder`/`trailingIconBuilder` are override
  escape hatches for callers needing custom leading/trailing widgets.
- `label`/`helperText` pass straight through to Remix's built-in
  `RemixTextField` slots, styled via the resolver (not left to callers to
  compose with a separate `Label` widget, unlike legacy `Input`).
- No `required` flag, no file-variant, no `onFilePick` — out of scope per the
  text-only decision above.

## Style resolver (`input_2_style_resolver.dart`)

One `resolveDsInputStyle({required DsInputSize size, required bool error})`
entry point, composing fragments merged in order — base, then size, then
error state — mirroring `resolveDsButtonStyle`'s base → size → variant →
state composition (minus the variant fragment, since there is no variant
axis here).

```dart
RemixTextFieldStyle resolveDsInputStyle({
  required DsInputSize size,
  required bool error,
}) {
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
            .borderAll(color: $borderDefault(), width: 1),
      );

  final sizeStyle = switch (size) {
    DsInputSize.sm => RemixTextFieldStyle()
        .padding(EdgeInsetsGeometryMix.symmetric(
          horizontal: $spacing012(),
          vertical: $spacing006(),
        ))
        // + per-size text/hintText/helperText/label TextStylers using
        // $bodySm/$labelSm tokens
        ,
    DsInputSize.md => RemixTextFieldStyle()
        .padding(EdgeInsetsGeometryMix.symmetric(
          horizontal: $spacing012(),
          vertical: $spacing008(),
        ))
        // + $bodyMd/$labelMd tokens
        ,
    DsInputSize.lg => RemixTextFieldStyle()
        .padding(EdgeInsetsGeometryMix.symmetric(
          horizontal: $spacing016(),
          vertical: $spacing012(),
        ))
        // + $bodyLg/$labelMd tokens
        ,
  };

  final stateStyle = error
      ? RemixTextFieldStyle().borderAll(color: $negativeBorder(), width: 1)
      : RemixTextFieldStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

Notes:

- Focus/disabled use Remix's own `.onFocused()`/`.onDisabled()` state-variant
  helpers (built into `RemixTextFieldStyle`'s base class, confirmed in
  Remix's own `fortal_textfield_styles.dart`), not hand-tracked `FocusNode`
  state like legacy `Input` — Remix/Naked already derives these live via
  `NakedTextFieldState`.
- `error` has no built-in `.onError()` helper in Mix (`WidgetStateVariantMixin`
  only provides `onHovered`/`onPressed`/`onFocused`/`onDisabled`/`onEnabled`).
  It's applied as a plain top-level style merge driven by the widget's own
  `error` bool, consistent with `error` already being an explicit constructor
  flag (not a derived interaction state) that's also passed straight through
  to `RemixTextField.error`.
- Border/background/content color tokens mirror the legacy resolver's
  mapping (`colors.border.base` → `$borderDefault`, `colors.surface.inverted`
  focus color → `$surfaceInverted`, `colors.negative.border` invalid color →
  `$negativeBorder`), translated to the new semantic token set.
- Corner radius stays constant across sizes (`$radius008`, same as
  `DsButton`), matching the legacy resolver's approach of a per-size switch
  that currently returns one constant.

## Catalog registration

Add `example/lib/catalog/specs/input_2_showcase_spec.dart`, mirroring
`button_2_showcase_spec.dart`:

- `sizesBuilder`: one `DsInput` per `DsInputSize`, static `hintText`.
- `statesBuilder`: `enabled`, `disabled`, `error`, `with label`, `with helper
  text`, `with leading icon`, `with trailing icon`.
- No `variantsBuilder` — there is no variant axis.
- Focus/hover states are transient and Naked-driven; verified interactively
  in the running catalog app, same caveat noted in the button spec.

Register the new spec in `example/lib/catalog/component_registry.dart`, and
export `input_2/input_2.dart` + `input_2/input_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`icon_container_2`.

## Out of scope

- File-drop variant (dashed border, `onFilePick`) — future `file_input`
  component.
- Multiline/textarea support — future `textarea` component.
- `DsInputVariant` visual-skin enum — no precedent from legacy `Input`;
  single style only for now.
