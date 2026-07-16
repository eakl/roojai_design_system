part of 'spinner_2.dart';

RemixSpinnerStyler resolveDsSpinnerStyle({
  required DsSpinnerSize size,
  required bool inverted,
}) {
  final baseStyle = RemixSpinnerStyler(
    duration: const Duration(milliseconds: 800),
  );

  final sizeStyle = switch (size) {
    DsSpinnerSize.sm => RemixSpinnerStyler(size: 16, strokeWidth: 1),
    DsSpinnerSize.md => RemixSpinnerStyler(size: 24, strokeWidth: 1.25),
    DsSpinnerSize.lg => RemixSpinnerStyler(size: 32, strokeWidth: 1.5),
  };

  final stateStyle = RemixSpinnerStyler(
    indicatorColor: inverted ? $contentOnBrand() : $contentSecondary(),
  );

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
