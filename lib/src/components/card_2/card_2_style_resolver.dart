part of 'card_2.dart';

// A local literal `BoxShadowMix` constant, same pattern as
// `dialog_2_style_resolver.dart`'s `_dialogShadow` — this DS's
// `$elevationLevelN` semantic tokens aren't consumed by any existing
// component yet (`dialog_2` already opted for a literal shadow instead),
// so `card_2` follows that same established precedent rather than being
// the first consumer of an unproven token path.
final _cardElevatedShadow = BoxShadowMix(
  color: const Color(0x1F000000),
  offset: const Offset(0, 2),
  blurRadius: 8,
);

RemixCardStyler resolveDsCardStyle({
  required DsCardVariant variant,
  required DsCardSize size,
}) {
  final baseStyle = RemixCardStyler().borderRadiusAll($radius008());

  final sizeStyle = switch (size) {
    DsCardSize.sm =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsCardSize.md =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsCardSize.lg =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  const transparent = Color(0x00000000);

  // `base`/`alternative`/`inverted` only differ by background color;
  // `elevated` trades a background tint for a shadow (having both would
  // double the edge treatment); `bordered` has no background, just an
  // emphasized `$borderStrong` border.
  final variantStyle = switch (variant) {
    DsCardVariant.base =>
      RemixCardStyler().backgroundColor($surfaceDefault()),
    DsCardVariant.alternative =>
      RemixCardStyler().backgroundColor($surfaceAlternative()),
    DsCardVariant.inverted =>
      RemixCardStyler().backgroundColor($surfaceInverted()),
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}

/// The child-facing foreground color for each [DsCardVariant] — consumed by
/// `card_2.dart`'s `build()` to color a `child` that doesn't explicitly set
/// its own color. Only `inverted` sits on a dark background, so it's the
/// only variant that needs `$contentOnBrand()` (white); every other variant
/// sits on a light/transparent background and uses the same
/// `$contentPrimary()` default body text color.
Color _resolveDsCardForegroundColor(DsCardVariant variant) {
  return switch (variant) {
    DsCardVariant.inverted => $contentOnBrand(),
    DsCardVariant.base ||
    DsCardVariant.alternative ||
    DsCardVariant.elevated ||
    DsCardVariant.bordered => $contentPrimary(),
  };
}
