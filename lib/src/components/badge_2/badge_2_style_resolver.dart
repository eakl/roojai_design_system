part of 'badge_2.dart';

RemixBadgeStyler resolveDsBadgeStyle({
  required DsBadgeVariant variant,
  required DsBadgeSize size,
}) {
  final baseStyle = RemixBadgeStyler()
      .borderRadiusAll($radius004())
      .borderAll(color: $transparent(), width: 1);

  final sizeStyle = switch (size) {
    DsBadgeSize.sm => RemixBadgeStyler(
        container: BoxStyler()
            .paddingX($spacing004())
            .paddingY($spacing002()),
        label: TextStyler(style: $labelSm.mix()),
      ),
    DsBadgeSize.md => RemixBadgeStyler(
        container: BoxStyler()
            .paddingX($spacing008())
            .paddingY($spacing002()),
        label: TextStyler(style: $labelSm.mix()),
      ),
    DsBadgeSize.lg => RemixBadgeStyler(
        container: BoxStyler()
            .paddingX($spacing012())
            .paddingY($spacing006()),
        label: TextStyler(style: $labelMd.mix()),
      ),
  };

  final variantStyle = switch (variant) {
    DsBadgeVariant.primary => RemixBadgeStyler()
        .backgroundColor($surfaceInverted())
        .foregroundColor($contentOnBrand()),
    DsBadgeVariant.secondary => RemixBadgeStyler()
        .backgroundColor($surfaceAlternative())
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.outline => RemixBadgeStyler()
        .backgroundColor($transparent())
        .foregroundColor($contentPrimary())
        .borderAll(color: $borderStrong(), width: 1),
    DsBadgeVariant.ghost => RemixBadgeStyler()
        .backgroundColor($transparent())
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.positive => RemixBadgeStyler()
        .backgroundColor($positiveSurface())
        .foregroundColor($positiveTextStrong()),
    DsBadgeVariant.negative => RemixBadgeStyler()
        .backgroundColor($negativeSurface())
        .foregroundColor($negativeTextStrong()),
    DsBadgeVariant.warning => RemixBadgeStyler()
        .backgroundColor($warningSurface())
        .foregroundColor($warningTextStrong()),
    DsBadgeVariant.info => RemixBadgeStyler()
        .backgroundColor($infoSurface())
        .foregroundColor($infoTextStrong()),
    DsBadgeVariant.neutral => RemixBadgeStyler()
        .backgroundColor($neutralSurface())
        .foregroundColor($neutralTextStrong()),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}


double resolveIconSize(DsBadgeSize size) => switch (size) {
  DsBadgeSize.sm => SemSpacing.spacing010,
  DsBadgeSize.md => SemSpacing.spacing012,
  DsBadgeSize.lg => SemSpacing.spacing016,
};

double resolveIconToLabelGap(DsBadgeSize size) => switch (size) {
  DsBadgeSize.sm => SemSpacing.spacing004,
  DsBadgeSize.md => SemSpacing.spacing004,
  DsBadgeSize.lg => SemSpacing.spacing006,
};
