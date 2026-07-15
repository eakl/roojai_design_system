part of 'badge_2.dart';

// Style resolver for DsBadge.
//
// Single entry point `resolveDsBadgeStyle` builds one `RemixBadgeStyle` by
// merging fragments — base, then size, then variant — mirroring the
// base/size/variant composition in `button_2_style_resolver.dart` (minus
// the state fragment: DsBadge has no `disabled`/interactive axis, same
// decision the legacy `Badge`'s doc comment already establishes — "always
// non-interactive").

/// Resolves the full `RemixBadgeStyle` for a [DsBadge], given its
/// [variant] and [size].
RemixBadgeStyle resolveDsBadgeStyle({
  required DsBadgeVariant variant,
  required DsBadgeSize size,
}) {
  // `RemixBadgeStyle.borderRadius` takes a `BorderRadiusGeometryMix`, and
  // its `.circular()` factory takes a plain `double` — it can't accept a
  // Mix token reference (`$radius004()` resolves to a `RadiusRef`, not a
  // `double`). `borderRadiusAll(Radius)` (from `BorderRadiusStyleMixin`,
  // mixed into every `RemixContainerStyle` incl. `RemixBadgeStyle`) takes
  // a `Radius` instead, which a token ref satisfies — same pattern
  // `resolveDsSwitchStyle`'s `.borderRadiusAll($radiusFull())` already
  // uses.
  final baseStyle = RemixBadgeStyle().borderRadiusAll($radius004());

  // `RemixBadgeStyle.create`'s `text` field is typed `TextStyler?`, not
  // `TextStyleMixRef`/`TextStyleMix` — a token's `.mix()` (e.g.
  // `$captionSm.mix()`) must be wrapped in `TextStyler(style: ...)` before
  // it can be assigned, mirroring `LabelStyleMixin.labelStyle`'s own
  // `label(TextStyler(style: value))` internals.
  final sizeStyle = switch (size) {
    DsBadgeSize.sm => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing008())
            .paddingY($spacing002()),
        text: TextStyler(style: $captionSm.mix()),
      ),
    DsBadgeSize.md => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing012())
            .paddingY($spacing004()),
        text: TextStyler(style: $captionMd.mix()),
      ),
    DsBadgeSize.lg => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing016())
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
        .merge(
          RemixBadgeStyle(
            container: BoxStyler().borderAll(color: $borderStrong(), width: 1),
          ),
        ),
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
