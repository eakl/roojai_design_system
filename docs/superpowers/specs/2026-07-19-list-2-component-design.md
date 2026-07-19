# `list_2` (`DsList`/`DsListItem`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `card_2` (single-widget container), `tabs_2`
(multiple cooperating widgets in one file), and `separator_2` (the divider
this component reuses). This spec covers `list_2` — a container that lays
out a vertical list of rows, optionally bordered, optionally headed by a
row of its own, with the body controlling its own padding/gap/separators.

No `RemixList`/`RemixListItem` exists in the `remix` package (confirmed by
searching its source), and no `ListItem`-shaped widget exists anywhere else
in this codebase. Both `DsList` (the container) and `DsListItem` (the row)
are therefore new, built together in this spec — the same "multiple
cooperating widgets, one new file" shape `tabs_2` established for
`DsTabs`/`DsTabBar`/`DsTab`/`DsTabView`.

## File structure

Mirrors `card_2`/`tabs_2`:

```
lib/src/components/list_2/
  list_2.dart                 — DsList + DsListItem widgets
  list_2_style_resolver.dart  — part of list_2.dart; resolveDsListStyle() + resolveDsListItemStyle()
  list_2_variants.dart        — DsListSize enum
```

## `DsListSize` (`list_2_variants.dart`)

```dart
enum DsListSize { sm, md, lg }
```

One shared size axis reused by both widgets, same "caller passes the same
value to each child" convention as `DsTabsSize`/`DsTab.size` — there is no
implicit inheritance from `DsList.size` down to its `children`. It drives
`DsList`'s body padding + inter-item gap, and `DsListItem`'s row padding and
title/subtitle text scale.

## `DsListItem` widget API

```dart
class DsListItem extends StatelessWidget {
  const DsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.size = DsListSize.md,
    this.enabled = true,
    this.onTap,
  });

  /// Primary text, always shown.
  final String title;

  /// Optional secondary text shown below [title].
  final String? subtitle;

  /// Optional leading slot — icon, `DsAvatar`, or any other widget.
  final Widget? leading;

  /// Optional trailing slot — icon, badge, switch, or any other widget.
  final Widget? trailing;

  /// Physical size — see [DsListSize]. Controls row padding and text scale.
  final DsListSize size;

  /// Public state: renders muted and suppresses [onTap] when false. Never
  /// inferred — always driven by this constructor param, same convention
  /// as [DsIconButton.enabled].
  final bool enabled;

  /// Called on tap. When null, the row renders as a static (non-pressable)
  /// row — no hover/press styling, no button semantics — same "presence of
  /// the callback decides interactivity" convention [DsIconButton.onPressed]
  /// and [RemixButton.onPressed] already use. Ignored while [enabled] is
  /// false.
  final VoidCallback? onTap;
}
```

### Rendering

A `Row` of:
1. `leading` (if set)
2. `Column` (`mainAxisSize: MainAxisSize.min`, cross-axis start) of
   `StyledText(title, ...)` + `StyledText(subtitle, ...)` if set — same
   `StyledText`/`TextStyler` primitive `label_2` uses, not raw `Text`.
3. `trailing` (if set)

When `onTap != null` (and `enabled`), this `Row` is wrapped in Mix's
`PressableBox` styled by `resolveDsListItemStyle`'s hover/press state
variants. When `onTap == null` or `enabled == false`, the row renders as a
plain `Box` with the base (non-interactive) style only — no `PressableBox`,
so there is no hover/press affordance to show for a row that can't react to
it.

## `DsList` widget API

```dart
class DsList extends StatelessWidget {
  const DsList({
    super.key,
    required this.children,
    this.header,
    this.bordered = false,
    this.separated = false,
    this.size = DsListSize.md,
  });

  /// The rows shown in the list body, in order.
  final List<DsListItem> children;

  /// Optional row shown above the body, visually set apart by an
  /// unconditional separator (see Rendering below) — independent of
  /// [separated].
  final DsListItem? header;

  /// Outer border treatment. `true` draws a `$radius008`/`$borderStrong`
  /// border around the whole container (background stays transparent),
  /// same tokens `card_2`'s `bordered` variant uses. `false` draws neither
  /// — the list sits flush in its parent's surface.
  final bool bordered;

  /// Whether consecutive body rows are separated by a `DsSeparator`
  /// (`separator_2`). Does not affect the header — the header/body divider
  /// is unconditional (see [header]).
  final bool separated;

  /// Physical size — see [DsListSize]. Controls the body's outer padding
  /// and the gap between rows.
  final DsListSize size;
}
```

### Rendering

```
Box(style: resolveDsListStyle(bordered: bordered, size: size), child: Column(
  children: [
    if (header != null) ...[header!, const DsSeparator()],
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) ...[
        if (separated) const DsSeparator() else SizedBox(height: gapForSize),
        if (separated) SizedBox(height: gapForSize / 2) /* around the line, both sides */,
      ],
      children[i],
    ],
  ],
))
```

(Illustrative — exact spacer arrangement is an implementation detail; the
requirement is: every row after the first gets `gapForSize` of breathing
room from its predecessor, and when `separated` is true a `DsSeparator`
sits centered in that gap rather than the gap being skipped.)

Single widget, not split into a separate "list body" sub-widget — the
outer-container concerns (`bordered`, `header`) and the body concerns
(padding, gap, `separated`) are all just properties of the one `DsList`,
matching `card_2`'s single-widget shape rather than introducing an
additional public type for what both amount to configuration of the same
container.

## Style resolvers (`list_2_style_resolver.dart`)

Two entry points, following `card_2_style_resolver.dart`'s
base → size (→ variant) composition:

```dart
BoxStyler resolveDsListStyle({
  required bool bordered,
  required DsListSize size,
}) {
  final baseStyle = BoxStyler(); // no border/radius by default

  final sizeStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsListSize.md => BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsListSize.lg => BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  final borderedStyle = bordered
      ? BoxStyler()
          .borderRadiusAll($radius008())
          .borderAll(color: $borderStrong(), width: 1)
      : BoxStyler();

  return baseStyle.merge(sizeStyle).merge(borderedStyle);
}

BoxStyler resolveDsListItemStyle({
  required DsListSize size,
  required bool enabled,
  required bool interactive, // onTap != null && enabled
}) {
  final sizeStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing012(), vertical: $spacing008())),
    DsListSize.md => BoxStyler().padding(EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing016(), vertical: $spacing012())),
    DsListSize.lg => BoxStyler().padding(EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing020(), vertical: $spacing016())),
  };

  final interactiveStyle = interactive
      ? BoxStyler()
          .onHovered(BoxStyler().backgroundColor($neutralUiHover()))
          .onPressed(BoxStyler().backgroundColor($neutralUiHover()))
      : BoxStyler();

  return sizeStyle.merge(interactiveStyle);
}
```

`enabled: false` dims `title`/`subtitle` text color to `$contentPlaceholder()`
in the widget's own `build()` (same treatment `label_2` applies for its
`disabled` state) rather than in the `Box` style — text color is a
`TextStyler` concern, resolved alongside title/subtitle the same way
`label_2_style_resolver.dart`'s `resolveDsLabelStyle` returns a text-styler
record.

`$spacing008`/`012`/`016`/`020` all exist as `SpaceToken`s in
`theme/light/spacing.dart` — the scale shown mirrors `card_2`'s `sm`/`md`/
`lg` progression (`$spacing012`/`016`/`020` for outer padding), with
`$spacing008` added one step down for the row's own vertical padding at
`sm`.

## Interactivity: `PressableBox` over `NakedButton`

`remix`'s only pressable primitives (`RemixButton`, `RemixIconButton`) have
a fixed label+leading/trailing-icon layout with no subtitle slot and no
arbitrary leading/trailing widgets — too rigid for this row shape. Two
alternatives were considered:

- **`naked_ui`'s `NakedButton`** (already used directly in `tabs_2`/
  `popover_2` for custom-layout+interaction cases) — would work, but
  requires manually branching on the returned `WidgetState` set to pick
  hover/press colors in the resolver.
- **Mix's `PressableBox`** (chosen) — combines `Box` styling with built-in
  hover/press/focus handling, driven declaratively by
  `BoxStyler.onHovered()`/`.onPressed()`/`.onDisabled()` state-variant
  chaining — the exact idiom `button_2_style_resolver.dart` already uses
  for `RemixButtonStyler`. It's part of `mix`, already a core dependency
  via `BoxStyler`/`TextStyler` (used by `card_2`/`label_2`/`icon_2`), and
  needs no manual state inspection anywhere in `list_2`.

## Catalog registration

Add `example/lib/catalog/specs/list_2_showcase_spec.dart`, mirroring
`card_2_showcase_spec.dart`'s structure:

- `sizesBuilder`: one `DsList` per `DsListSize`, three static items each.
- `variantsBuilder`: `bordered: false` vs `bordered: true`.
- `statesBuilder`: plain list, `separated: true`, `with header`, `with
  leading/trailing content` (icons), `disabled item`, `interactive item`
  (`onTap` wired to a visible callback, e.g. a snackbar or print).

Register in `example/lib/catalog/component_registry.dart`. Export
`list_2/list_2.dart` + `list_2/list_2_variants.dart` from `lib/ui.dart`,
same two-line pattern as every other `_2` component.

## Out of scope

- Selection/multi-select row state (checked/radio rows) — no precedent
  requested here; a future `DsListItem` variant if needed.
- Nested/indented lists.
- A `child` override on `DsListItem` bypassing leading/title/subtitle/
  trailing (the "fully generic child" alternative, not chosen) — can be
  added later as an escape hatch without breaking this API, same precedent
  as `DsTab.child`.
- Scrolling — `DsList` renders a plain `Column`; callers wrap it in a
  `ListView`/`SingleChildScrollView` themselves, same as `card_2` not
  handling its own scrolling.
- `style`/`styleSpec` Remix-style escape hatches — `DsList`/`DsListItem`
  don't wrap a Remix widget with its own `Styler` type (same reasoning
  `label_2` documents for omitting them).
