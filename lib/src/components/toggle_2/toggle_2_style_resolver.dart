part of 'toggle_2.dart';

RemixToggleStyle resolveDsToggleStyle({
  required DsToggleVariant variant,
  required DsToggleSize size,
  required bool disabled,
}) {
  final baseStyle = RemixToggleStyle()
      .borderRadiusAll($radius008())
      .mainAxisSize(MainAxisSize.min);

  final sizeStyle = switch (size) {
    DsToggleSize.sm => RemixToggleStyle()
        .paddingX($spacing008())
        .paddingY($spacing004())
        .spacing($spacing004())
        .labelStyle($labelSm.mix())
        .iconSize(16),
    DsToggleSize.md => RemixToggleStyle()
        .paddingX($spacing012())
        .paddingY($spacing008())
        .spacing($spacing004())
        .labelStyle($labelMd.mix())
        .iconSize(18),
    DsToggleSize.lg => RemixToggleStyle()
        .paddingX($spacing016())
        .paddingY($spacing010())
        .spacing($spacing006())
        .labelStyle($labelLg.mix())
        .iconSize(20),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsToggleVariant.ghost => RemixToggleStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($brandSurface())
              .foregroundColor($brandText()),
        ),
    DsToggleVariant.outline => RemixToggleStyle()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($brandSurface())
              .foregroundColor($brandText())
              .borderAll(color: $brandUi()),
        ),
  };

  final stateStyle = disabled
      ? RemixToggleStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixToggleStyle();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
