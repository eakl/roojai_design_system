// Probably needs to be removed and backed in button_2

part of 'button_2.dart';

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
    var style = IconStyler().size(widget.spec.size ?? 20);
    if (widget.spec.indicatorColor != null) {
      style = style.color(widget.spec.indicatorColor!);
    }

    return RotationTransition(
      turns: _controller,
      child: Icon(PhosphorIcons.circleNotch(), style: style),
    );
  }
}
