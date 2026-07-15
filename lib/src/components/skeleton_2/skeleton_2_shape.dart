/// Visual shape of a [DsSkeleton] placeholder. Drives corner radius and
/// which of [DsSkeleton.width]/[DsSkeleton.height] the resolved
/// dimensions use — see `resolveDsSkeletonStyle` in
/// `skeleton_2_style_resolver.dart`.
enum DsSkeletonShape {
  /// Rounded-rectangle block — the default. For placeholder cards, images,
  /// and generic content blocks.
  rectangle,

  /// Fully rounded circle — for placeholder avatars. [DsSkeleton.height]
  /// drives the circle's diameter; [DsSkeleton.width] is ignored so a
  /// caller-supplied width can't squash it into an ellipse.
  circle,

  /// A thin, slightly-rounded bar — for placeholder text lines.
  text,
}
