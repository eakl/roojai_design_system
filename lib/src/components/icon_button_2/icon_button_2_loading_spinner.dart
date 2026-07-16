part of 'icon_button_2.dart';

Widget _dsIconButtonLoadingSpinnerBuilder(
  BuildContext context,
  RemixSpinnerSpec spec,
) {
  return _DsIconButtonLoadingSpinner(spec: spec);
}

class _DsIconButtonLoadingSpinner extends StatefulWidget {
  const _DsIconButtonLoadingSpinner({required this.spec});

  final RemixSpinnerSpec spec;

  @override
  State<_DsIconButtonLoadingSpinner> createState() =>
      _DsIconButtonLoadingSpinnerState();
}

class _DsIconButtonLoadingSpinnerState
    extends State<_DsIconButtonLoadingSpinner>
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
