import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import 'avatar_size.dart';

// The `_resolve*` functions consumed by `build()` below live in
// avatar_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to Avatar while living in their
// own file — matching the Button component's structure.
part 'avatar_style_resolvers.dart';

/// A circular image avatar with a text fallback, built from low-level
/// primitives (`ClipOval` + `Stack`, no Material `CircleAvatar`).
///
/// Avatar is fully stateless — unlike Button it has no interaction states
/// of its own, only a static visual resolved from [image], [fallback],
/// [size] and [badge].
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.image,
    required this.fallback,
    this.size = AvatarSize.md,
    this.badge,
  });

  /// The avatar's photo, from any source Flutter supports —
  /// `NetworkImage`, `AssetImage`, `MemoryImage`, `FileImage`, etc. When
  /// null, or when it fails to load, [fallback] is shown instead.
  final ImageProvider? image;

  /// Fallback text shown when [image] is null or fails to load. Expected
  /// to be two-letter initials (e.g. "JD"), but the widget defensively
  /// uppercases and truncates to two characters — see
  /// `_resolveFallbackText` — so it degrades gracefully on unexpected
  /// input rather than breaking layout.
  final String fallback;

  /// Physical size — see [AvatarSize].
  final AvatarSize size;

  /// Optional indicator rendered bottom-right of the avatar (e.g. an
  /// online-status dot, a platform glyph). Avatar draws the separating
  /// ring around it; the caller supplies only the indicator's own
  /// content, so Avatar stays agnostic of what the badge means.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties -----------------------------------------
    final diameter = avatarDiameterForSize(size);
    final fallbackText = _resolveFallbackText(fallback);
    final fallbackTextStyle = avatarFallbackTextStyleForSize(typography, size);
    final badgeDiameter = _resolveBadgeDiameter(diameter);
    final badgeRingWidth = _resolveBadgeRingWidth(size);

    // --- Layout -------------------------------------------------------
    final circle = ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: image != null
            ? Image(
                image: image!,
                fit: BoxFit.cover,
                // Any decode/network failure falls back to the initials
                // circle instead of Flutter's default broken-image icon.
                errorBuilder: (context, error, stackTrace) => _FallbackCircle(
                  text: fallbackText,
                  textStyle: fallbackTextStyle,
                  backgroundColor: colors.surface.alternative,
                  textColor: colors.content.secondary,
                ),
              )
            : _FallbackCircle(
                text: fallbackText,
                textStyle: fallbackTextStyle,
                backgroundColor: colors.surface.alternative,
                textColor: colors.content.secondary,
              ),
      ),
    );

    if (badge == null) {
      return SizedBox(width: diameter, height: diameter, child: circle);
    }

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        children: [
          circle,
          // Anchored to the avatar's bottom-right corner. That corner
          // sits outside the clipped circle, so the badge reads as
          // "attached" to the avatar without needing to overflow the
          // SizedBox bounds.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeDiameter,
              height: badgeDiameter,
              padding: EdgeInsets.all(badgeRingWidth),
              decoration: BoxDecoration(
                // Ring color matches canvas so the badge reads as a
                // separate layer over whatever page background sits
                // behind the avatar — same rationale as AvatarGroup's
                // ring between overlapping avatars.
                color: colors.canvas.base,
                shape: BoxShape.circle,
              ),
              child: ClipOval(child: badge),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials-on-tint circle shown when [Avatar.image] is absent or fails
/// to load.
class _FallbackCircle extends StatelessWidget {
  const _FallbackCircle({
    required this.text,
    required this.textStyle,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(text, style: textStyle.copyWith(color: textColor)),
      ),
    );
  }
}
