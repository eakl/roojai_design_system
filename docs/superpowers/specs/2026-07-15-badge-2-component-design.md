# `badge_2` (`DsBadge`) design

## Context

Continues the `_2` migration established by `button_2`, `input_2`,
`select_2`, `switch_2`, `toggle_2`, `progress_2`, `spinner_2`, `tabs_2`,
`skeleton_2`, `separator_2`. `lib/ui.dart` already has the legacy `badge`
export commented out, marking the slot `badge_2` is meant to fill.

Unlike `skeleton_2` (which has no Remix counterpart and is built directly
on `Box`), Remix ships `RemixBadge` — a `StyleWidget<RemixBadgeSpec>` with
`label`/`child`/`labelBuilder` content slots and a `RemixBadgeStyle`
(`container: BoxStyler`, `text: TextStyler`). `badge_2` follows the
`button_2`/`switch_2` precedent: a thin wrapper supplying a resolved
`RemixBadgeStyle` from this DS's Mix semantic tokens.

Remix's own docs (docs.page/btwld/remix/components/badge) don't define a
fixed size/variant enum for `RemixBadge` itself — sizing and variants are
left to the consuming design system, same as every other Remix component
this repo has migrated. The Fortal reference styles bundled with the
package (`fortal_badge_styles.dart`) sketch one such example (`solid`,
`soft`, `surface`, `outline` variants × `size1..3`) but aren't used
directly here — this DS defines its own enums to match its own token set,
same as `button_2` did for `DsButtonVariant`/`DsButtonSize`.

## File structure

```
lib/src/components/badge_2/
  badge_2.dart                 — DsBadge widget (StatelessWidget)
  badge_2_style_resolver.dart  — part of badge_2.dart; resolveDsBadgeStyle()
  badge_2_variants.dart        — DsBadgeVariant, DsBadgeSize enums
```

## `badge_2_variants.dart`

```dart
enum DsBadgeSize { sm, md, lg }

enum DsBadgeVariant {
  primary,
  secondary,
  outline,
  ghost,
  positive,
  negative,
  warning,
  info,
  neutral,
}
```

`DsBadgeSize` is a direct port of legacy `BadgeSize`.

`DsBadgeVariant` merges legacy `BadgeVariant`'s structural variants
(`primary`, `secondary`, `outline`, `ghost`) with the semantic status
palette now available as tokens in `colors.dart` (`positive`, `negative`,
`warning`, `info`, `neutral`). Legacy `BadgeVariant.destructive` is not
ported as its own case — it resolved to `colors.negative.surface` /
`colors.negative.textStrong`, the exact same tokens the new `negative`
case uses, so keeping both would be two names for one color. Any caller
using `destructive` maps onto `negative`.

## Widget API (`badge_2.dart`)

```dart
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.variant = DsBadgeVariant.primary,
    this.size = DsBadgeSize.md,
    this.style = const RemixBadgeStyle.create(),
    this.styleSpec,
  });

  /// The badge's text content. Always shown.
  final String label;

  /// Widget shown before [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent. Same convention as legacy `Badge.leading`.
  final Widget? leading;

  /// Widget shown after [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent.
  final Widget? trailing;

  /// Visual treatment — see [DsBadgeVariant].
  final DsBadgeVariant variant;

  /// Physical size — see [DsBadgeSize].
  final DsBadgeSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsBadgeStyle]'s output). Replaces
  /// legacy `Badge`'s dedicated `backgroundColor`/`foregroundColor`
  /// params — same convention as [DsButton.style]/[DsSwitch.style]
  /// (`RemixBadgeStyle().backgroundColor(...)`/`.foregroundColor(...)`
  /// cover the same cases).
  final RemixBadgeStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixBadgeSpec] directly, bypassing style resolution entirely.
  final RemixBadgeSpec? styleSpec;
}
```

No `child`/`labelBuilder` passthrough — legacy `Badge` has no such slots,
and nothing in this migration calls for adding them.

### `build()`

```dart
@override
Widget build(BuildContext context) {
  final resolvedStyle = resolveDsBadgeStyle(
    variant: variant,
    size: size,
  ).merge(style);

  return RemixBadge(
    label: label,
    style: resolvedStyle,
    styleSpec: styleSpec,
    labelBuilder: (leading == null && trailing == null)
        ? null
        : (context, spec, resolvedLabel) => _buildLabelWithIcons(
              spec: spec,
              label: resolvedLabel,
              leading: leading,
              trailing: trailing,
              size: size,
            ),
  );
}
```

`labelBuilder` is `RemixBadge`'s hook for rendering custom content while
still receiving the resolved `TextSpec` — used here only when an icon
slot is present, so the plain-label case (no icon slots) renders through
`RemixBadge`'s own default `StyledText(label, styleSpec: spec.text)`
path unchanged, same as the legacy widget's `if (leading != null)` /
`if (trailing != null)` conditionals in its `Row`.

`_buildLabelWithIcons` (private top-level function in `badge_2.dart`)
ports the legacy widget's icon-flanked `Row` build, using the label's
resolved `TextSpec.style` for the text run:

```dart
Widget _buildLabelWithIcons({
  required TextSpec spec,
  required String label,
  required Widget? leading,
  required Widget? trailing,
  required DsBadgeSize size,
}) {
  final iconExtent = _iconExtentFor(size);
  final iconGap = _iconGapFor(size);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[
        SizedBox(width: iconExtent, height: iconExtent, child: leading),
        SizedBox(width: iconGap),
      ],
      Text(label, style: spec.style),
      if (trailing != null) ...[
        SizedBox(width: iconGap),
        SizedBox(width: iconExtent, height: iconExtent, child: trailing),
      ],
    ],
  );
}

double _iconExtentFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 10,
      DsBadgeSize.md => 12,
      DsBadgeSize.lg => 14,
    };

double _iconGapFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 4,
      DsBadgeSize.md => 4,
      DsBadgeSize.lg => 6,
    };
```

Icon sizing/gap stays outside `RemixBadgeStyle` (which only has
`container`/`text` fields, no icon slot) — same reasoning legacy
`Badge`'s `_resolveIconGap`/`_resolveIconExtent` helpers already
establish, just ported to `double` literals instead of Mix tokens since
these aren't `BoxStyler`/`TextStyler` properties.

## Style resolver (`badge_2_style_resolver.dart`)

```dart
part of 'badge_2.dart';

RemixBadgeStyle resolveDsBadgeStyle({
  required DsBadgeVariant variant,
  required DsBadgeSize size,
}) {
  final baseStyle = RemixBadgeStyle().borderRadiusAll($radius004());

  final sizeStyle = switch (size) {
    DsBadgeSize.sm => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing004())
            .paddingY($spacing002()),
        text: TextStyler(style: $captionSm.mix()),
      ),
    DsBadgeSize.md => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing008())
            .paddingY($spacing004()),
        text: TextStyler(style: $captionMd.mix()),
      ),
    DsBadgeSize.lg => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing012())
            .paddingY($spacing006()),
        text: TextStyler(style: $labelSm.mix()),
      ),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsBadgeVariant.primary => RemixBadgeStyle()
        .backgroundColor($surfaceInverted())
        .foregroundColor($contentOnBrand()),
    DsBadgeVariant.secondary => RemixBadgeStyle()
        .backgroundColor($surfaceAlternative())
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.outline => RemixBadgeStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .borderAll(color: $borderStrong(), width: 1),
    DsBadgeVariant.ghost => RemixBadgeStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.positive => RemixBadgeStyle()
        .backgroundColor($positiveSurface())
        .foregroundColor($positiveTextStrong()),
    DsBadgeVariant.negative => RemixBadgeStyle()
        .backgroundColor($negativeSurface())
        .foregroundColor($negativeTextStrong()),
    DsBadgeVariant.warning => RemixBadgeStyle()
        .backgroundColor($warningSurface())
        .foregroundColor($warningTextStrong()),
    DsBadgeVariant.info => RemixBadgeStyle()
        .backgroundColor($infoSurface())
        .foregroundColor($infoTextStrong()),
    DsBadgeVariant.neutral => RemixBadgeStyle()
        .backgroundColor($neutralSurface())
        .foregroundColor($neutralTextStrong()),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

Notes:

- No `disabled`/state axis and no `.animate(...)` — Badge is always
  non-interactive (no `onPressed`, no hover/press/focus), same as legacy
  `Badge`'s comment ("Unlike `Badge`'s closest sibling, `Button`, this
  widget is always non-interactive").
- `borderRadiusAll($radius004())` is fixed across all three sizes, not
  varied per size and not `$radiusFull()` (unlike legacy `Badge`, which
  used `AppRadius.radiusFull` for a pill shape) — this migration
  deliberately moves off the pill shape onto the DS's small-radius scale.
  `borderRadiusAll(Radius)` (from `BorderRadiusStyleMixin`, mixed into
  every `RemixContainerStyle` incl. `RemixBadgeStyle`) is used instead of
  `.borderRadius(BorderRadiusGeometryMix.circular(...))` because
  `.circular()` takes a plain `double`, and `$radius004()` resolves to a
  `RadiusRef` (a `Radius`, not a `double`) — same pattern
  `resolveDsSwitchStyle`'s `.borderRadiusAll($radiusFull())` already uses.
- `outline` is the only variant that sets a border; every other variant
  leaves `container`'s border unset (default none), same variant/border
  pairing as legacy `Badge`'s `_resolveBorderColor`. `.borderAll(...)` is
  chained directly on `RemixBadgeStyle()` — no `container: BoxStyler()`
  wrapping or `.merge()` needed, since `RemixContainerStyle` (which
  `RemixBadgeStyle` extends) already mixes in `BorderStyleMixin`, the
  same mixin family `borderRadiusAll` above comes from.
- `text` fields wrap each typography token in `TextStyler(style: ...)`
  (e.g. `TextStyler(style: $captionSm.mix())`) rather than assigning the
  token's `.mix()` result directly — `RemixBadgeStyle`'s `text` field is
  typed `TextStyler?`, not `TextStyleMix`/`TextStyleMixRef`, so the ref
  must be wrapped, mirroring `LabelStyleMixin.labelStyle`'s own internal
  `label(TextStyler(style: value))` wrapping.
- Padding uses one token tier below legacy `Badge`'s literal values —
  `sm`/`md`/`lg` map to `$spacing004()`/`$spacing008()`/`$spacing012()`
  (paired with `$spacing002()`/`$spacing004()`/`$spacing006()` vertically)
  rather than a direct `spacing8/12/16` port — a deliberate tightening for
  badge_2, not a port of the legacy numbers.

## Catalog registration

Add `example/lib/catalog/specs/badge_2_showcase_spec.dart`, following
`button_2_showcase_spec.dart`'s three-axis shape (Badge has both a
variant and a size axis, unlike `skeleton_2`/`separator_2`):

- `variantsBuilder`: one `DsBadge` per `DsBadgeVariant.values` (9 total),
  `label: variant.name`.
- `sizesBuilder`: one `DsBadge` per `DsBadgeSize.values`, `label:
  size.name`.
- `statesBuilder`: plain label, label with `leading` icon, label with
  `trailing` icon — mirrors `button_2_showcase_spec.dart`'s leading/
  trailing examples, using `PhosphorIcons.circle()` through this DS's
  `Icon` widget.

Register `'Badge 2': buildBadge2ShowcaseSpec` in
`example/lib/catalog/component_registry.dart`, and export
`badge_2/badge_2.dart` + `badge_2/badge_2_variants.dart` from
`lib/ui.dart` in place of the currently-commented-out `badge`,
`badge_size`, `badge_variant` exports.

## Out of scope

- `child`/`labelBuilder` public passthrough params — legacy `Badge` has
  no such slots.
- Dedicated `backgroundColor`/`foregroundColor` override params — the
  `style` escape hatch covers the same cases (see widget API above).
- Any interactive/pressed state — Badge stays non-interactive, same as
  the legacy widget.
