part of 'icon_button_2.dart';

Color _iconButtonPressedBackground(ColorToken token, {int amount = 5}) {
  return ColorRef(token().directives([DarkenColorDirective(amount)]));
}

Color _opacity(ColorToken token, double opacity) {
  return ColorRef(token().directives([OpacityColorDirective(opacity)]));
}

RemixIconButtonStyler resolveDsIconButtonStyle({
  required DsIconButtonVariant variant,
  required DsIconButtonSize size,
  required bool disabled,
  required bool loading,
}) {
  // Same 100ms literal-`Curve`/`Duration` workaround as
  // `button_2_style_resolver.dart` — see that file's comment for why an
  // inline `$motionCurveStandard()`/`$motionDurationFast()` token
  // reference can't be used here instead.
  final baseStyle = RemixIconButtonStyler()
      .borderRadiusAll($radius008())
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // Square dimensions mirror `button_2`'s own `height()` per size, so an
  // icon button lines up with a same-size `DsButton` in a shared toolbar.
  // `iconSize`/spinner size scale the same way as `button_2`'s icon/spinner.
  final sizeStyle = switch (size) {
    DsIconButtonSize.sm =>
      RemixIconButtonStyler()
          .iconButtonSize(36)
          .iconSize(20)
          .spinner(RemixSpinnerStyler().size(20)),
    DsIconButtonSize.md =>
      RemixIconButtonStyler()
          .iconButtonSize(44)
          .iconSize(20)
          .spinner(RemixSpinnerStyler().size(20)),
    DsIconButtonSize.lg =>
      RemixIconButtonStyler()
          .iconButtonSize(56)
          .iconSize(24)
          .spinner(RemixSpinnerStyler().size(24)),
  };

  // Same rationale as `button_2_style_resolver.dart`'s `variantStyle`:
  // pressed feedback is a background-color change (darken for solid
  // fills, a light brand-tinted fill for transparent-background variants)
  // rather than an opacity modifier, which is reserved for `disabled`.
  final variantStyle = switch (variant) {
    DsIconButtonVariant.primary =>
      RemixIconButtonStyler()
          .backgroundColor($surfaceInverted())
          .foregroundColor($contentOnBrand())
          .spinner(RemixSpinnerStyler().indicatorColor($contentOnBrand()))
          .onPressed(
            RemixIconButtonStyler()
                .backgroundColor(_iconButtonPressedBackground($surfaceInverted)),
          ),
    DsIconButtonVariant.secondary =>
      RemixIconButtonStyler()
          .backgroundColor($surfaceAlternative())
          .foregroundColor($brandText())
          .spinner(RemixSpinnerStyler().indicatorColor($brandText()))
          .onPressed(
            RemixIconButtonStyler().backgroundColor(
              _iconButtonPressedBackground($surfaceAlternative),
            ),
          ),
    DsIconButtonVariant.outline =>
      RemixIconButtonStyler()
          .borderAll(color: $brandUi(), width: 1)
          .backgroundColor(_opacity($canvasAlternative, 0))
          .foregroundColor($brandText())
          .spinner(RemixSpinnerStyler().indicatorColor($brandText()))
          .onPressed(
            RemixIconButtonStyler().backgroundColor(_opacity($canvasAlternative, 1)),
          ),
    DsIconButtonVariant.ghost =>
      RemixIconButtonStyler()
          .backgroundColor(_opacity($canvasAlternative, 0))
          .foregroundColor($brandText())
          .spinner(RemixSpinnerStyler().indicatorColor($brandText()))
          .onPressed(
            RemixIconButtonStyler().backgroundColor(_opacity($canvasAlternative, 1)),
          ),
    DsIconButtonVariant.destructive =>
      RemixIconButtonStyler()
          .backgroundColor($negativeSurface())
          .foregroundColor($contentPrimary())
          .spinner(RemixSpinnerStyler().indicatorColor($contentPrimary()))
          .onPressed(
            RemixIconButtonStyler().backgroundColor(
              _iconButtonPressedBackground($negativeSurface),
            ),
          ),
  };

  // Disabled wins over every other interactive state, same as `button_2`.
  final stateStyle = disabled
      ? RemixIconButtonStyler().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixIconButtonStyler();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
