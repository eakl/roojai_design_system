# `card_2` (`DsCard`) design

## Context

Continues the `_2` migration established by `button_2`, `input_2`,
`badge_2`, `callout_2`, `dialog_2`, and others. There is no legacy `card`
component in this repo — this is a new component, same situation as
`dialog_2`.

Remix ships `RemixCard` (docs.page/btwld/remix/components/card) — a thin
`StyleWidget<RemixCardSpec>` wrapping a single `Box` via a
`RemixCardStyler` (`container: BoxStyler` only, no built-in size/variant
axis; the bundled Fortal reference styles define their own
`surface`/`classic`/`ghost` × `size1..3` example, not used directly).
`card_2` follows the `badge_2`/`dialog_2` precedent: a thin wrapper
supplying a resolved `RemixCardStyler` from this DS's Mix semantic
tokens, with its own `DsCardVariant`/`DsCardSize` enums.

## File structure

```
lib/src/components/card_2/
  card_2.dart                 — DsCard widget (StatelessWidget)
  card_2_style_resolver.dart  — part of card_2.dart; resolveDsCardStyle()
  card_2_variants.dart        — DsCardVariant, DsCardSize enums
```

## `card_2_variants.dart`

```dart
enum DsCardSize { sm, md, lg }

enum DsCardVariant { surface, elevated, ghost, bordered }
```

`DsCardVariant` mirrors Fortal's `surface`/`classic`/`ghost` shape but
renames `classic` to `elevated` to describe what it actually does in
this DS (shadow, no border) rather than reusing Fortal's naming
verbatim — there's no legacy `Card` to port a name from. `bordered` was
added afterward: a transparent-background, border-only treatment (no
Fortal equivalent), same shape as `button_2`/`badge_2`'s `outline`.

## Widget API (`card_2.dart`)

```dart
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    this.child,
    this.variant = DsCardVariant.surface,
    this.size = DsCardSize.md,
    this.style = const RemixCardStyler.create(),
    this.styleSpec,
  });

  /// The widget below this widget in the tree. Non-interactive container
  /// — same single-child constraint as [RemixCard] itself.
  final Widget? child;

  /// Visual treatment — see [DsCardVariant].
  final DsCardVariant variant;

  /// Physical size — see [DsCardSize]. Controls padding only; card has no
  /// intrinsic height/width like [DsButton]/[DsInput] do.
  final DsCardSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsCardStyle]'s output).
  final RemixCardStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixCardSpec] directly, bypassing style resolution entirely.
  final RemixCardSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCardStyle(
      variant: variant,
      size: size,
    ).merge(style);

    return RemixCard(
      style: resolvedStyle,
      styleSpec: styleSpec,
      child: child,
    );
  }
}
```

No `builder`/content-slot params — `RemixCard` itself only has a plain
`child` slot (no `labelBuilder`-style callback), so there's nothing to
forward beyond `child`.

## Style resolver (`card_2_style_resolver.dart`)

```dart
part of 'card_2.dart';

final _cardElevatedShadow = BoxShadowMix(
  color: const Color(0x1F000000),
  offset: const Offset(0, 2),
  blurRadius: 8,
);

RemixCardStyler resolveDsCardStyle({
  required DsCardVariant variant,
  required DsCardSize size,
}) {
  final baseStyle = RemixCardStyler().borderRadiusAll($radius008());

  final sizeStyle = switch (size) {
    DsCardSize.sm => RemixCardStyler().padding(
        EdgeInsetsGeometryMix.all($spacing012()),
      ),
    DsCardSize.md => RemixCardStyler().padding(
        EdgeInsetsGeometryMix.all($spacing016()),
      ),
    DsCardSize.lg => RemixCardStyler().padding(
        EdgeInsetsGeometryMix.all($spacing020()),
      ),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsCardVariant.surface => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .borderAll(color: $borderDefault(), width: 1),
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.ghost => RemixCardStyler().backgroundColor(transparent),
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

Notes:

- No `disabled`/state axis and no `.animate(...)` — Card is always
  non-interactive, same reasoning as `badge_2`/`callout_2`.
- `_cardElevatedShadow` is a local literal `BoxShadowMix` constant, same
  pattern as `dialog_2_style_resolver.dart`'s `_dialogShadow` — this DS's
  `$elevationLevelN` semantic tokens (`lib/src/tokens/semantic/
  elevation.dart`) aren't consumed by any existing component yet
  (`dialog_2` already opted for a literal shadow instead), so `card_2`
  follows that same established precedent rather than being the first
  consumer of an unproven token path.
- `borderRadiusAll($radius008())` matches `dialog_2`/`button_2`/every
  other panel-scale container in this DS — not varied per size.
- `surface` has a background + `$borderDefault` border; `elevated`
  trades the border for a shadow (can't sensibly have both without
  doubling the edge treatment); `ghost` has neither, matching Fortal's
  ghost; `bordered` has no background but an emphasized `$borderStrong`
  border (vs. `surface`'s subtler `$borderDefault`) so it still reads
  clearly with no fill behind it.
- Padding uses the same `$spacing012/016/020` tier `button_2`'s
  `sm/md/lg` sizes use for their horizontal padding — a comparable
  content-inset scale for a panel-like container.

## Catalog registration

Add `example/lib/catalog/specs/card_2_showcase_spec.dart`, following
`badge_2_showcase_spec.dart`'s two-axis shape (Card has both a variant
and a size axis, no interactive states):

- `variantsBuilder`: one `DsCard` per `DsCardVariant.values`, wrapping a
  `Text(variant.name)` child.
- `sizesBuilder`: one `DsCard` per `DsCardSize.values`, wrapping a
  `Text(size.name)` child.
- `statesBuilder`: omitted — Card has no interactive/public state axis
  (same as `skeleton_2`/`separator_2`).

Register `'Card 2': buildCard2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`card_2/card_2.dart` + `card_2/card_2_variants.dart` from `lib/ui.dart`.

## Out of scope

- Dedicated header/footer/media slots — `RemixCard`/legacy has none;
  callers compose those themselves via `child` (e.g. a `Column`).
- `DsCardSize` affecting anything beyond padding (no fixed
  width/height) — same reasoning as the widget API doc above.
- Consuming `$elevationLevelN` tokens — left for a future migration that
  also updates `dialog_2` to match, see resolver notes above.
