part of 'progress_2.dart';

RemixProgressStyle resolveDsProgressStyle({required DsProgressSize size}) {
  final baseStyle = RemixProgressStyle()
      .width(double.infinity)
      .trackColor($surfaceAlternative())
      .indicatorColor($surfaceInverted())
      .track(BoxStyler().width(double.infinity).borderRadiusAll($radiusFull()))
      .indicator(BoxStyler().borderRadiusAll($radiusFull()))
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  final sizeStyle = switch (size) {
    DsProgressSize.sm =>
      RemixProgressStyle()
          .height(6)
          .track(BoxStyler().height(6))
          .indicator(BoxStyler().height(6)),
    DsProgressSize.md =>
      RemixProgressStyle()
          .height(8)
          .track(BoxStyler().height(8))
          .indicator(BoxStyler().height(8)),
    DsProgressSize.lg =>
      RemixProgressStyle()
          .height(10)
          .track(BoxStyler().height(10))
          .indicator(BoxStyler().height(10)),
  };

  return baseStyle.merge(sizeStyle);
}
