part of 'avatar_2.dart';

RemixAvatarStyle resolveDsAvatarStyle({
  required DsAvatarVariant variant,
  required DsAvatarSize size,
  required DsAvatarShape shape,
}) {
  // `clipBehavior(.hardEdge)` is required for `image` to actually clip to
  // the resolved shape — `BoxDecoration`'s image otherwise ignores
  // `borderRadius`. `labelFontWeight` matches legacy `Avatar`'s and Remix
  // Fortal's fallback-text weight.
  final baseStyle = RemixAvatarStyle()
      .clipBehavior(Clip.hardEdge)
      .labelFontWeight(FontWeight.w500);

  final sizeStyle = switch (size) {
    DsAvatarSize.sm => RemixAvatarStyle()
        .square(24)
        .labelStyle($captionSm.mix()),
    DsAvatarSize.md => RemixAvatarStyle()
        .square(32)
        .labelStyle($labelSm.mix()),
    DsAvatarSize.lg => RemixAvatarStyle()
        .square(40)
        .labelStyle($labelMd.mix()),
    DsAvatarSize.xl => RemixAvatarStyle()
        .square(64)
        .labelStyle($labelLg.mix()),
  };

  // Icon fallback size is fixed per `size`, reusing `icon_2`'s own
  // `DsIconSize` scale 1:1 (both have exactly 4 steps) — same pattern as
  // `input_2`'s `_resolveDsInputIconSize`. `DsAvatar` maps this separately
  // in `avatar_2.dart` when building the `Icon` fallback widget; here we
  // only size Remix's own `IconStyler` slot to match, in case a caller's
  // `iconBuilder`-less default path is ever exercised directly through
  // `styleSpec`.
  final iconSizeStyle = switch (size) {
    DsAvatarSize.sm => RemixAvatarStyle().iconSize($spacing016()),
    DsAvatarSize.md => RemixAvatarStyle().iconSize($spacing020()),
    DsAvatarSize.lg => RemixAvatarStyle().iconSize($spacing024()),
    DsAvatarSize.xl => RemixAvatarStyle().iconSize($spacing032()),
  };

  // `circle` uses a radius token large enough that a square container
  // renders fully round at every size. `square` uses a per-size radius
  // that grows with diameter so corner rounding stays proportional.
  final shapeStyle = switch (shape) {
    DsAvatarShape.circle => RemixAvatarStyle().borderRadiusAll($radiusFull()),
    DsAvatarShape.square => switch (size) {
        DsAvatarSize.sm => RemixAvatarStyle().borderRadiusAll($radius004()),
        DsAvatarSize.md => RemixAvatarStyle().borderRadiusAll($radius008()),
        DsAvatarSize.lg => RemixAvatarStyle().borderRadiusAll($radius012()),
        DsAvatarSize.xl => RemixAvatarStyle().borderRadiusAll($radius016()),
      },
  };

  // Fallback-only colors — a rendered `image` visually hides these, since
  // `RemixAvatar` paints the image as a `BoxDecoration.image` above the
  // container's background color.
  final variantStyle = switch (variant) {
    DsAvatarVariant.soft => RemixAvatarStyle()
        .backgroundColor($accentSurface())
        .labelColor($accentText())
        .iconColor($accentText()),
    DsAvatarVariant.solid => RemixAvatarStyle()
        .backgroundColor($accentSurfaceStrong())
        .labelColor($contentOnBrand())
        .iconColor($contentOnBrand()),
  };

  return baseStyle
      .merge(sizeStyle)
      .merge(iconSizeStyle)
      .merge(shapeStyle)
      .merge(variantStyle);
}
