# IconContainer Component Design

**Goal:** Add a design-system `IconContainer` widget — a rounded-square
background chip that renders an `Icon` (from `icon_2`) centered inside it,
sized and colored as one coherent unit via `variant` and `size`.

**Prerequisite fix:** the working tree has broken, uncommitted edits in
`lib/src/tokens/semantic/colors.dart` and `lib/src/theme/light/colors.dart` —
a "Neutral" token block was pasted in reusing the `$info*` names (duplicate
declarations) instead of `$neutral*`, and the light-colors file has
`const $neutral... = ...;` statements illegally inside a `Map` literal. This
must be fixed first: `IconContainer`'s neutral variant depends on
`$neutralSurface`, and `icon_2`'s existing resolver already depends on
`$neutralText`, neither of which currently compile. Additionally,
`lib/src/components/icon_2/icon.dart` imports a nonexistent `icon_size.dart`
(the `DsIconSize` enum was consolidated into `icon_variant.dart`) — this dead
import must be dropped.

**Tech Stack:** Flutter, `mix` (`Box`, `BoxStyler`), consuming the existing
`icon_2` `Icon` widget and `DsIconVariant`/`DsIconSize` enums.

## Token fixes

`lib/src/tokens/semantic/colors.dart` — replace the broken duplicate block
(currently named `$info*` under the `// Neutral.` comment) with correctly
named tokens, following the same shape as every other category (Positive,
Negative, Warning, etc.):

```dart
// Neutral.
const $neutralSurface = ColorToken('color.neutral.surface');
const $neutralSurfaceStrong = ColorToken('color.neutral.surfaceStrong');
const $neutralBorder = ColorToken('color.neutral.border');
const $neutralUi = ColorToken('color.neutral.ui');
const $neutralUiHover = ColorToken('color.neutral.uiHover');
const $neutralText = ColorToken('color.neutral.text');
const $neutralTextStrong = ColorToken('color.neutral.textStrong');
```

`lib/src/theme/light/colors.dart` — replace the invalid `const`-in-map block
with proper map entries (mirroring the Positive/Negative/Warning sections,
which also don't map their `*Border` token — an existing, consistent gap in
this file, not something this change introduces):

```dart
  // Neutral.
  $neutralSurface: AppColors.neutral050,
  $neutralSurfaceStrong: AppColors.neutral200,
  $neutralUi: AppColors.neutral500,
  $neutralUiHover: AppColors.neutral600,
  $neutralText: AppColors.neutral700,
  $neutralTextStrong: AppColors.neutral800,
};
```

`lib/src/components/icon_2/icon.dart` — remove the `import 'icon_size.dart';`
line; `DsIconSize` already resolves via the existing `import 'icon_variant.dart';`.

## File Structure

```
lib/src/components/icon_container/
  icon_container.dart                  # IconContainer widget + `part` declaration
  icon_container_size.dart             # enum DsIconContainerSize
  icon_container_style_resolver.dart   # part of 'icon_container.dart'
```

`IconContainer` reuses `DsIconVariant` from `icon_2/icon_variant.dart` rather
than declaring its own variant enum — one variant vocabulary for both the
glyph's color and the chip's background keeps them visually coupled by
construction.

## Widget API

```dart
class IconContainer extends StatelessWidget {
  const IconContainer(
    this.glyph, {
    super.key,
    this.variant = DsIconVariant.neutral,
    this.size = DsIconContainerSize.md,
    this.style,
  });

  final IconData glyph;
  final DsIconVariant variant;
  final DsIconContainerSize size;

  /// Escape hatch merged on top of the resolved style — same shape as
  /// `Icon.style` / `DsButton.style`.
  final BoxStyler? style;
}
```

## Size resolution

`DsIconContainerSize` maps to an (outer square dimension, inner `DsIconSize`)
pair. Outer dimensions are literal doubles, not spacing tokens — same
precedent as `button_2_style_resolver.dart`'s `height(36/44/56)`:

| `DsIconContainerSize` | outer square | inner `DsIconSize` |
|---|---|---|
| `sm` | 24 | `sm` (16) |
| `md` | 32 | `md` (20) |
| `lg` | 40 | `lg` (24) |
| `xl` | 56 | `xl` (32) |

## Variant resolution

Background and glyph color both key off `DsIconVariant`, mirroring Badge's
variant → background+foreground mapping:

| `DsIconVariant` | background token | glyph color (via `Icon`'s own resolver) |
|---|---|---|
| `neutral` | `$neutralSurface` | `$neutralText` |
| `brand` | `$brandSurface` | `$brandText` |
| `positive` | `$positiveSurface` | `$positiveText` |
| `negative` | `$negativeSurface` | `$negativeText` |
| `warning` | `$warningSurface` | `$warningText` |

## Shape

Constant `$radius008` corner radius on the `Box`, regardless of `size` — same
precedent as `button_2` using one constant radius across all its sizes,
rather than scaling radius with container size.

## Implementation sketch

```dart
Widget build(BuildContext context) {
  final (dimension, iconSize) = _resolveIconContainerSize(size);
  final resolvedStyle = BoxStyler()
      .size(dimension, dimension)
      .color(_resolveIconContainerBackground(variant))
      .borderRadiusAll($radius008())
      .merge(style);

  return Box(
    style: resolvedStyle,
    child: Center(child: Icon(glyph, size: iconSize, variant: variant)),
  );
}
```

## Non-goals

- No new `lib/ui.dart` export, no catalog `componentRegistry` entry — same
  as `icon_2`/`button_2`, neither of which is wired in yet.
- No automated test suite (none exists in this package) — verification is
  `flutter analyze`, with the same caveat as the `icon_2` plan: if the local
  Flutter SDK is too old to satisfy `pubspec.yaml`'s `mix`/`remix`
  constraints, fall back to manual side-by-side review and state that
  explicitly.
