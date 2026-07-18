# card_2: trim variants to elevated/bordered/filled(grey|inverted)

## Goal
Reshape `DsCardVariant` from `{ surface, elevated, ghost, bordered }` to
`{ elevated, bordered, filled }`, with `filled` further split by a new
`DsCardTone { grey, inverted }` parameter — matching the color split
`badge_2` already uses for its `secondary`/`primary` variants
(`$surfaceAlternative` vs `$surfaceInverted`), but expressed as a variant +
tone pair rather than badge_2's flat enum.

## API shape
```dart
enum DsCardVariant { elevated, bordered, filled }
enum DsCardTone { grey, inverted }

class DsCard extends StatelessWidget {
  const DsCard({
    ...
    this.variant = DsCardVariant.surface, // -> becomes elevated or bordered as new default; see below
    this.tone,
    ...
  });

  final DsCardVariant variant;

  /// Only meaningful when [variant] is [DsCardVariant.filled]. Defaults to
  /// [DsCardTone.grey] when left null.
  final DsCardTone? tone;
}
```

- `surface` and `ghost` are removed outright — breaking change, but the only
  consumer today is the showcase spec.
- `tone` is nullable. If `variant == DsCardVariant.filled` and `tone` is
  null, resolution silently falls back to `DsCardTone.grey` (no assertion).
- `tone` is ignored for `elevated`/`bordered`.

## Style resolution (`card_2_style_resolver.dart`)
- `elevated`: unchanged — `$surfaceDefault` background + `_cardElevatedShadow`, no border.
- `bordered`: unchanged — transparent background + `$borderStrong` border.
- `filled`: no border.
  - `DsCardTone.grey` → `$surfaceAlternative()` background.
  - `DsCardTone.inverted` → `$surfaceInverted()` background.

## Default variant
Since `surface` is removed, `DsCard`'s default `variant` moves from
`DsCardVariant.surface` to `DsCardVariant.elevated` (closest visual
equivalent — filled background, not transparent).

## Showcase spec (`example/lib/catalog/specs/card_2_showcase_spec.dart`)
`variantsBuilder` currently maps over `DsCardVariant.values`. Since `filled`
now hides the grey/inverted split, replace the map with an explicit list of
four cards: `elevated`, `bordered`, `filled` (tone: grey, labeled
"filled (grey)"), `filled` (tone: inverted, labeled "filled (inverted)").

## Out of scope
- No other component references `DsCard`/`DsCardVariant` today, so no other
  call sites need updates.
- No changes to `DsCardSize` or padding/radius logic.
