part of 'button_2.dart';

Color _darken(ColorToken token, {int amount = 5}) {
  return ColorRef(token().directives([DarkenColorDirective(amount)]));
}

Color _opacity(ColorToken token, double opacity) {
  return ColorRef(token().directives([OpacityColorDirective(opacity)]));
}

RemixButtonStyler resolveDsButtonStyle({
  required DsButtonVariant variant,
  required DsButtonSize size,
  required bool disabled,
  required bool loading,
}) {
  final baseStyle = RemixButtonStyler()
      .borderRadiusAll($radius008())
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  final sizeStyle = switch (size) {
    DsButtonSize.sm =>
      RemixButtonStyler()
          .height(36)
          .paddingX($spacing012())
          .paddingY($spacing008())
          .spacing(6)
          .labelStyle($labelMd.mix())
          .iconSize(20)
          .spinnerSize(20),
    DsButtonSize.md =>
      RemixButtonStyler()
          .height(44)
          .paddingX($spacing016())
          .paddingY($spacing010())
          .spacing(8)
          .labelStyle($labelLg.mix())
          .iconSize(20)
          .spinnerSize(20),
    DsButtonSize.lg =>
      RemixButtonStyler()
          .height(56)
          .paddingX($spacing020())
          .paddingY($spacing016())
          .spacing(8)
          .labelStyle($labelLg.mix())
          .iconSize(24)
          .spinnerSize(24),
  };

  final variantStyle = switch (variant) {
    DsButtonVariant.primary =>
      RemixButtonStyler()
          .color($surfaceInverted())
          .labelColor($contentOnBrand())
          .iconColor($contentOnBrand())
          .spinnerIndicatorColor($contentOnBrand())
          .onPressed(
            RemixButtonStyler().color(_darken($surfaceInverted)),
          ),
    DsButtonVariant.secondary =>
      RemixButtonStyler()
          .color($surfaceAlternative())
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(
            RemixButtonStyler().color(_darken($surfaceAlternative)),
          ),
    DsButtonVariant.outline =>
      RemixButtonStyler()
          .borderAll(color: $brandUi(), width: 1)
          .backgroundColor(_opacity($canvasAlternative, 0))
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(RemixButtonStyler().color(_opacity($canvasAlternative, 1))),
    DsButtonVariant.ghost =>
      RemixButtonStyler()
          .backgroundColor(_opacity($canvasAlternative, 0))
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(RemixButtonStyler().color(_opacity($canvasAlternative, 1))),
    DsButtonVariant.destructive =>
      RemixButtonStyler()
          .color($negativeSurface())
          .labelColor($contentPrimary())
          .iconColor($contentPrimary())
          .spinnerIndicatorColor($contentPrimary())
          .onPressed(
            RemixButtonStyler().color(_darken($negativeSurface)),
          ),
    DsButtonVariant.link =>
      RemixButtonStyler()
          .color($transparent())
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(RemixButtonStyler().labelDecoration(TextDecoration.underline)),
  };

  final stateStyle = disabled
      ? RemixButtonStyler().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixButtonStyler();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
