part of 'icon.dart';

IconStyler resolveDsIconStyle({
  required DsIconVariant variant,
  required DsIconSize size,
}) {
  final baseStyle = IconStyler();

  final variantStyle = switch (variant) {
    DsIconVariant.neutral => IconStyler().color($neutralText()),
    DsIconVariant.brand => IconStyler().color($brandText()),
    DsIconVariant.positive => IconStyler().color($positiveText()),
    DsIconVariant.negative => IconStyler().color($negativeText()),
    DsIconVariant.warning => IconStyler().color($warningText()),
  };

  final sizeStyle = switch (size) {
    DsIconSize.sm => IconStyler().size($spacing016()),
    DsIconSize.md => IconStyler().size($spacing020()),
    DsIconSize.lg => IconStyler().size($spacing024()),
    DsIconSize.xl => IconStyler().size($spacing032()),
  };

  return baseStyle.merge(variantStyle).merge(sizeStyle);
}
