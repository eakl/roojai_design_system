part of 'slider_2.dart';

RemixSliderStyle resolveDsSliderStyle({
  required DsSliderSize size,
  required bool disabled,
}) {
  final baseStyle = RemixSliderStyle()
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
    DsSliderSize.sm => RemixSliderStyle(
        thumb: BoxStyler().size(14, 14),
        trackWidth: 3,
        rangeWidth: 3,
      ),
    DsSliderSize.md => RemixSliderStyle(
        thumb: BoxStyler().size(18, 18),
        trackWidth: 4,
        rangeWidth: 4,
      ),
    DsSliderSize.lg => RemixSliderStyle(
        thumb: BoxStyler().size(22, 22),
        trackWidth: 5,
        rangeWidth: 5,
      ),
  };

  final stateStyle = disabled
      ? RemixSliderStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSliderStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
