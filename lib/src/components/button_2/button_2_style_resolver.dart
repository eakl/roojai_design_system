part of 'button_2.dart';

Color _pressedBackground(ColorToken token, {int amount = 15}) {
  return ColorRef(token().directives([DarkenColorDirective(amount)]));
}

RemixButtonStyler resolveDsButtonStyle({
  required DsButtonVariant variant,
  required DsButtonSize size,
  required bool disabled,
  required bool loading,
}) {
  // Neither `Curve` nor arithmetic on a `Duration` token reference is
  // supported by Mix's inline token-ref mechanism: `$motionCurveStandard()`
  // throws ("No token reference is registered for MixToken<Curve>"), and
  // `AnimationConfig` internally adds `duration + delay`, which a
  // `$motionDurationFast()` reference also can't do ("Cannot access '+' on
  // a Duration token reference"). Both fall back to literals matching the
  // legacy `Button`'s 100ms interactive transition until Mix supports
  // resolving these token types outside of Style properties.
  final baseStyle = RemixButtonStyler()
      .borderRadiusAll($radius008())
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // Icon size is fixed per `size` regardless of what `leadingIcon`/
  // `trailingIcon` glyph the caller passes in — `IconStyler.size` (set via
  // `.iconSize()`) controls rendering size independently of the `IconData`
  // supplied, so callers can't accidentally break the button's vertical
  // rhythm with an oversized/undersized icon. `spinnerSize` mirrors the
  // same value so the loading spinner matches the icon it temporarily
  // stands in for.
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

  const transparent = Color(0x00000000);

  // Pressed feedback is a *style property* (background color), not a
  // `.wrap(WidgetModifierConfig.opacity(...))` modifier — see the design
  // spec's "Pressed feedback" section. Opacity is already spoken for by
  // the `disabled` state below (a whole-widget dim via a wrapper
  // `Opacity` widget, the correct use for a modifier per Mix's own
  // guidance: https://www.fluttermix.com/documentation/mix/guides/widget-modifiers#modifiers-vs-style-properties).
  // Reusing it for `pressed` would fight over the same channel and washes
  // out the border/label along with the fill, so solid-background variants
  // darken their own fill color (`_pressedBackground`) and the
  // transparent-background variants (outline/ghost) instead wash in a
  // light brand-tinted fill, since darkening `transparent` is a no-op.
  final variantStyle = switch (variant) {
    DsButtonVariant.primary =>
      RemixButtonStyler()
          .color($surfaceInverted())
          .labelColor($contentOnBrand())
          .iconColor($contentOnBrand())
          .spinnerIndicatorColor($contentOnBrand())
          .onPressed(
            RemixButtonStyler().color(_pressedBackground($surfaceInverted)),
          ),
    DsButtonVariant.secondary =>
      RemixButtonStyler()
          .color($surfaceAlternative())
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(
            RemixButtonStyler().color(_pressedBackground($surfaceAlternative)),
          ),
    DsButtonVariant.outline =>
      RemixButtonStyler()
          .borderAll(color: $brandUi(), width: 1)
          .backgroundColor(transparent)
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(RemixButtonStyler().color($brandSurface())),
    DsButtonVariant.ghost =>
      RemixButtonStyler()
          .color(transparent)
          .labelColor($brandText())
          .iconColor($brandText())
          .spinnerIndicatorColor($brandText())
          .onPressed(RemixButtonStyler().color($brandSurface())),
    DsButtonVariant.destructive =>
      RemixButtonStyler()
          .color($negativeSurface())
          .labelColor($contentPrimary())
          .iconColor($contentPrimary())
          .spinnerIndicatorColor($contentPrimary())
          .onPressed(
            RemixButtonStyler().color(_pressedBackground($negativeSurface)),
          ),
  };

  // Disabled wins over every other interactive state — a disabled button
  // never shows hover/pressed/focus feedback regardless of `loading`.
  final stateStyle = disabled
      ? RemixButtonStyler().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixButtonStyler();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
