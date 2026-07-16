part of 'toggle_2.dart';

RemixToggleStyler resolveDsToggleStyle({
  required DsToggleVariant variant,
  required DsToggleSize size,
  required bool disabled,
}) {
  final baseStyle = RemixToggleStyler()
      .borderRadiusAll($radius008())
      .mainAxisSize(MainAxisSize.min);

  final sizeStyle = switch (size) {
    DsToggleSize.sm => RemixToggleStyler()
        .paddingX($spacing008())
        .paddingY($spacing004())
        .spacing($spacing004())
        .labelStyle($labelSm.mix())
        .iconSize(16),
    DsToggleSize.md => RemixToggleStyler()
        .paddingX($spacing012())
        .paddingY($spacing008())
        .spacing($spacing004())
        .labelStyle($labelMd.mix())
        .iconSize(18),
    DsToggleSize.lg => RemixToggleStyler()
        .paddingX($spacing016())
        .paddingY($spacing010())
        .spacing($spacing006())
        .labelStyle($labelLg.mix())
        .iconSize(20),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsToggleVariant.ghost => RemixToggleStyler()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyler().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyler()
              .backgroundColor($brandSurface())
              .foregroundColor($brandText()),
        ),
    DsToggleVariant.outline => RemixToggleStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyler().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyler()
              .backgroundColor($brandSurface())
              .foregroundColor($brandText())
              .borderAll(color: $brandUi()),
        ),
  };

  final stateStyle = disabled
      ? RemixToggleStyler().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixToggleStyler();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
