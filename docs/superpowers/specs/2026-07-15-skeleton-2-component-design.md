# `skeleton_2` (`DsSkeleton`) design

## Context

Continues the `_2` migration established by `button_2`, `input_2`,
`select_2`, `switch_2`, `toggle_2`, `progress_2`, `spinner_2`, `tabs_2`.
`lib/ui.dart` already has the legacy `skeleton` export commented out
(the same holding pattern every other pre-migration component sits in),
marking the slot `skeleton_2` is meant to fill.

Unlike the `_2` components built as thin wrappers around a `Remix*`
widget, Remix ships no `Skeleton` component — there is nothing to wrap.
`skeleton_2` instead follows the other precedent already in the repo,
`icon_container_2`: built directly on Mix's `Box`/`BoxStyler` primitive,
styled from this DS's semantic tokens, with no Remix widget underneath.

## File structure

```
lib/src/components/skeleton_2/
  skeleton_2.dart                 — DsSkeleton widget (StatefulWidget)
  skeleton_2_style_resolver.dart  — part of skeleton_2.dart; resolveDsSkeletonStyle()
  skeleton_2_shape.dart           — DsSkeletonShape enum
```

## `skeleton_2_shape.dart`

Direct rename of the legacy `SkeletonShape` enum, doc comments carried
over unchanged:

```dart
enum DsSkeletonShape { rectangle, circle, text }
```

- `rectangle` (default) — rounded-rectangle block for placeholder cards,
  images, generic content blocks.
- `circle` — fully rounded circle for placeholder avatars. `height`
  drives the diameter; `width` is ignored so a caller-supplied width
  can't squash it into an ellipse (same behavior as the legacy widget).
- `text` — thin, slightly-rounded bar for placeholder text lines.

## Widget API (`skeleton_2.dart`)

Same public shape as the legacy `Skeleton`, `Ds`-prefixed per convention,
plus a `style` escape hatch matching `IconContainer.style`'s convention
(the legacy widget had no such escape hatch — this is a net-new addition
needed now that styling flows through a Mix `BoxStyler` instead of a
raw `BoxDecoration`):

```dart
class DsSkeleton extends StatefulWidget {
  const DsSkeleton({
    super.key,
    this.shape = DsSkeletonShape.rectangle,
    this.width = 120,
    this.height = 16,
    this.style,
  });

  /// Visual shape — see [DsSkeletonShape].
  final DsSkeletonShape shape;

  /// Width of the placeholder block. Ignored when [shape] is
  /// [DsSkeletonShape.circle] — [height] drives both dimensions there.
  final double width;

  /// Height of the placeholder block. For [DsSkeletonShape.circle], also
  /// used as the diameter (see [width]).
  final double height;

  /// Escape hatch merged on top of [resolveDsSkeletonStyle]'s output —
  /// same convention as [IconContainer.style].
  final BoxStyler? style;
}
```

## Behavior — unchanged from the legacy widget

`_DsSkeletonState` still owns:

- an `AnimationController` (vsync via `SingleTickerProviderStateMixin`,
  1000ms duration, `repeat(reverse: true)`) — a skeleton has no
  "finished" state, so it runs from `initState` to `dispose`, same
  lifecycle as `Spinner`'s controller;
- a `CurvedAnimation` (`Curves.easeInOut`) so the pulse settles at each
  end instead of reversing abruptly;
- an `AnimatedBuilder` wrapping the resolved `Box` in `Opacity`, mapping
  the eased 0.0-1.0 value to a 0.5-1.0 opacity range via the same
  `_resolveOpacity` helper, ported unchanged.

Mix has no "loop forever" animation primitive that fits here —
`phaseAnimation`/`keyframeAnimation` both advance on an external
`trigger: Listenable`, not on a free-running repeat — so hand-rolling the
pulse via `AnimationController` is still the right call, same reasoning
`tabs_2`'s spec gives for skipping `.animate(...)` on `resolveDsTabStyle`.
What changes is only the leaf being animated: instead of a raw
`Container`/`BoxDecoration`, it's a Mix `Box` styled through
`resolveDsSkeletonStyle`.

## Style resolver (`skeleton_2_style_resolver.dart`)

One resolver function, mirroring the legacy widget's three small
`_resolve*` helpers but folded into a single `BoxStyler`:

```dart
part of 'skeleton_2.dart';

BoxStyler resolveDsSkeletonStyle({
  required DsSkeletonShape shape,
  required double width,
  required double height,
}) {
  final resolvedWidth = shape == DsSkeletonShape.circle ? height : width;
  final radius = _resolveRadius(shape, height);

  return BoxStyler()
      .width(resolvedWidth)
      .height(height)
      .color($surfaceAlternative())
      .borderRadiusAll(radius);
}

double _resolveRadius(DsSkeletonShape shape, double height) {
  switch (shape) {
    case DsSkeletonShape.rectangle:
      return $radius008();
    case DsSkeletonShape.circle:
      return height / 2;
    case DsSkeletonShape.text:
      return $radius004();
  }
}
```

Notes:

- `$surfaceAlternative()` replaces the legacy widget's
  `AppTokens.of(context).colors.surface.alternative` — same semantic
  color, now sourced from this DS's Mix token set (`colors.dart`)
  instead of the raw `AppTokens` theme object, matching every other
  `_2` resolver's token usage.
- `rectangle`/`text` radii move onto the existing `$radius008`/`$radius004`
  semantic tokens (already used by `tabs_2`'s segmented variant) in place
  of the legacy widget's raw `AppRadius.radius8`/`AppRadius.radius4`
  constants — same numeric values, now token-sourced.
- `circle`'s `height / 2` stays a computed value, not a token — it's
  inherently dynamic (depends on the caller's `height`), same as the
  legacy widget.
- No variant × state matrix here (no `disabled`, no visual variant axis),
  so there's a single resolver function, not the
  `resolveX`/`_variantBaseStyle`/`sizeStyle`/`stateStyle` split
  `tabs_2`/`spinner_2` use for their larger matrices.

## `DsSkeleton.build()`

```dart
@override
Widget build(BuildContext context) {
  final resolvedStyle = resolveDsSkeletonStyle(
    shape: widget.shape,
    width: widget.width,
    height: widget.height,
  ).merge(widget.style);

  return AnimatedBuilder(
    animation: _pulse,
    builder: (context, child) {
      return Opacity(opacity: _resolveOpacity(_pulse.value), child: child);
    },
    child: Box(style: resolvedStyle),
  );
}
```

## Catalog registration

Add `example/lib/catalog/specs/skeleton_2_showcase_spec.dart`. Skeleton
has no variant or size axis (unlike `tabs_2`/`spinner_2`), so
`variantsBuilder`/`sizesBuilder` are omitted — only `statesBuilder`,
following `spinner_2_showcase_spec.dart`'s no-variant shape as the
closer model:

- `statesBuilder`: one `DsSkeleton` per `DsSkeletonShape`
  (`rectangle` at its default 120×16, `circle` at e.g. 40×40, `text` at
  e.g. 200×12), demonstrating the pulse animation live in the catalog.

Register `'Skeleton 2': buildSkeleton2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`skeleton_2/skeleton_2.dart` + `skeleton_2/skeleton_2_shape.dart` from
`lib/ui.dart` in place of the currently-commented-out `skeleton` export.

## Out of scope

- Adding a size or variant enum beyond `DsSkeletonShape` — the legacy
  widget has none, and nothing in this migration calls for one.
- Any change to the pulse timing/curve/opacity range — ported verbatim.
