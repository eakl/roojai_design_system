import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import 'avatar.dart';
import 'avatar_size.dart';

// The `_resolve*` functions consumed by `build()` below live in
// avatar_group_style_resolvers.dart, split out as `part of` this library
// so they stay private to AvatarGroup while living in their own file —
// matching Avatar's and Button's structure.
part 'avatar_group_style_resolvers.dart';

/// A row of overlapping [Avatar]s with a "+N" overflow indicator, built
/// from `Stack`/`Positioned` (no Material widgets).
///
/// Every visible entry is re-rendered as a fresh [Avatar] at the group's
/// own [size] — an individual [Avatar.size] set on an entry in [avatars]
/// is ignored — so the whole group stays visually uniform regardless of
/// how each avatar was constructed by the caller.
class AvatarGroup extends StatelessWidget {
  const AvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.size = AvatarSize.md,
    this.trailing,
  });

  /// The full set of avatars to represent. Only the first [maxVisible]
  /// are drawn; the rest are folded into a single "+N" circle.
  final List<Avatar> avatars;

  /// How many avatars to draw before switching remaining entries to a
  /// "+N" overflow circle. Defaults to 3.
  final int maxVisible;

  /// Physical size applied uniformly to every visible avatar and to the
  /// overflow circle — see [AvatarSize].
  final AvatarSize size;

  /// Optional widget rendered after the avatar stack (e.g. an "add
  /// member" button). Independent of overflow — shown whenever provided,
  /// regardless of whether [avatars] exceeds [maxVisible].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties -----------------------------------------
    final avatarDiameter = avatarDiameterForSize(size);
    final ringWidth = _resolveRingWidth(size);
    // The ring container is larger than the raw avatar diameter so the
    // ring is drawn *around* the avatar rather than eating into its
    // rendered size.
    final cellDiameter = avatarDiameter + ringWidth * 2;
    final overlap = _resolveOverlap(cellDiameter);
    final step = cellDiameter - overlap;

    final visibleAvatars = avatars.take(maxVisible).toList();
    final overflowCount = avatars.length - visibleAvatars.length;

    // --- Layout -------------------------------------------------------
    final cells = <Widget>[
      for (final avatar in visibleAvatars)
        _RingedCircle(
          diameter: cellDiameter,
          ringWidth: ringWidth,
          ringColor: colors.canvas.base,
          // Rebuilt at the group's uniform `size`/image/fallback/badge —
          // see the class doc on why an entry's own `size` is ignored.
          child: Avatar(
            image: avatar.image,
            fallback: avatar.fallback,
            size: size,
            badge: avatar.badge,
          ),
        ),
      if (overflowCount > 0)
        _RingedCircle(
          diameter: cellDiameter,
          ringWidth: ringWidth,
          ringColor: colors.canvas.base,
          child: _OverflowCircle(
            label: '+$overflowCount',
            textStyle: avatarFallbackTextStyleForSize(typography, size),
            backgroundColor: colors.surface.alternative,
            textColor: colors.content.secondary,
          ),
        ),
    ];

    final stackWidth =
        cells.isEmpty ? 0.0 : cellDiameter + step * (cells.length - 1);

    final stack = SizedBox(
      width: stackWidth,
      height: cellDiameter,
      child: Stack(
        children: [
          for (var i = 0; i < cells.length; i++)
            // Painted in list order, so later (rightward) cells are
            // painted on top of earlier ones where they overlap.
            Positioned(left: i * step, child: cells[i]),
        ],
      ),
    );

    if (trailing == null) return stack;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stack,
        const SizedBox(width: AppSpacing.spacing8),
        trailing!,
      ],
    );
  }
}

/// Wraps [child] in a canvas-colored ring so overlapping cells in
/// [AvatarGroup] read as distinct layers instead of blending together.
class _RingedCircle extends StatelessWidget {
  const _RingedCircle({
    required this.diameter,
    required this.ringWidth,
    required this.ringColor,
    required this.child,
  });

  final double diameter;
  final double ringWidth;
  final Color ringColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(color: ringColor, shape: BoxShape.circle),
      child: ClipOval(child: child),
    );
  }
}

/// The "+N" circle shown in place of avatars beyond [AvatarGroup.maxVisible].
class _OverflowCircle extends StatelessWidget {
  const _OverflowCircle({
    required this.label,
    required this.textStyle,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final TextStyle textStyle;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(
        child: Text(label, style: textStyle.copyWith(color: textColor)),
      ),
    );
  }
}
