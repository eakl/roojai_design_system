part of 'spinner_2.dart';

RemixSpinnerStyle resolveDsSpinnerStyle({
  required DsSpinnerSize size,
  required bool inverted,
}) {
  final baseStyle = RemixSpinnerStyle(
    duration: const Duration(milliseconds: 800),
  );

  final sizeStyle = switch (size) {
    DsSpinnerSize.sm => RemixSpinnerStyle(size: 16, strokeWidth: 1),
    DsSpinnerSize.md => RemixSpinnerStyle(size: 24, strokeWidth: 1.25),
    DsSpinnerSize.lg => RemixSpinnerStyle(size: 32, strokeWidth: 1.5),
  };

  final stateStyle = RemixSpinnerStyle(
    indicatorColor: inverted ? $contentOnBrand() : $contentSecondary(),
  );

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
