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
  required DsCardTone tone,
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

  // `elevated` trades a border for a shadow (having both would double the
  // edge treatment); `bordered` has no background but an emphasized
  // `$borderStrong` border; `filled` has a background (picked by [tone])
  // and no border in any tone, matching badge_2's borderless
  // primary/secondary precedent.
  final variantStyle = switch (variant) {
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
    DsCardVariant.filled => RemixCardStyler().backgroundColor(
        switch (tone) {
          // `base` reproduces the old `surface` variant's background
          // exactly, so the new default (filled + base) matches the old
          // default (surface) look.
          DsCardTone.base => $surfaceDefault(),
          DsCardTone.alternative => $surfaceAlternative(),
          DsCardTone.inverted => $surfaceInverted(),
        },
      ),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
