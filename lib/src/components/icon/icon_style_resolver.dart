part of 'icon.dart';

// Style resolver for Icon.
//
// One pure function per resolved property (size, color), same
// one-resolver-per-property split as every other component in this
// package (see `button_2_style_resolver.dart`, `badge_style_resolvers.dart`).

/// Resolves the full `IconStyler` for an [Icon], given its [size] and
/// [variant].
IconStyler resolveIconStyle({
  required IconSize size,
  required IconVariant variant,
}) {
  return IconStyler()
      .size(_resolveIconSize(size))
      .color(_resolveIconColor(variant));
}

double _resolveIconSize(IconSize size) {
  switch (size) {
    case IconSize.sm:
      return $spacing016();
    case IconSize.md:
      return $spacing020();
    case IconSize.lg:
      return $spacing024();
    case IconSize.xl:
      return $spacing032();
  }
}

Color _resolveIconColor(IconVariant variant) {
  switch (variant) {
    case IconVariant.neutral:
      return $iconNeutral();
    case IconVariant.brand:
      return $brandText();
    case IconVariant.positive:
      return $positiveText();
    case IconVariant.negative:
      return $negativeText();
    case IconVariant.warning:
      return $warningText();
  }
}
