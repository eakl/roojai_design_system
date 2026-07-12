import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import 'skeleton_shape.dart';

/// A pulsing placeholder block shown in place of content that hasn't
/// loaded yet, built from a plain animated `Container` (no Material
/// shimmer/skeleton widget).
///
/// Mirrors shadcn's `Skeleton`: a single opacity-pulsing block whose size
/// the caller controls directly, generalized here with a [shape] axis so
/// one widget covers rectangular content blocks, circular avatar
/// placeholders, and thin text-line placeholders instead of three
/// separate widgets.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.shape = SkeletonShape.rectangle,
    this.width = 120,
    this.height = 16,
  });

  /// Visual shape — see [SkeletonShape].
  final SkeletonShape shape;

  /// Width of the placeholder block. Ignored when [shape] is
  /// [SkeletonShape.circle] — [height] drives both dimensions there, see
  /// [SkeletonShape.circle]'s doc.
  final double width;

  /// Height of the placeholder block. For [SkeletonShape.circle], also
  /// used as the diameter (see [width]).
  final double height;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  // Ping-pongs opacity between the low/high bounds resolved by
  // `_resolveOpacity` below. A skeleton has no "finished" state, so this
  // repeats forever from initState to dispose — same lifecycle shape as
  // Spinner's controller.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties ------------------------------------------------
    final resolvedWidth =
        _resolveWidth(widget.shape, widget.width, widget.height);
    final radius = _resolveRadius(widget.shape, widget.height);

    // --- Layout ---------------------------------------------------------------
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _resolveOpacity(_controller.value),
          child: child,
        );
      },
      child: Container(
        width: resolvedWidth,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.surface.alternative,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// Style/layout resolvers for Skeleton. One pure function per resolved
// property, same convention as Button/Badge's `_resolve*` split — kept
// inline here (no separate `_style_resolvers.dart` part file) since
// Skeleton has no variant x state matrix, just three small, single-axis
// resolvers.

/// [SkeletonShape.circle] ignores the public [Skeleton.width] entirely and
/// uses [height] for both dimensions, so a caller-supplied width can't
/// squash the circle into an ellipse.
double _resolveWidth(SkeletonShape shape, double width, double height) {
  return shape == SkeletonShape.circle ? height : width;
}

double _resolveRadius(SkeletonShape shape, double height) {
  switch (shape) {
    case SkeletonShape.rectangle:
      return AppRadius.radius8;
    case SkeletonShape.circle:
      return height / 2;
    case SkeletonShape.text:
      return AppRadius.radius4;
  }
}

/// Maps the controller's 0.0-1.0 ping-pong value to an opacity range of
/// 0.5-0.8, so the block never fully disappears (0.5 floor) or reads as
/// fully "loaded" opaque content (0.8 ceiling).
double _resolveOpacity(double controllerValue) {
  return 0.5 + (controllerValue * 0.3);
}
