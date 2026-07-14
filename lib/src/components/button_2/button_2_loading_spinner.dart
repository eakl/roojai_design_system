part of 'button_2.dart';

// Default `loading` spinner for DsButton.
//
// Remix's own `RemixButton` defaults to a `RemixSpinner` (an arc drawn with
// `CustomPaint`). The design system instead standardizes on Phosphor's
// `circleNotch` glyph, continuously rotated, so the loading indicator reuses
// the same icon set as every other icon in the design system rather than a
// bespoke painted spinner.

/// Default [RemixButtonLoadingBuilder] for [DsButton]. Renders a rotating
/// [PhosphorIcons.circleNotch], sized/colored/timed from the resolved
/// [RemixSpinnerSpec] (see `spinnerSize`/`spinnerIndicatorColor`/
/// `spinnerDuration` in `resolveDsButtonStyle`), so it always matches the
/// button's `size`/`variant` without callers wiring anything up themselves.
Widget _dsButtonLoadingSpinnerBuilder(
  BuildContext context,
  RemixSpinnerSpec spec,
) {
  return _DsButtonLoadingSpinner(spec: spec);
}

class _DsButtonLoadingSpinner extends StatefulWidget {
  const _DsButtonLoadingSpinner({required this.spec});

  final RemixSpinnerSpec spec;

  @override
  State<_DsButtonLoadingSpinner> createState() =>
      _DsButtonLoadingSpinnerState();
}

class _DsButtonLoadingSpinnerState extends State<_DsButtonLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.spec.duration ?? const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: PhosphorIcon(
        PhosphorIcons.circleNotch(),
        size: widget.spec.size ?? 20,
        color: widget.spec.indicatorColor,
      ),
    );
  }
}
