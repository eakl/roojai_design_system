part of 'avatar.dart';

// Style resolvers for Avatar.
//
// One pure function per resolved property, matching the convention
// established by Button's style resolvers. Diameter and fallback text
// style are *not* here — they're shared with AvatarGroup and live as
// public top-level functions in avatar_size.dart instead.

/// Defensively normalizes [fallback] to at most two uppercase characters,
/// so a caller passing a full name or lowercase text still lays out as a
/// compact two-glyph initials circle instead of overflowing or looking
/// inconsistent with the rest of the design system.
String _resolveFallbackText(String fallback) {
  final normalized = fallback.trim().toUpperCase();
  return normalized.length <= 2 ? normalized : normalized.substring(0, 2);
}

/// Badge diameter as a fraction of the avatar's own diameter, so it scales
/// proportionally across [AvatarSize] instead of needing its own switch.
double _resolveBadgeDiameter(double avatarDiameter) => avatarDiameter * 0.32;

/// Thickness of the canvas-colored ring drawn around [Avatar.badge].
double _resolveBadgeRingWidth(AvatarSize size) {
  switch (size) {
    case AvatarSize.sm:
      return 1.5;
    case AvatarSize.md:
    case AvatarSize.lg:
      return 2;
  }
}
