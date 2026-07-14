part of 'icon_container.dart';

// Style resolvers for IconContainer.
//
// One pure function per resolved property (outer size + inner icon size,
// background color), same one-resolver-per-property split as every other
// component in this package (see `icon_style_resolver.dart`,
// `badge_style_resolvers.dart`).

/// Resolves an [IconContainer]'s outer square dimension and its inner
/// glyph's [DsIconSize], given its [size].
(double, DsIconSize) _resolveIconContainerSize(DsIconContainerSize size) {
  switch (size) {
    case DsIconContainerSize.sm:
      return (24, DsIconSize.sm);
    case DsIconContainerSize.md:
      return (32, DsIconSize.md);
    case DsIconContainerSize.lg:
      return (40, DsIconSize.lg);
    case DsIconContainerSize.xl:
      return (56, DsIconSize.xl);
  }
}

/// Resolves an [IconContainer]'s square background color, given its
/// [variant]. The glyph color itself is resolved separately by `Icon`'s
/// own `resolveDsIconStyle` — this function only supplies the background.
Color _resolveIconContainerBackground(DsIconVariant variant) {
  switch (variant) {
    case DsIconVariant.neutral:
      return $neutralSurface();
    case DsIconVariant.brand:
      return $brandSurface();
    case DsIconVariant.positive:
      return $positiveSurface();
    case DsIconVariant.negative:
      return $negativeSurface();
    case DsIconVariant.warning:
      return $warningSurface();
  }
}
