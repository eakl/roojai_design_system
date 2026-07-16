part of 'avatar_2.dart';

RemixAvatarStyler resolveDsAvatarStyle({
  required DsAvatarVariant variant,
  required DsAvatarSize size,
  required DsAvatarShape shape,
}) {
  // `clipBehavior(.hardEdge)` is required for `image` to actually clip to
  // the resolved shape — `BoxDecoration`'s image otherwise ignores
  // `borderRadius`. `labelFontWeight` matches legacy `Avatar`'s and Remix
  // Fortal's fallback-text weight.
  final baseStyle = RemixAvatarStyler()
      .clipBehavior(Clip.hardEdge)
      .labelFontWeight(FontWeight.w500);

  // A subtle ring around every avatar, regardless of `image`/fallback
  // content, so photos (especially light ones) stay visually separated
  // from a similarly-colored page background. Width scales with size the
  // same way `AvatarGroup`'s own ring does.
  final ringWidth = switch (size) {
    DsAvatarSize.sm => 1.0,
    DsAvatarSize.md => 1.5,
    DsAvatarSize.lg => 1.5,
    DsAvatarSize.xl => 2.0,
  };
  final ringStyle = RemixAvatarStyler().borderAll(
    color: $transparent(),
    width: ringWidth,
  );

  final sizeStyle = switch (size) {
    DsAvatarSize.sm =>
      RemixAvatarStyler().square(24).labelStyle($captionSm.mix()),
    DsAvatarSize.md =>
      RemixAvatarStyler().square(32).labelStyle($labelSm.mix()),
    DsAvatarSize.lg =>
      RemixAvatarStyler().square(40).labelStyle($labelMd.mix()),
    DsAvatarSize.xl =>
      RemixAvatarStyler().square(64).labelStyle($labelLg.mix()),
  };

  // Icon fallback size is fixed per `size`. `DsAvatar` passes `icon`
  // straight through to `RemixAvatar` with no custom `iconBuilder`, so
  // this `IconStyler` slot is what actually sizes (and, via
  // `variantStyle` below, colors) every rendered fallback glyph — not a
  // niche `styleSpec`-only path.
  final iconSizeStyle = switch (size) {
    DsAvatarSize.sm => RemixAvatarStyler().iconSize($spacing016()),
    DsAvatarSize.md => RemixAvatarStyler().iconSize($spacing020()),
    DsAvatarSize.lg => RemixAvatarStyler().iconSize($spacing024()),
    DsAvatarSize.xl => RemixAvatarStyler().iconSize($spacing032()),
  };

  // `circle` uses a radius token large enough that a square container
  // renders fully round at every size. `square` uses a per-size radius
  // that grows with diameter so corner rounding stays proportional.
  final shapeStyle = switch (shape) {
    DsAvatarShape.circle => RemixAvatarStyler().borderRadiusAll($radiusFull()),
    DsAvatarShape.square => switch (size) {
      DsAvatarSize.sm => RemixAvatarStyler().borderRadiusAll($radius004()),
      DsAvatarSize.md => RemixAvatarStyler().borderRadiusAll($radius008()),
      DsAvatarSize.lg => RemixAvatarStyler().borderRadiusAll($radius012()),
      DsAvatarSize.xl => RemixAvatarStyler().borderRadiusAll($radius016()),
    },
  };

  // Fallback-only colors — a rendered `image` visually hides these, since
  // `RemixAvatar` paints the image as a `BoxDecoration.image` above the
  // container's background color.
  final variantStyle = switch (variant) {
    DsAvatarVariant.soft =>
      RemixAvatarStyler()
          .backgroundColor($accentSurface())
          .labelColor($accentText())
          .iconColor($accentText()),
    DsAvatarVariant.solid =>
      RemixAvatarStyler()
          .backgroundColor($accentSurfaceStrong())
          .labelColor($contentOnBrand())
          .iconColor($contentOnBrand()),
  };

  return baseStyle
      .merge(ringStyle)
      .merge(sizeStyle)
      .merge(iconSizeStyle)
      .merge(shapeStyle)
      .merge(variantStyle);
}
