part of 'label_2.dart';

({TextStyler text, TextStyler marker}) resolveDsLabelStyle({
  required DsLabelSize size,
  required bool disabled,
}) {
  final sizeToken = switch (size) {
    DsLabelSize.sm => $labelSm.mix(),
    DsLabelSize.md => $labelMd.mix(),
    DsLabelSize.lg => $labelLg.mix(),
  };

  final textColor = disabled ? $contentPlaceholder() : $contentPrimary();
  final markerColor = disabled ? $contentPlaceholder() : $negativeText();

  return (
    text: TextStyler().style(sizeToken).color(textColor),
    marker: TextStyler().style(sizeToken).color(markerColor),
  );
}
