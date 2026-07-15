# `select_2` (`DsSelect`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`),
`input_2` (`DsInput` wrapping `RemixTextField`), and `switch_2` (`DsSwitch`
wrapping `RemixSwitch`). This spec covers `select_2` (`DsSelect`), a thin
wrapper around Remix's `RemixSelect<T>`, replacing the legacy hand-rolled
`AppSelect` widget (`lib/src/components/select/select.dart`, a
`CompositedTransformTarget`/`OverlayEntry` dropdown built from scratch).

The installed `remix` version is `0.2.0` (pinned in `pubspec.yaml`), which
differs from the "Styler"-suffixed API shown on the live docs.page/btwld/remix
site (a newer/dev version). This spec follows the actual installed API
(`RemixSelectStyle`/`RemixSelectTriggerStyle`/`RemixSelectMenuItemStyle`, no
`RemixSelect.styleSpec` param, no `RemixSelectStyle.item()` default-item-style
setter — verified directly against
`package:remix/src/components/select/{select_widget,select_style,select_spec}.dart`
in the pub cache) rather than the docs site.

## File structure

Mirrors `button_2`/`input_2`/`switch_2`:

```
lib/src/components/select_2/
  select_2.dart                 — DsSelect<T> widget + doc comments
  select_2_style_resolver.dart  — part of select_2.dart; resolveDsSelectStyle()
                                   + resolveDsSelectItemStyle()
  select_2_variants.dart        — DsSelectSize enum
```

No loading-spinner part file (no async "loading" concept for a select, same
reasoning as `input_2`/`switch_2`).

## `DsSelectSize` (`select_2_variants.dart`)

```dart
enum DsSelectSize { sm, md, lg }
```

Matches `DsButtonSize`/`DsInputSize`/`DsSwitchSize`. The legacy `AppSelect` had
a single fixed size; `md` becomes that default, with `sm`/`lg` added for
consistency with the rest of the `_2` family.

There is no `DsSelectVariant` enum: like `DsInput`/`DsSwitch`, the legacy
`AppSelect` had only one visual look (trigger + menu, states only), so
`select_2` keeps that — single style, states only.

## `DsSelect<T>` widget API

```dart
class DsSelect<T> extends StatelessWidget {
  const DsSelect({
    super.key,
    required this.items,
    this.selectedValue,
    this.placeholder = 'Select…',
    this.leadingIcon,
    this.onChanged,
    this.onOpen,
    this.onClose,
    this.size = DsSelectSize.md,
    this.error = false,
    this.enabled = true,
    this.closeOnSelect = true,
    this.targetAnchor,
    this.followerAnchor,
    this.focusNode,
    this.semanticLabel,
    this.style = const RemixSelectStyle.create(),
  });
}
```

- A thin wrapper delegating to `RemixSelect<T>` for all interaction handling
  (open/close overlay, hover/press/focus on trigger and items, keyboard
  navigation, semantics), same relationship `DsButton`/`DsInput` have to
  their Remix counterparts.
- `items` reuses Remix's own `RemixSelectItem<T>` data class directly rather
  than introducing a parallel `DsSelectItem<T>` — same precedent as
  `DsButton` reusing `RemixButtonTextBuilder`/`RemixButtonIconBuilder`
  directly instead of re-wrapping them. Each `RemixSelectItem.style` is
  merged *on top of* `DsSelect`'s own resolved per-item style (see below),
  so it still works as a row-level override, matching the upstream
  `RemixSelectItem.style` contract.
- `selectedValue`/`onChanged` mirror `RemixSelect`'s own naming exactly
  (unlike `DsSwitch.selected`, there's no legacy `AppSelect` naming
  collision to resolve — `AppSelect` already used `selected`/`onChanged` for
  the same concepts, so no rename needed).
- `placeholder` + `leadingIcon` replace constructing a `RemixSelectTrigger`
  by hand — `DsSelect.build()` assembles
  `RemixSelectTrigger(placeholder: placeholder, icon: leadingIcon)` itself.
  This keeps `DsSelect`'s own top-level API flat (no nested trigger object
  the caller has to build), same flattening `DsInput` does for
  leading/trailing icons vs `RemixTextField`'s own accessory slots.
- `error` is public state, never inferred — same convention as
  `DsInput.error`/legacy `AppSelect.invalid` (renamed to match `DsInput`'s
  `error` naming, since both are "this value is invalid" signals on a form
  field).
- `enabled` is likewise always explicit, never derived — same as
  `DsButton`/`DsInput`/`DsSwitch`. Forwarded straight through to
  `RemixSelect.enabled`.
- `closeOnSelect`, `onOpen`, `onClose`, `targetAnchor`, `followerAnchor`,
  `focusNode`, `semanticLabel` all forward directly to the identically-named
  `RemixSelect` params — no renaming or flattening needed there.
- No `styleSpec` escape hatch: unlike `RemixButton`/`RemixTextField`/
  `RemixSwitch`, the installed `RemixSelect` (remix `0.2.0`) has no
  `styleSpec` constructor parameter to forward to, so `DsSelect` doesn't
  expose one either (nothing to bypass).
- `style` is the escape hatch for full trigger/menu customization, same
  pattern as `DsButton`/`DsInput`/`DsSwitch`. There is no separate
  `itemStyle` constructor param — per-item style overrides go through each
  `RemixSelectItem.style` individually (matching upstream's own contract),
  not through a second top-level `DsSelect` param.

## Style resolvers (`select_2_style_resolver.dart`)

Two entry points, since `RemixSelect`'s per-item style isn't part of
`RemixSelectStyle` in the installed remix version (`RemixSelectItem.style` is
applied per-item by the widget itself, not merged in from the trigger/menu
style) — see "Context" above:

```dart
RemixSelectStyle resolveDsSelectStyle({
  required DsSelectSize size,
  required bool error,
})

RemixSelectMenuItemStyle resolveDsSelectItemStyle({
  required DsSelectSize size,
})
```

`resolveDsSelectStyle` composes fragments merged in order — base
(border/background/onFocused/onDisabled), then size (trigger padding/height/
label text style/icon size), then state (error border) — mirroring
`resolveDsInputStyle`'s composition:

```dart
RemixSelectStyle resolveDsSelectStyle({
  required DsSelectSize size,
  required bool error,
}) {
  final baseStyle = RemixSelectStyle()
      .trigger(
        RemixSelectTriggerStyle()
            .borderRadiusAll($radius008())
            .borderAll(color: $borderDefault(), width: 1)
            .color($surfaceDefault())
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentSecondary())),
      )
      .menuContainer(
        FlexBoxStyler()
            .color($surfaceDefault())
            .borderAll(color: $borderDefault(), width: 1)
            .borderRadiusAll($radius008())
            .paddingAll($spacing004())
            .marginTop($spacing004()),
      )
      .onFocused(
        RemixSelectStyle().trigger(
          RemixSelectTriggerStyle()
              .borderAll(color: $surfaceInverted(), width: 1),
        ),
      )
      .onDisabled(
        RemixSelectStyle().trigger(
          RemixSelectTriggerStyle()
              .color($surfaceAlternative())
              .label(TextStyler().color($contentMuted()))
              .icon(IconStyler(color: $contentMuted())),
        ),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm => RemixSelectStyle().trigger(
        RemixSelectTriggerStyle()
            .label(TextStyler(style: $bodySm.mix()))
            .icon(IconStyler(size: 16))
            .paddingX($spacing012())
            .paddingY($spacing006()),
      ),
    DsSelectSize.md => RemixSelectStyle().trigger(
        RemixSelectTriggerStyle()
            .label(TextStyler(style: $bodyMd.mix()))
            .icon(IconStyler(size: 20))
            .paddingX($spacing012())
            .paddingY($spacing008()),
      ),
    DsSelectSize.lg => RemixSelectStyle().trigger(
        RemixSelectTriggerStyle()
            .label(TextStyler(style: $bodyLg.mix()))
            .icon(IconStyler(size: 24))
            .paddingX($spacing016())
            .paddingY($spacing012()),
      ),
  };

  final stateStyle = error
      ? RemixSelectStyle().trigger(
          RemixSelectTriggerStyle().borderAll(color: $negativeUi(), width: 1),
        )
      : RemixSelectStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
```

`resolveDsSelectItemStyle` mirrors the same base/size composition for menu
rows, using `RemixSelectMenuItemStyle`'s own `.onHovered()`/`.onDisabled()`
(`WidgetStateVariantMixin` helpers, same family `resolveDsSwitchStyle` uses
via `.onSelected()`):

```dart
RemixSelectMenuItemStyle resolveDsSelectItemStyle({
  required DsSelectSize size,
}) {
  final baseStyle = RemixSelectMenuItemStyle()
      .borderRadiusAll($radius004())
      .color(const Color(0x00000000))
      .text(TextStyler().color($contentPrimary()))
      .icon(IconStyler(color: $contentPrimary()))
      .onHovered(
        RemixSelectMenuItemStyle().color($surfaceAlternative()),
      )
      .onDisabled(
        RemixSelectMenuItemStyle()
            .text(TextStyler().color($contentMuted()))
            .icon(IconStyler(color: $contentMuted())),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm => RemixSelectMenuItemStyle()
        .text(TextStyler(style: $bodySm.mix()))
        .icon(IconStyler(size: 16))
        .paddingX($spacing008())
        .paddingY($spacing006()),
    DsSelectSize.md => RemixSelectMenuItemStyle()
        .text(TextStyler(style: $bodyMd.mix()))
        .icon(IconStyler(size: 20))
        .paddingX($spacing012())
        .paddingY($spacing008()),
    DsSelectSize.lg => RemixSelectMenuItemStyle()
        .text(TextStyler(style: $bodyLg.mix()))
        .icon(IconStyler(size: 24))
        .paddingX($spacing012())
        .paddingY($spacing010()),
  };

  return baseStyle.merge(sizeStyle);
}
```

`DsSelect.build()` applies `resolveDsSelectItemStyle` to every item before
handing the list to `RemixSelect`, merging each item's own `style` on top so
callers can still override individual rows:

```dart
final resolvedItemStyle = resolveDsSelectItemStyle(size: size);
final resolvedItems = [
  for (final item in items)
    RemixSelectItem<T>(
      value: item.value,
      label: item.label,
      enabled: item.enabled,
      semanticLabel: item.semanticLabel,
      style: resolvedItemStyle.merge(item.style),
    ),
];
```

Notes:

- Color tokens mirror `resolveDsInputStyle`'s mapping (`$borderDefault`
  border, `$surfaceDefault` background, `$surfaceInverted` focus border,
  `$surfaceAlternative` disabled background / row hover, `$contentMuted`
  disabled text) for visual continuity between the two migrated form fields.
- `error` reuses `$negativeUi` for the trigger border, same token
  `resolveDsInputStyle`'s `stateStyle` uses.
- Menu row background defaults to transparent (`Color(0x00000000)`) so only
  the hover state paints a fill — same "null/transparent until interactive"
  precedent as the legacy `AppSelect`'s `_SelectOptionRow.color`.
- No `.animate()` fragment: `RemixSelect`'s own `_buildStyle()` (in
  `select_widget.dart`) already applies a 150ms fade/scale overlay
  animation internally, so the resolver doesn't need to add one — unlike
  `resolveDsButtonStyle`/`resolveDsSwitchStyle`, which animate their own
  color transitions directly.

## Catalog registration

Add `example/lib/catalog/specs/select_2_showcase_spec.dart`, mirroring
`button_2_showcase_spec.dart`/`input_2_showcase_spec.dart`:

- `sizesBuilder`: one `DsSelect<String>` per `DsSelectSize`, same 3-item list.
- `statesBuilder`: `enabled`, `disabled`, `error`, `with leading icon`,
  `with selected value`.
- No `variantsBuilder` — there is no variant axis.
- Hover/press/focus/open states are transient and Naked-driven; verified
  interactively in the running catalog app, same caveat noted in the
  button/input/switch specs.

Register the new spec in `example/lib/catalog/component_registry.dart`, and
export `select_2/select_2.dart` + `select_2/select_2_variants.dart` from
`lib/ui.dart`, same two-line pattern as `button_2`/`input_2`/`switch_2`.

## Out of scope

- `DsSelectVariant` visual-skin enum — no precedent from legacy `AppSelect`;
  single style only for now, same decision `input_2`/`switch_2` made.
- Multi-select — `RemixSelect<T>` (and therefore `DsSelect<T>`) models a
  single selected value only, same as legacy `AppSelect`.
- Label/helper-text slots — composition is the caller's responsibility, same
  as `DsSwitch`; unlike `DsInput`, `RemixSelect` has no built-in label/helper
  slot to wrap.
- Migrating/removing the legacy `AppSelect` — out of scope for this spec,
  same as `button_2`/`input_2`/`switch_2` leaving their legacy counterparts
  in place during the migration.
