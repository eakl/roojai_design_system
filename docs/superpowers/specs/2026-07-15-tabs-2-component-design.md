# `tabs_2` (`DsTabs`) design

## Context

Continues the `_2` migration onto `remix`/`mix` established by `button_2`,
`input_2`, `select_2`, `switch_2`, `toggle_2`. This spec covers `tabs_2`, a
thin wrapper around Remix's `RemixTabs` family
(https://docs.page/btwld/remix/components/tabs). There is no legacy `Tabs`
widget in this repo to replace — this is a net-new component.

Unlike the single-widget wrappers (`DsButton`/`RemixButton`,
`DsToggle`/`RemixToggle`), Remix's tabs API is a **composite of four
widgets** the caller assembles by hand:

```dart
RemixTabs(                      // state container — selectedTabId/onChanged
  selectedTabId: 'tab1',
  onChanged: (id) => ...,
  child: Column(
    children: [
      RemixTabBar(child: Row(children: [RemixTab(tabId: 'tab1', ...), ...])),
      RemixTabView(tabId: 'tab1', child: ...),
      RemixTabView(tabId: 'tab2', child: ...),
    ],
  ),
)
```

`tabs_2` follows that same shape one-for-one: `DsTabs`, `DsTabBar`, `DsTab`,
`DsTabView`, each a thin wrapper around its `Remix*` counterpart. There is no
single `DsTabs(items: [...])` all-in-one API — matching Remix's own
compositional design rather than inventing a data-driven wrapper on top.

## File structure

```
lib/src/components/tabs_2/
  tabs_2.dart                 — DsTabs, DsTabBar, DsTab, DsTabView widgets
  tabs_2_style_resolver.dart  — part of tabs_2.dart; resolveDsTabStyle(),
                                 resolveDsTabBarStyle(), resolveDsTabViewStyle()
  tabs_2_variants.dart        — DsTabsVariant, DsTabsSize enums
```

## `tabs_2_variants.dart`

```dart
enum DsTabsVariant { underline, segmented }

enum DsTabsSize { sm, md, lg }
```

- `DsTabsVariant.underline` is the original (and default) look — Remix's own
  `FortalTabsStyles` ships this single underline-indicator style, ported
  onto this DS's semantic tokens exactly as originally shipped, unchanged.
- `DsTabsVariant.segmented` is an iOS `UISegmentedControl`-style addition: a
  gray rounded container (`DsTabBar`) with the selected `DsTab` rendered as
  a solid pill inside it, rather than an underline. There's no Remix/Fortal
  precedent for this look — it's this DS's own addition, built from the same
  semantic tokens.
- Sizing is applied per-`DsTab` (see below) rather than centrally, since
  each tab is constructed independently by the caller — same reasoning
  callers already navigate when composing multiple `DsButton`s that need to
  agree on one `size`. `variant` follows the same per-widget convention:
  callers composing a `DsTabBar` pass the same `variant` to it and to every
  `DsTab` within it.

## Widget API

### `DsTabs` (state container)

Thin pass-through to `RemixTabs` — no styling surface of its own (Remix's
`RemixTabs` takes no `style` param either, it only manages
selection/keyboard state via `NakedTabs`):

```dart
class DsTabs extends StatelessWidget {
  const DsTabs({
    super.key,
    required this.child,
    this.controller,
    this.selectedTabId,
    this.onChanged,
    this.orientation = Axis.horizontal,
    this.enabled = true,
    this.onEscapePressed,
  }) : assert(
         controller != null || selectedTabId != null,
         'Either controller or selectedTabId must be provided',
       );
}
```

Same fully-controlled convention as `DsSelect.selectedValue` — `selectedTabId`
is never inferred, the assert is carried through verbatim from `RemixTabs`.

### `DsTabBar` (tab list container)

```dart
class DsTabBar extends StatelessWidget {
  const DsTabBar({
    super.key,
    required this.child,
    this.variant = DsTabsVariant.underline,
    this.style = const RemixTabBarStyle.create(),
  });
}
```

Resolves `resolveDsTabBarStyle(variant)` merged with the caller's `style`
escape hatch. `underline` draws a bottom-rule separator under the bar;
`segmented` gives the bar a gray, rounded container background instead (see
resolver below).

### `DsTab` (individual tab)

```dart
class DsTab extends StatelessWidget {
  const DsTab({
    super.key,
    required this.tabId,
    this.label,
    this.icon,
    this.child,
    this.variant = DsTabsVariant.underline,
    this.size = DsTabsSize.md,
    this.enabled = true,
    this.mouseCursor = SystemMouseCursors.click,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onHoverChange,
    this.onPressChange,
    this.semanticLabel,
    this.style = const RemixTabStyle.create(),
  }) : assert(
         child != null || label != null,
         'Either child or label must be provided',
       );
}
```

- `label`/`icon`/`child` mirror `RemixTab`'s own slots directly (label text,
  optional icon, or a fully custom `child` bypassing both). `builder` is
  dropped from the public surface — no `_2` component exposes Remix's
  per-state `builder` escape hatch today (see `DsButton`'s narrower
  `textBuilder`/`iconBuilder` precedent instead), and nothing in this spec's
  scope needs it.
- `size` drives label/icon/padding sizing via `resolveDsTabStyle`, same
  `sm`/`md`/`lg` used elsewhere. Applied per-tab since `RemixTab`s are
  independent siblings, not a list Remix hands sizing down to centrally.
- `variant` selects the underline vs. segmented indicator via
  `resolveDsTabStyle`, same per-tab application as `size` and for the same
  reason.
- `enabled`, `focusNode`, `autofocus`, `onFocusChange`, `onHoverChange`,
  `onPressChange`, `mouseCursor`, `enableFeedback`, `semanticLabel` are
  straight pass-throughs to `RemixTab`, same as `DsButton`'s equivalent
  fields pass through to `RemixButton`.

### `DsTabView` (content panel)

```dart
class DsTabView extends StatelessWidget {
  const DsTabView({
    super.key,
    required this.tabId,
    required this.child,
    this.style = const RemixTabViewStyle.create(),
  });
}
```

Resolves `resolveDsTabViewStyle()` (padding only) merged with the caller's
`style`.

## Style resolver (`tabs_2_style_resolver.dart`)

`resolveDsTabBarStyle(variant)` and `resolveDsTabStyle({variant, size,
disabled})` are the two entry points consumed by `DsTabBar`/`DsTab`
respectively (`DsTabView`'s `resolveDsTabViewStyle()` is variant-agnostic —
padding only, unchanged). Each switches on `variant` to one of two private
per-variant base-style helpers, then (for `DsTab`) merges the same
`sizeStyle`/`stateStyle` fragments regardless of variant:

```dart
RemixTabBarStyle resolveDsTabBarStyle(DsTabsVariant variant) {
  return switch (variant) {
    DsTabsVariant.underline => _underlineTabBarStyle(),
    DsTabsVariant.segmented => _segmentedTabBarStyle(),
  };
}

RemixTabBarStyle _underlineTabBarStyle() {
  return RemixTabBarStyle().decoration(
    BoxDecorationMix(
      border: BorderMix.bottom(BorderSideMix(color: $borderDefault(), width: 1)),
    ),
  );
}

RemixTabBarStyle _segmentedTabBarStyle() {
  return RemixTabBarStyle()
      .color($surfaceAlternative())
      .borderRadiusAll($radius008())
      .padding(EdgeInsetsMix.all($spacing004()));
}

RemixTabStyle resolveDsTabStyle({
  required DsTabsVariant variant,
  required DsTabsSize size,
  required bool disabled,
}) {
  final baseStyle = switch (variant) {
    DsTabsVariant.underline => _underlineTabStyle(),
    DsTabsVariant.segmented => _segmentedTabStyle(),
  };

  final sizeStyle = switch (size) {
    // unchanged — same label/icon/padding fragments for both variants
  };

  final stateStyle = disabled
      ? RemixTabStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixTabStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}

RemixTabStyle _underlineTabStyle() {
  // exactly the original (pre-variant) baseStyle, unchanged: transparent
  // 2px bottom-border wrap, $brandUi() on select.
}

RemixTabStyle _segmentedTabStyle() {
  const transparent = Color(0x00000000);

  return RemixTabStyle()
      .container(/* same layout fragment as _underlineTabStyle */)
      .color(transparent)
      .borderRadiusAll($radius004())
      .label(TextStyler().color($contentSecondary()))
      .icon(IconStyler(color: $contentSecondary()))
      .onHovered(/* same hover label/icon color bump */)
      .onSelected(
        RemixTabStyle()
            .color($surfaceDefault())
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentPrimary())),
      );
}

RemixTabViewStyle resolveDsTabViewStyle() {
  return RemixTabViewStyle().padding(EdgeInsetsMix.all($spacing016()));
}
```

Notes:

- `underline`'s selected-tab indicator is a 2px bottom border on the tab
  itself (via `.wrap(WidgetModifierConfig.box(...))`, same "opacity/border
  modifier, not a style property" split `resolveDsButtonStyle`'s comment
  documents), transparent by default and `$brandUi()` when selected — same
  underline pattern `FortalTabsStyles.base()` uses, ported onto this DS's
  own semantic tokens instead of `FortalTokens`. This branch is untouched
  from the component's original (pre-variant) implementation.
- `segmented`'s selected-tab indicator is a `$surfaceDefault()` pill drawn
  via `.color()`/`.borderRadius()` — a container **decoration** merged
  straight into the same `FlexBoxStyler` used for layout, not a `.wrap(...)`
  modifier — since the pill needs to sit inset by the bar's own
  `$spacing004()` padding (see `_segmentedTabBarStyle`), not drawn edge to
  edge like the underline's border. `$radius004()` on the tab pairs with
  `$radius008()` on the bar container — a nested-corner convention (outer
  radius minus the bar's inset padding roughly matches the inner radius).
- `resolveDsTabBarStyle`'s `underline` branch draws one hairline
  (`$borderDefault()`, 1px) under the whole bar so the tab row reads as a
  single separated region before any tab is selected; the selected tab's own
  2px indicator then overlaps the hairline visually. The `segmented` branch
  instead gives the bar a full `$surfaceAlternative()` background — there's
  no hairline to overlap since the pill itself provides all the contrast.
- Disabled dimming reuses the same `.wrap(WidgetModifierConfig.opacity(0.5))`
  mechanism as every other `_2` resolver, for both variants.
- No `.animate(...)` — same reasoning as `resolveDsToggleStyle`: no legacy
  precedent to match and out of this spec's scope. (A sliding-pill animation
  for `segmented` would be a natural follow-up but isn't implemented here.)

## Catalog registration

Add `example/lib/catalog/specs/tabs_2_showcase_spec.dart`. Tabs don't fit the
`variantsBuilder`/`sizesBuilder`/`statesBuilder` single-widget-per-cell shape
as cleanly as `DsButton` — each entry needs a fully assembled
`DsTabs`/`DsTabBar`/`DsTab`×N/`DsTabView`×N tree, and `DsTabs.selectedTabId`
is fully controlled (no internal state), so every showcased instance needs
its own `_InteractiveTabs`-style stateful wrapper, same pattern
`select_2_showcase_spec.dart`'s `_InteractiveSelect` uses:

- `variantsBuilder`: one `_InteractiveTabs` per `DsTabsVariant`.
- `sizesBuilder`: one `_InteractiveTabs` per `DsTabsSize`, three tabs each.
- `statesBuilder`: default interactive tabs, a tabs group with icons
  alongside labels, a tabs group with one disabled tab
  (`DsTab(enabled: false)`), and the same disabled/default pair repeated for
  the `segmented` variant.

Register `'Tabs 2': buildTabs2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`tabs_2/tabs_2.dart` + `tabs_2/tabs_2_variants.dart` from `lib/ui.dart`.

## Out of scope

- Vertical orientation styling — `DsTabs.orientation` passes through to
  `RemixTabs`/`NakedTabs` for keyboard-navigation behavior, but
  `resolveDsTabStyle`'s underline indicator is only tuned for the horizontal
  layout used throughout the catalog. Vertical-specific styling (e.g. a
  side-border indicator instead of bottom-border) can follow in a later spec
  if a caller needs it.
- A data-driven `DsTabs(items: [...])` convenience wrapper — out of scope,
  see "Context" above.
