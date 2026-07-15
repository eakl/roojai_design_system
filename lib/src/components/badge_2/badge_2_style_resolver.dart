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
