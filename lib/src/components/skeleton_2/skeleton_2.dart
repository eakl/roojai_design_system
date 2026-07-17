import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import 'skeleton_2_shape.dart';

// The `resolveDsSkeletonStyle`/`_resolveRadius` functions consumed by
// `build()` below live in skeleton_2_style_resolver.dart, split out as
// `part of` this library (not a separate import) so they stay private to
// DsSkeleton while living in their own file — same split as
// `IconContainer`'s `icon_container_style_resolver.dart`.
part 'skeleton_2_style_resolver.dart';

/// A pulsing placeholder block shown in place of content that hasn't
/// loaded yet, built on Mix's [Box]/[BoxStyler] — the same primitive
/// `IconContainer` uses — rather than a raw `Container`/`BoxDecoration`.
///
/// Remix ships no `Skeleton` widget, so unlike most `_2` components (thin
/// wrappers around a `Remix*` widget), [DsSkeleton] has no Remix widget
/// underneath — same situation `IconContainer` is in.
///
/// Mirrors the legacy `Skeleton`: a single opacity-pulsing block whose
/// size the caller controls directly, generalized with a [shape] axis so
/// one widget covers rectangular content blocks, circular avatar
/// placeholders, and thin text-line placeholders.
class DsSkeleton extends StatefulWidget {
  const DsSkeleton({
    super.key,
    this.shape = DsSkeletonShape.rectangle,
    this.width = 120,
    this.height = 16,
    this.style,
  });

  /// Visual shape — see [DsSkeletonShape].
  final DsSkeletonShape shape;

  /// Width of the placeholder block. Ignored when [shape] is
  /// [DsSkeletonShape.circle] — [height] drives both dimensions there,
  /// see [DsSkeletonShape.circle]'s doc.
  final double width;

  /// Height of the placeholder block. For [DsSkeletonShape.circle], also
  /// used as the diameter (see [width]).
  final double height;

  /// Escape hatch for callers that need to further customize the
  /// resolved style (merged on top of [resolveDsSkeletonStyle]'s output)
  /// — same convention as [IconContainer.style].
  final BoxStyler? style;

  @override
  State<DsSkeleton> createState() => _DsSkeletonState();
}

class _DsSkeletonState extends State<DsSkeleton>
    with SingleTickerProviderStateMixin {
  // Ping-pongs opacity between the low/high bounds resolved by
  // `_resolveOpacity` below. A skeleton has no "finished" state, so this
  // repeats forever from initState to dispose — same lifecycle shape as
  // Spinner's controller. Ported unchanged from the legacy `Skeleton`.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  // Eases the raw linear controller value so the pulse settles at each
  // end instead of reversing direction abruptly — matches the smooth
  // "breathing" look of shadcn's `animate-pulse`.
  late final Animation<double> _pulse = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsSkeletonStyle(
      shape: widget.shape,
      width: widget.width,
      height: widget.height,
    ).merge(widget.style);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Opacity(
          opacity: _resolveOpacity(_pulse.value),
          child: child,
        );
      },
      child: Box(style: resolvedStyle),
    );
  }
}

/// Maps the eased 0.0-1.0 ping-pong value to an opacity range of 0.5-1.0
/// — the same swing Tailwind's `animate-pulse` (and shadcn's `Skeleton`,
/// which is built on it) uses, so the block never fully disappears (0.5
/// floor) while still producing a clearly visible pulse (1.0 ceiling).
/// Ported unchanged from the legacy `Skeleton`.
double _resolveOpacity(double animationValue) {
  return 0.5 + (animationValue * 0.5);
}
