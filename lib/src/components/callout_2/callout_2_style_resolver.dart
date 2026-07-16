part of 'callout_2.dart';

/// Resolves a [RemixCalloutStyler] from the design system's [variant]/[size]
/// axes, mirroring `resolveDsButtonStyle`'s base → size → variant
/// composition (there is no interaction/disabled state axis here — callouts
/// are static content, not interactive controls).
RemixCalloutStyler resolveDsCalloutStyle({
  required DsCalloutVariant variant,
  required DsCalloutSize size,
}) {
  final baseStyle = RemixCalloutStyler().borderRadiusAll($radius008());

  final sizeStyle = switch (size) {
    DsCalloutSize.sm =>
      RemixCalloutStyler(text: TextStyler(style: $bodySm.mix()))
          .paddingX($spacing012())
          .paddingY($spacing008())
          .spacing($spacing008())
          .iconSize(16),
    DsCalloutSize.md =>
      RemixCalloutStyler(text: TextStyler(style: $bodyMd.mix()))
          .paddingX($spacing016())
          .paddingY($spacing012())
          .spacing($spacing008())
          .iconSize(20),
    DsCalloutSize.lg =>
      RemixCalloutStyler(text: TextStyler(style: $bodyLg.mix()))
          .paddingX($spacing020())
          .paddingY($spacing016())
          .spacing($spacing012())
          .iconSize(24),
  };

  // Each variant pairs a semantic `*Surface` background with the matching
  // `*Text` foreground (shared across the icon and text via
  // `.foregroundColor()`), the same surface/text token pairing
  // `DsIconVariant` uses for its own neutral/brand/positive/negative/warning
  // set — kept in lockstep so an icon dropped into a callout with a matching
  // `DsIconVariant` looks consistent.
  final variantStyle = switch (variant) {
    DsCalloutVariant.neutral =>
      RemixCalloutStyler()
          .backgroundColor($neutralSurface())
          .foregroundColor($neutralText()),
    DsCalloutVariant.brand =>
      RemixCalloutStyler()
          .backgroundColor($brandSurface())
          .foregroundColor($brandText()),
    DsCalloutVariant.positive =>
      RemixCalloutStyler()
          .backgroundColor($positiveSurface())
          .foregroundColor($positiveText()),
    DsCalloutVariant.negative =>
      RemixCalloutStyler()
          .backgroundColor($negativeSurface())
          .foregroundColor($negativeText()),
    DsCalloutVariant.warning =>
      RemixCalloutStyler()
          .backgroundColor($warningSurface())
          .foregroundColor($warningText()),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
