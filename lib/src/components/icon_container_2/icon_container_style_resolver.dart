part of 'icon_container.dart';

/// Resolves an [IconContainer]'s square background/size, given its
/// [variant] and [size]. The glyph itself is resolved separately by
/// [Icon]'s own `resolveDsIconStyle` — see [_resolveGlyphVariant] and
/// [_resolveGlyphSize] for the enum mapping into that call.
BoxStyler resolveDsIconContainerStyle({
  required DsIconContainerVariant variant,
  required DsIconContainerSize size,
}) {
  final variantStyle = switch (variant) {
    DsIconContainerVariant.neutral => BoxStyler().color($neutralSurface()),
    DsIconContainerVariant.brand => BoxStyler().color($brandSurface()),
    DsIconContainerVariant.positive => BoxStyler().color($positiveSurface()),
    DsIconContainerVariant.negative => BoxStyler().color($negativeSurface()),
    DsIconContainerVariant.warning => BoxStyler().color($warningSurface()),
  };

  final sizeStyle = switch (size) {
    DsIconContainerSize.sm => BoxStyler().size(24, 24),
    DsIconContainerSize.md => BoxStyler().size(32, 32),
    DsIconContainerSize.lg => BoxStyler().size(40, 40),
    DsIconContainerSize.xl => BoxStyler().size(56, 56),
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(variantStyle)
      .merge(sizeStyle);
}

/// Maps [IconContainer]'s own variant enum onto [Icon]'s, so the glyph
/// color tracks the same semantic variant as the container background.
DsIconVariant _resolveGlyphVariant(DsIconContainerVariant variant) {
  return switch (variant) {
    DsIconContainerVariant.neutral => DsIconVariant.neutral,
    DsIconContainerVariant.brand => DsIconVariant.brand,
    DsIconContainerVariant.positive => DsIconVariant.positive,
    DsIconContainerVariant.negative => DsIconVariant.negative,
    DsIconContainerVariant.warning => DsIconVariant.warning,
  };
}

/// Maps [IconContainer]'s own size enum onto [Icon]'s, so the glyph scales
/// with the container instead of needing a second size prop from callers.
DsIconSize _resolveGlyphSize(DsIconContainerSize size) {
  return switch (size) {
    DsIconContainerSize.sm => DsIconSize.sm,
    DsIconContainerSize.md => DsIconSize.md,
    DsIconContainerSize.lg => DsIconSize.lg,
    DsIconContainerSize.xl => DsIconSize.xl,
  };
}
