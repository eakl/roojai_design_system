# avatar_2 component design

## Context

Legacy `Avatar` (`lib/src/components/avatar/`) is a hand-rolled `ClipOval` +
`Stack` widget: a photo with initials fallback, three sizes (`sm`/`md`/`lg`),
and an optional bottom-right status badge slot. `AvatarGroup` sits alongside
it for overlapping-avatar rows with a "+N" overflow indicator.

This spec covers porting `Avatar` to the `_2` generation — `DsAvatar`, built
on the `remix` package's `RemixAvatar` — following the structural precedent
set by `button_2`, `badge_2`, and `input_2` (a DS wrapper that resolves a
`RemixAvatarStyle` from DS enums/tokens and forwards to the Remix widget).

`AvatarGroup` and the status-badge slot are explicitly out of scope for this
pass — see "Out of scope" below.

## API

```dart
class DsAvatar extends StatefulWidget {
  const DsAvatar({
    super.key,
    this.image,
    this.onImageError,
    this.label,
    this.icon,
    this.variant = DsAvatarVariant.soft,
    this.size = DsAvatarSize.md,
    this.shape = DsAvatarShape.circle,
    this.style = const RemixAvatarStyle.create(),
    this.styleSpec,
  });

  final ImageProvider? image;
  final ImageErrorListener? onImageError;
  final String? label;
  final IconData? icon;
  final DsAvatarVariant variant;
  final DsAvatarSize size;
  final DsAvatarShape shape;
  final RemixAvatarStyle style;
  final StyleSpec<RemixAvatarSpec>? styleSpec;
}
```

- **`image`** — the avatar's photo, from any `ImageProvider` (`NetworkImage`,
  `AssetImage`, `MemoryImage`, `FileImage`, ...). When null, or when it fails
  to decode/load, `label`/`icon` render instead.
- **`onImageError`** — optional passthrough so callers can also observe
  image-load failures (e.g. for logging), independent of the automatic
  fallback below.
- **`label`** — fallback initials text. Normalized the same way legacy
  `Avatar` does: trimmed, uppercased, truncated to 2 characters — so a caller
  passing a full name or lowercase text still lays out as a compact
  two-glyph circle instead of overflowing.
- **`icon`** — fallback icon, shown when `image` is absent/failed and
  `label` is null. Same content-priority chain as `RemixAvatar` itself
  (`label` wins over `icon` when both are given).
- **`variant`** — see [`DsAvatarVariant`](#enums). Affects only the
  fallback's colors — a rendered photo visually hides them.
- **`size`** — see [`DsAvatarSize`](#enums).
- **`shape`** — see [`DsAvatarShape`](#enums).
- **`style`** — escape hatch merged on top of `resolveDsAvatarStyle`'s
  output, same convention as `DsButton.style`/`DsBadge.style`.
- **`styleSpec`** — escape hatch to supply an already-resolved
  `RemixAvatarSpec` directly, bypassing style resolution — same convention
  as `DsBadge.styleSpec`.

There is no `child` escape hatch — legacy `Avatar` never had one, and no
other `_2` component exposes a raw-content override either.

### Automatic image-fallback (why `DsAvatar` is stateful)

`RemixAvatar` does not swap to fallback content automatically on image
failure — it only exposes `onBackgroundImageError`/`onForegroundImageError`
callbacks, leaving state management to the caller. Legacy `Avatar` auto-swaps
via `Image.errorBuilder`. To preserve that ergonomic behavior, `DsAvatar` is
a `StatefulWidget`:

- Internal `_imageFailed` flag starts `false`.
- `RemixAvatar` is given `backgroundImage: widget.image` normally, with
  `onBackgroundImageError` wired to a handler that sets `_imageFailed = true`
  (via `setState`) and also forwards to `widget.onImageError`.
- Once `_imageFailed` is true, `build` passes `backgroundImage: null`
  instead, so `RemixAvatar` renders `label`/`icon` fallback content.
- `didUpdateWidget` resets `_imageFailed` to `false` whenever `widget.image`
  changes (by identity/equality), so a newly-assigned image gets a fresh
  load attempt instead of being permanently stuck on the old failure.

This makes `DsAvatar` the first `_2` component that's a `StatefulWidget`
rather than `StatelessWidget` — every prior `_2` component delegates all
interaction/async state to its underlying Remix widget; here, the automatic
fallback behavior has no Remix-level equivalent to delegate to.

## Enums

```dart
enum DsAvatarSize { sm, md, lg, xl }   // 24 / 32 / 40 / 64 px diameter
enum DsAvatarVariant { soft, solid }
enum DsAvatarShape { circle, square }
```

- **`DsAvatarSize`** — four sizes, matching `RemixAvatar`'s own Fortal preset
  scale (`FortalAvatarSize`: 24/32/40/64px) rather than the 3-size
  `sm`/`md`/`lg` convention used by `DsButton`/`DsBadge`/`DsInput`. Chosen
  deliberately over the 3-size legacy scale (32/40/56) since it aligns
  `DsAvatar` with the Remix package's own avatar sizing and gives a
  dedicated small size (24px) for compact contexts (e.g. comment threads)
  that legacy `Avatar` didn't have.
- **`DsAvatarVariant`** — `soft` (tinted background, accent-colored fallback
  text/icon) and `solid` (bold accent background, on-brand contrast text/
  icon), matching `RemixAvatar`'s own `FortalAvatarVariant` naming and
  intent, resolved through DS semantic tokens instead of raw Fortal tokens.
- **`DsAvatarShape`** — `circle` (default, matches legacy `Avatar`'s
  always-round shape) or `square` (rounded-square, matching `RemixAvatar`'s
  Fortal preset default). Exposed as a caller choice since both shapes are
  common in avatar usage (circle for people, rounded-square for
  organizations/bots is a common UI convention) and Remix already supports
  both cleanly via `borderRadius`.

## Style resolution (`avatar_2_style_resolver.dart`)

`resolveDsAvatarStyle({ required DsAvatarVariant variant, required DsAvatarSize size, required DsAvatarShape shape })`
returns a `RemixAvatarStyle`, merged the same way `resolveDsBadgeStyle`/
`resolveDsButtonStyle` do (`base.merge(sizeStyle).merge(variantStyle).merge(shapeStyle)`),
then merged with the caller's `style` in `DsAvatar.build`.

**Base**: `.clipBehavior(Clip.hardEdge)` (required for `image` to actually
clip to the resolved shape — `BoxDecoration`'s image otherwise ignores
`borderRadius`) and `.labelFontWeight(FontWeight.w500)` (matches legacy
`Avatar`'s and Remix Fortal's fallback-text weight).

**Size** (`.square(diameter)` + label typography + fallback icon size):

| `DsAvatarSize` | diameter | label style    | icon size (`DsIconSize`) |
|----------------|----------|----------------|---------------------------|
| `sm`           | 24       | `$captionSm`   | `sm` (16px)               |
| `md`           | 32       | `$labelSm`     | `md` (20px)               |
| `lg`           | 40       | `$labelMd`     | `lg` (24px)               |
| `xl`           | 64       | `$labelLg`     | `xl` (32px)               |

The icon-size mapping reuses `icon_2`'s existing `DsIconSize` enum 1:1 (both
have exactly 4 steps), the same way `input_2` maps `DsInputSize` onto
`DsIconSize` for its leading/trailing icons.

**Shape**:
- `circle` → `.borderRadiusAll($radiusFull())` at every size (a token large
  enough that a square container renders fully round).
- `square` → per-size radius, increasing with diameter so corner rounding
  stays proportional: `sm` → `$radius004`, `md` → `$radius008`,
  `lg` → `$radius012`, `xl` → `$radius016`.

**Variant** (fallback label/icon color + fallback background):
- `soft` → `.backgroundColor($accentSurface())`, `.labelColor($accentText())`,
  `.iconColor($accentText())`.
- `solid` → `.backgroundColor($accentSurfaceStrong())`,
  `.labelColor($contentOnBrand())`, `.iconColor($contentOnBrand())`.

(`backgroundColor` only visually matters when no `image` is showing —
`RemixAvatar` paints the image as a `BoxDecoration.image`, which sits above
the container's background color.)

## Out of scope

- **Status/online-indicator badge slot** — legacy `Avatar.badge` renders a
  bottom-right ringed indicator. Left out of `DsAvatar` v1, matching
  `input_2`'s precedent of trimming secondary concerns (multiline/file-drop)
  from a first `_2` pass. Can be added as a later enhancement or folded into
  a future `avatar_group_2`.
- **`AvatarGroup` / `avatar_group_2`** — overlapping-avatar row with "+N"
  overflow. Out of scope for this task; a separate future component.

## Catalog

Add `avatar_2_showcase_spec.dart` under `example/lib/catalog/specs/`,
following `badge_2_showcase_spec.dart`'s structure: a `variantsBuilder` over
`DsAvatarVariant.values`, a `sizesBuilder` over `DsAvatarSize.values`, and a
`statesBuilder` covering: image (network image), image that fails to load
(verifies automatic fallback), label-only fallback, icon-only fallback, and
both shapes. Register `'Avatar 2': buildAvatar2ShowcaseSpec` in
`component_registry.dart`.

## Exports

Add to `lib/ui.dart`:
```dart
export 'src/components/avatar_2/avatar_2.dart';
export 'src/components/avatar_2/avatar_2_variants.dart';
```
