/// Visual shape of a [Skeleton] placeholder. Drives corner radius and
/// which of [Skeleton.width]/[Skeleton.height] the resolved dimensions use
/// — see the `_resolve*(shape, ...)` functions in `skeleton.dart`.
enum SkeletonShape {
  /// Rounded-rectangle block — the default. For placeholder cards, images,
  /// and generic content blocks.
  rectangle,

  /// Fully rounded circle — for placeholder avatars. [Skeleton.height]
  /// drives the circle's diameter; [Skeleton.width] is ignored so a
  /// caller-supplied width can't squash it into an ellipse.
  circle,

  /// A thin, slightly-rounded bar — for placeholder text lines.
  text,
}
