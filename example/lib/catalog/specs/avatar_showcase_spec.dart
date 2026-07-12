import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

/// Small colored dot used as a badge example in the showcase only — the
/// real `ui` package has no status-dot component of its own; Avatar's
/// `badge` slot accepts any widget.
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// Public placeholder photo service — stable per-index images, good enough
// for a showcase without bundling asset images into the example app.
const _samplePhotoUrl = 'https://i.pravatar.cc/150?img=13';

// Deliberately unreachable, to exercise Avatar's image-load-failure path.
const _brokenPhotoUrl = 'https://example.com/does-not-exist.png';

ComponentShowcaseSpec buildAvatarShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Avatar',
    variantsBuilder: () => [
      const Avatar(fallback: 'JD'),
      const Avatar(fallback: 'JD', image: NetworkImage(_samplePhotoUrl)),
      const Avatar(
        fallback: 'JD',
        image: NetworkImage(_samplePhotoUrl),
        badge: _StatusDot(color: Color(0xFF22C55E)),
      ),
      // errorBuilder falls back to the initials circle here, verifying
      // Avatar degrades instead of breaking layout on a failed load.
      const Avatar(fallback: 'JD', image: NetworkImage(_brokenPhotoUrl)),
    ],
    // Includes a badge on every size so the badge/ring scale relative to
    // AvatarSize (see _resolveBadgeDiameter/_resolveBadgeRingWidth) can be
    // checked at a glance across sm/md/lg, not just at the default size.
    sizesBuilder: () => AvatarSize.values
        .map((size) => Avatar(
              fallback: 'AB',
              size: size,
              badge: const _StatusDot(color: Color(0xFF22C55E)),
            ))
        .toList(),
  );
}
