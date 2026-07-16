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

  // `surface` has a background + `$borderDefault` border; `elevated`
  // trades the border for a shadow (having both would double the edge
  // treatment); `ghost` has neither, matching Fortal's ghost; `bordered`
  // has no background but an emphasized `$borderStrong` border.
  final variantStyle = switch (variant) {
    DsCardVariant.surface => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .borderAll(color: $borderDefault(), width: 1),
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.ghost => RemixCardStyler().backgroundColor(transparent),
    // Transparent background with an emphasized border — no fill to help
    // it read visually, so it uses $borderStrong (vs. `surface`'s
    // $borderDefault) rather than reusing surface's subtler border color.
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
