part of 'skeleton_2.dart';

/// Resolves a [DsSkeleton]'s background/size/corner-radius, given its
/// [shape] and requested [width]/[height]. No variant × state matrix here
/// (no `disabled`, no visual variant axis) — unlike `resolveDsTabStyle` or
/// `resolveDsSpinnerStyle`, this is a single resolver function, not a
/// `variantStyle`/`sizeStyle`/`stateStyle` merge.
BoxStyler resolveDsSkeletonStyle({
  required DsSkeletonShape shape,
  required double width,
  required double height,
}) {
  final resolvedWidth = shape == DsSkeletonShape.circle ? height : width;

  return BoxStyler()
      .size(resolvedWidth, height)
      .color($surfaceAlternative())
      .borderRadiusAll(_resolveRadius(shape, height));
}

/// [DsSkeletonShape.circle]'s radius is a computed value (`height / 2`),
/// not a token — it's inherently dynamic since it depends on the caller's
/// [height], same as the legacy `Skeleton` widget's `_resolveRadius`.
Radius _resolveRadius(DsSkeletonShape shape, double height) {
  switch (shape) {
    case DsSkeletonShape.rectangle:
      return $radius008();
    case DsSkeletonShape.circle:
      return Radius.circular(height / 2);
    case DsSkeletonShape.text:
      return $radius004();
  }
}
