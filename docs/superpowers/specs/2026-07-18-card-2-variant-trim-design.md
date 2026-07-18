# card_2: trim variants to elevated/bordered/filled(base|alternative|inverted)

## Goal
Reshape `DsCardVariant` from `{ surface, elevated, ghost, bordered }` to
`{ elevated, bordered, filled }`, with `filled` further split by a new
`DsCardTone { base, alternative, inverted }` parameter. This is the same
color-split idea `badge_2` uses for its `secondary`/`primary` variants
(`$surfaceAlternative` vs `$surfaceInverted`), but expressed as a
variant + tone pair, with a third `base` tone that preserves the old
`surface` variant's exact look.

## API shape
```dart
enum DsCardVariant { elevated, bordered, filled }
enum DsCardTone { base, alternative, inverted }

class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    this.child,
    this.variant = DsCardVariant.filled,
    this.tone = DsCardTone.base,
    this.size = DsCardSize.md,
    this.style = const RemixCardStyler.create(),
    this.styleSpec,
  });

  final DsCardVariant variant;

  /// Only meaningful when [variant] is [DsCardVariant.filled]; ignored for
  /// [DsCardVariant.elevated]/[DsCardVariant.bordered].
  final DsCardTone tone;
}
```

- `surface` and `ghost` are removed outright — breaking change, but the only
  consumer today is the showcase spec.
- `tone` is non-nullable, defaults to `DsCardTone.base` — no fallback logic
  needed since the default already covers the "unspecified" case.
- Default `variant` becomes `DsCardVariant.filled` (previously `surface`),
  which combined with the default `tone: base` reproduces the exact old
  `surface` appearance.

## Style resolution (`card_2_style_resolver.dart`)
- `elevated`: unchanged — `$surfaceDefault` background + `_cardElevatedShadow`, no border.
- `bordered`: unchanged — transparent background + `$borderStrong` border.
- `filled`: no border in any tone.
  - `DsCardTone.base` → `$surfaceDefault()` background (matches old `surface` variant exactly).
  - `DsCardTone.alternative` → `$surfaceAlternative()` background (grey).
  - `DsCardTone.inverted` → `$surfaceInverted()` background.

## Showcase spec (`example/lib/catalog/specs/card_2_showcase_spec.dart`)
`variantsBuilder` currently maps over `DsCardVariant.values`. Since `filled`
now hides the tone split, replace the map with an explicit list of five
cards: `elevated`, `bordered`, `filled` (tone: base, labeled
"filled (base)"), `filled` (tone: alternative, labeled
"filled (alternative)"), `filled` (tone: inverted, labeled
"filled (inverted)").

## Out of scope
- No other component references `DsCard`/`DsCardVariant` today, so no other
  call sites need updates.
- No changes to `DsCardSize` or padding/radius logic.
