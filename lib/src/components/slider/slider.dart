import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/semantic/semantic_colors.dart';

part 'slider_style_resolvers.dart';

/// A continuous-value drag control built from low-level primitives
/// (`GestureDetector` + `Stack`, no Material `Slider`).
///
/// Named `AppSlider` (not `Slider`) to avoid colliding with
/// `package:flutter/widgets.dart`'s `Slider`.
///
/// [value] and [disabled] are both explicit constructor params — like
/// [Button], public state is never inferred from other props. The one
/// state the widget derives itself is "dragging", from a live
/// `GestureDetector` signal — used only to thicken the thumb's ring while
/// the pointer is down, the same way [Button] derives "pressed".
class AppSlider extends StatefulWidget {
  const AppSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    required this.onChanged,
    this.disabled = false,
    this.width = 200,
    this.focusNode,
    this.autofocus = false,
  });

  /// The slider's current value. Always reflects the caller's state — this
  /// widget holds no internal value of its own. Expected to fall within
  /// [min]..[max]; the resolved thumb/fill fraction is clamped to 0..1 for
  /// rendering regardless.
  final double value;

  /// The lower bound of the slider's range.
  final double min;

  /// The upper bound of the slider's range.
  final double max;

  /// Called with the new value as the thumb is dragged or the track is
  /// tapped. Ignored (and the slider rendered non-interactive) while
  /// [disabled] is true, or when null.
  final ValueChanged<double>? onChanged;

  /// Public state: renders a muted fill and suppresses drag/tap/focus
  /// entirely. [value] still governs thumb position while disabled, so
  /// the slider keeps communicating where it's set.
  final bool disabled;

  /// The track's total width in logical pixels.
  final double width;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_AppSliderState._focusNode].
  final FocusNode? focusNode;

  /// Whether this slider should request focus when first built.
  final bool autofocus;

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  // Internal interaction state — the only one the widget derives itself,
  // driven purely by real GestureDetector callbacks. Purely cosmetic (it
  // thickens the thumb ring); it never affects the resolved value.
  bool _isDragging = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button's `_internalFocusNode`.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSlider');
    }
  }

  @override
  void didUpdateWidget(AppSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSlider');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the slider accepts drag/tap input at all. [disabled]
  /// always wins, and a null [AppSlider.onChanged] makes it inert even
  /// when not disabled — mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onChanged != null;

  void _handleDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
    _updateFromLocalX(details.localPosition.dx);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _updateFromLocalX(details.localPosition.dx);
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
  }

  void _handleTapDown(TapDownDetails details) {
    _updateFromLocalX(details.localPosition.dx);
  }

  void _updateFromLocalX(double localX) {
    final fraction = (localX / widget.width).clamp(0.0, 1.0);
    widget.onChanged!(widget.min + fraction * (widget.max - widget.min));
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties --------------------------------------------
    final trackColor = _resolveTrackColor(colors, widget.disabled);
    final fillColor = _resolveFillColor(colors, widget.disabled);
    final thumbRingColor = _resolveThumbRingColor(colors);
    final fraction = widget.max == widget.min
        ? 0.0
        : ((widget.value - widget.min) / (widget.max - widget.min))
            .clamp(0.0, 1.0);

    // --- Layout -----------------------------------------------------------
    const trackHeight = 4.0;
    const thumbDiameter = 18.0;
    final thumbRingWidth = _isDragging ? 3.0 : 2.0;

    return MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _interactive,
        child: GestureDetector(
          onHorizontalDragStart: _interactive ? _handleDragStart : null,
          onHorizontalDragUpdate: _interactive ? _handleDragUpdate : null,
          onHorizontalDragEnd: _interactive ? _handleDragEnd : null,
          onTapDown: _interactive ? _handleTapDown : null,
          child: SizedBox(
            width: widget.width,
            height: thumbDiameter,
            child: Stack(
              alignment: Alignment.centerLeft,
              // The thumb is centered on the fill's leading edge, so at
              // value == min/max it overhangs the track by half its
              // diameter on purpose (standard slider behavior). Stack's
              // default `Clip.hardEdge` would clip that overhang into a
              // half-circle at the extremes — disable clipping so the
              // full thumb always renders.
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: widget.width,
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),
                Container(
                  width: widget.width * fraction,
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                  ),
                ),
                AnimatedPositioned(
                  duration:
                      _isDragging ? Duration.zero : AppMotion.durationFast,
                  curve: AppMotion.curveStandard,
                  left: (widget.width * fraction) - (thumbDiameter / 2),
                  child: AnimatedContainer(
                    duration: AppMotion.durationFast,
                    curve: AppMotion.curveStandard,
                    width: thumbDiameter,
                    height: thumbDiameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: fillColor,
                      border: Border.all(
                        color: thumbRingColor,
                        width: thumbRingWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
