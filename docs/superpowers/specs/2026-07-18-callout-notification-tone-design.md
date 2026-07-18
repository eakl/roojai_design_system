# callout_2 / notification_2 Soft/Solid Tone Design

**Goal:** Add a soft-vs-solid appearance axis to `DsCallout` and `DsNotification`, independent of their existing semantic-color `variant` (neutral/brand/positive/negative/warning). Today both components only render the "soft" look (tinted `*Surface` background + colored `*Text` foreground); this adds a "solid" look (saturated `*Ui` background + white `$contentOnBrand()` foreground), matching an established reference screenshot showing soft and solid alert pairs.

**Precedent:** `avatar_2` already has this exact soft/solid distinction (`DsAvatarVariant { soft, solid }`, resolved in `avatar_2_style_resolver.dart` as `*Surface`/`*Text` vs `*Ui`/`$contentOnBrand()`). `callout_2`/`notification_2` can't reuse the name `variant` for this axis since it's already the color axis, so this adds a second parameter named `tone` (user-selected name, distinct from `card_2`'s unrelated `DsCardTone { base, alternative, inverted }`, which chooses a *background color* rather than an emphasis level).

**Non-goals:** No change to `DsCalloutVariant`/`DsNotificationVariant` (color axis stays neutral/brand/positive/negative/warning). No change to `card_2`'s `DsCardTone`. No new color tokens — solid reuses each color's existing `*Ui` token (already defined in `lib/src/theme/light/colors.dart`) and `$contentOnBrand()` (white) for foreground.

## `callout_2`

- **`callout_2_variants.dart`**: add `enum DsCalloutTone { soft, solid }`.
- **`callout_2.dart`**: add `final DsCalloutTone tone;` field, default `DsCalloutTone.soft` (preserves current default appearance — additive, non-breaking). Pass `tone: tone` into `resolveDsCalloutStyle(...)`.
- **`callout_2_style_resolver.dart`**: `resolveDsCalloutStyle` gains `required DsCalloutTone tone`. The `variantStyle` switch nests under `tone`:
  - `soft` (existing behavior, unchanged): `neutral → $neutralSurface()/$neutralText()`, `brand → $brandSurface()/$brandText()`, `positive → $positiveSurface()/$positiveText()`, `negative → $negativeSurface()/$negativeText()`, `warning → $warningSurface()/$warningText()`.
  - `solid` (new): `neutral → $neutralUi()/$contentOnBrand()`, `brand → $brandUi()/$contentOnBrand()`, `positive → $positiveUi()/$contentOnBrand()`, `negative → $negativeUi()/$contentOnBrand()`, `warning → $warningUi()/$contentOnBrand()`.

## `notification_2`

- **`notification_2_variants.dart`**: add `enum DsNotificationTone { soft, solid }`.
- **`notification_2.dart`**: add `final DsNotificationTone tone;` field, default `DsNotificationTone.soft`. Pass `tone: tone` into `resolveDsNotificationContainerStyle`, `resolveDsNotificationTitleStyle`, `resolveDsNotificationTextStyle`, and `_resolveDsNotificationTextColor` (the last already drives the leading icon's color via `leadingColor`, so the icon flips to white automatically under solid tone).
- **`notification_2_style_resolver.dart`**:
  - `resolveDsNotificationContainerStyle` gains `required DsNotificationTone tone`; its `variantStyle` switch nests under `tone` the same way as callout's, using `*Surface` (soft) vs `*Ui` (solid) backgrounds.
  - `_resolveDsNotificationTextColor` gains `required DsNotificationTone tone`; returns `*Text` (soft) or `$contentOnBrand()` (solid) per color.
  - `resolveDsNotificationTitleStyle`/`resolveDsNotificationTextStyle` gain `required DsNotificationTone tone`, threaded through to `_resolveDsNotificationTextColor`.

## Showcase specs

Both `example/lib/catalog/specs/callout_2_showcase_spec.dart` and `notification_2_showcase_spec.dart` update `variantsBuilder` to enumerate all `variant` × `tone` combinations explicitly (5 colors × 2 tones = 10 entries each), the same explicit-enumeration approach the recent `card_2` variant/tone showcase update used, labeling each entry e.g. `'brand (soft)'` / `'brand (solid)'`.

## Known limitation

Solid `neutral` renders as a mid-gray bar (`$neutralUi()` = `PrimColors.neutral500`), not the near-black/white treatment sometimes seen in reference designs — there is no separate "true solid black" token in the current palette, and this design intentionally reuses the same `*Ui`/`$contentOnBrand()` pairing already established by `DsAvatarVariant.solid` for consistency rather than introducing a one-off. Confirmed acceptable with the user.

## Verification

No test suite in this repo — verification is `dart analyze` (both `lib/` and `example/`) after each change, plus a final manual check that the catalog app's Callout 2 and Notification 2 showcases render all 10 variant×tone combinations with the expected soft/solid look.
