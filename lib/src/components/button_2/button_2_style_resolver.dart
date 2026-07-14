part of 'button_2.dart';

// Style resolver for DsButton.
//
// Single entry point `resolveDsButtonStyle` builds one `RemixButtonStyle` by
// merging four independent style fragments — base, size, variant, state —
// mirroring the per-property-axis split used by the legacy `Button`'s
// `_resolve*` functions (see `button/button_style_resolvers.dart`), but
// composed as `RemixButtonStyle` fragments merged with `.merge()` instead of
// resolved values, since Remix styles compose that way natively.

/// Darkens a background color token by [amount]% (HSL lightness) for the
/// pressed interactive state.
///
/// Built with a `DarkenColorDirective` attached to the token's own
/// `ColorRef` — rather than resolving the token to a concrete `Color` and
/// blending it with `Color.alphaBlend` — because style resolution here
/// happens before `BuildContext` is available. Directives are the
/// mechanism Mix provides for transforming a token-backed color lazily, at
/// the point the token itself resolves.
Color _pressedBackground(ColorToken token, {int amount = 15}) {
  return ColorRef(token().directives([DarkenColorDirective(amount)]));
}

/// Resolves the full `RemixButtonStyle` for a [DsButton], given its
/// [variant], [size] and current [disabled]/[loading] state.
///
/// Order of composition: base metrics/motion, then size (height/padding),
/// then variant (colors), then interactive state (opacity/focus ring).
/// Later merges win on overlapping properties, so `stateStyle` — applied
/// last — always has final say (e.g. disabled dims whatever the variant set).
RemixButtonStyle resolveDsButtonStyle({
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
  final baseStyle = RemixButtonStyle().borderRadiusAll($radius008()).animate(
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
    DsButtonSize.sm => RemixButtonStyle()
        .height(36)
        .paddingY($spacing008())
        .paddingX($spacing012())
        .spacing(6)
        .labelStyle($labelMd.mix())
        .iconSize(20)
        .spinnerSize(20),
    DsButtonSize.md => RemixButtonStyle()
        .height(44)
        .paddingY($spacing010())
        .paddingX($spacing016())
        .spacing(8)
        .labelStyle($labelLg.mix())
        .iconSize(20)
        .spinnerSize(20),
    DsButtonSize.lg => RemixButtonStyle()
        .height(56)
        .paddingY($spacing016())
        .paddingX($spacing020())
        .spacing(8)
        .labelStyle($labelLg.mix())
        .iconSize(24)
        .spinnerSize(24),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsButtonVariant.primary => RemixButtonStyle()
        .color($surfaceInverted())
        .labelColor($contentOnBrand())
        .iconColor($contentOnBrand())
        .spinnerIndicatorColor($contentOnBrand())
        .onPressed(
          RemixButtonStyle().color(_pressedBackground($surfaceInverted)),
        ),
    DsButtonVariant.secondary => RemixButtonStyle()
        .color($surfaceAlternative())
        .labelColor($brandText())
        .iconColor($brandText())
        .spinnerIndicatorColor($brandText())
        .onPressed(
            RemixButtonStyle().color(_pressedBackground($surfaceAlternative))),
    DsButtonVariant.outline => RemixButtonStyle()
        .borderAll(color: $brandUi(), width: 1)
        .backgroundColor(transparent)
        .labelColor($brandText())
        .iconColor($brandText())
        .spinnerIndicatorColor($brandText())
        .onPressed(RemixButtonStyle()),
    DsButtonVariant.ghost => RemixButtonStyle()
        .color(transparent)
        .labelColor($brandText())
        .iconColor($brandText())
        .spinnerIndicatorColor($brandText())
        .onPressed(RemixButtonStyle()),
    DsButtonVariant.destructive => RemixButtonStyle()
        .color($negativeSurface())
        .labelColor($contentPrimary())
        .iconColor($contentPrimary())
        .spinnerIndicatorColor($contentPrimary())
        .onPressed(
            RemixButtonStyle().color(_pressedBackground($negativeSurface))),
  };

  // Disabled wins over every other interactive state — a disabled button
  // never shows hover/pressed/focus feedback regardless of `loading`.
  final stateStyle = disabled
      ? RemixButtonStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixButtonStyle();

  return baseStyle.merge(sizeStyle).merge(variantStyle).merge(stateStyle);
}
