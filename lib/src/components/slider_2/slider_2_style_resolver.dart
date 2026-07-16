part of 'slider_2.dart';

RemixSliderStyler resolveDsSliderStyle({
  required DsSliderSize size,
  required bool disabled,
}) {
  final baseStyle = RemixSliderStyler()
      .trackColor($surfaceAlternative())
      .rangeColor($accentUi())
      .thumb(
        BoxStyler()
            .color($surfaceDefault())
            .shapeCircle(
              side: BorderSideMix()
                  .color($borderStrong())
                  .strokeAlign(BorderSide.strokeAlignOutside),
            ),
      );

  final sizeStyle = switch (size) {
    DsSliderSize.sm => RemixSliderStyler(
        thumb: BoxStyler().size(14, 14),
        trackWidth: 3,
        rangeWidth: 3,
      ),
    DsSliderSize.md => RemixSliderStyler(
        thumb: BoxStyler().size(18, 18),
        trackWidth: 4,
        rangeWidth: 4,
      ),
    DsSliderSize.lg => RemixSliderStyler(
        thumb: BoxStyler().size(22, 22),
        trackWidth: 5,
        rangeWidth: 5,
      ),
  };

  final stateStyle = disabled
      ? RemixSliderStyler().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSliderStyler();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
