part of 'avatar_group.dart';

// Style resolvers for AvatarGroup. One pure function per resolved
// property, matching the convention established by Button/Avatar.

/// Thickness of the canvas-colored ring drawn around each cell in the
/// group. Kept in step with Avatar's own badge ring width per size, so
/// the two visually match wherever they appear together (an [Avatar]
/// with a [Avatar.badge] inside an [AvatarGroup]).
double _resolveRingWidth(AvatarSize size) {
  switch (size) {
    case AvatarSize.sm:
      return 1.5;
    case AvatarSize.md:
    case AvatarSize.lg:
      return 2;
  }
}

/// How many logical pixels each cell overlaps the previous one, as a
/// fraction of [cellDiameter] so the overlap looks proportionally similar
/// across [AvatarSize]s rather than eating a fixed amount out of a small
/// avatar.
double _resolveOverlap(double cellDiameter) => cellDiameter * 0.35;
