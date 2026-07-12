import 'package:flutter/widgets.dart';

import '../../tokens/semantic/semantic_typography.dart';

/// Physical size of an [Avatar]. Drives its diameter and fallback text
/// style — see [avatarDiameterForSize] and [avatarFallbackTextStyleForSize].
///
/// Those two helpers are top-level (not private resolvers local to a
/// single file) because both `Avatar` and `AvatarGroup` need to agree on
/// exactly what each size means in pixels/typography: `AvatarGroup`
/// re-renders every visible entry as a fresh `Avatar` at its own uniform
/// `size`, so the two components must stay in sync.
enum AvatarSize { sm, md, lg }

/// Diameter, in logical pixels, of an [Avatar] rendered at [size].
double avatarDiameterForSize(AvatarSize size) {
  switch (size) {
    case AvatarSize.sm:
      return 32;
    case AvatarSize.md:
      return 40;
    case AvatarSize.lg:
      return 56;
  }
}

/// Text style for an [Avatar]'s fallback initials at [size].
TextStyle avatarFallbackTextStyleForSize(
  SemanticTypography typography,
  AvatarSize size,
) {
  switch (size) {
    case AvatarSize.sm:
      return typography.captionSm;
    case AvatarSize.md:
      return typography.labelSm;
    case AvatarSize.lg:
      return typography.labelLg;
  }
}
