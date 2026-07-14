import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/motion.dart';
import '../../tokens/primitives/radius.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'checkbox_value.dart';

part 'checkbox_style_resolvers.dart';

/// A tri-state selection control built from low-level primitives
/// (`GestureDetector` + `CustomPaint`, no Material `Checkbox`).
///
/// Named `AppCheckbox` (not `Checkbox`) to avoid colliding with
/// `package:flutter/widgets.dart`'s `Checkbox`.
///
/// [value] and [disabled] are both explicit constructor params — like
/// [Button], public state is never inferred from other props.
class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// The checkbox's current value — see [CheckboxValue].
  final CheckboxValue value;

  /// Called with the next value on tap. [CheckboxValue.checked] and
  /// [CheckboxValue.indeterminate] both resolve to
  /// [CheckboxValue.unchecked]; [CheckboxValue.unchecked] resolves to
  /// [CheckboxValue.checked] — see [_AppCheckboxState._handleTap]. Ignored
  /// (and the checkbox rendered non-interactive) while [disabled] is
  /// true, or when null.
  final ValueChanged<CheckboxValue>? onChanged;

  /// Public state: renders muted colors and suppresses taps and focus
  /// entirely. [value] still governs which glyph (if any) is drawn while
  /// disabled, so the checkbox keeps communicating its value.
  final bool disabled;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_AppCheckboxState._focusNode].
  final FocusNode? focusNode;

  /// Whether this checkbox should request focus when first built.
  final bool autofocus;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button's `_internalFocusNode`.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppCheckbox');
    }
  }

  @override
  void didUpdateWidget(AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppCheckbox');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the checkbox accepts taps at all. [disabled] always wins,
  /// and a null [AppCheckbox.onChanged] makes it inert even when not
  /// disabled — mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onChanged != null;

  void _handleTap() {
    final next = widget.value == CheckboxValue.unchecked
        ? CheckboxValue.checked
        : CheckboxValue.unchecked;
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties --------------------------------------------
    final backgroundColor =
        _resolveBackgroundColor(colors, widget.value, widget.disabled);
    final borderColor =
        _resolveBorderColor(colors, widget.value, widget.disabled);
    final glyphColor = _resolveGlyphColor(colors, widget.disabled);

    // --- Layout -----------------------------------------------------------
    const size = 20.0;

    return MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _interactive,
        child: GestureDetector(
          onTap: _interactive ? _handleTap : null,
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            curve: AppMotion.curveStandard,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.radius4),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            // Unchecked draws no glyph at all — only checked/indeterminate
            // paint something inside the box.
            child: widget.value == CheckboxValue.unchecked
                ? null
                : CustomPaint(
                    painter: _CheckboxGlyphPainter(
                      value: widget.value,
                      color: glyphColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Draws the checkmark ([CheckboxValue.checked]) or dash
/// ([CheckboxValue.indeterminate]) glyph directly onto the box, so
/// [AppCheckbox] doesn't depend on a Material icon font for two simple
/// strokes.
class _CheckboxGlyphPainter extends CustomPainter {
  const _CheckboxGlyphPainter({required this.value, required this.color});

  final CheckboxValue value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (value == CheckboxValue.indeterminate) {
      canvas.drawLine(
        Offset(size.width * 0.2, size.height * 0.5),
        Offset(size.width * 0.8, size.height * 0.5),
        paint,
      );
      return;
    }

    // A short down-stroke followed by a long up-stroke — the standard
    // checkmark silhouette, sized to sit inside the box with even margins.
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.5)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.8, size.height * 0.28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckboxGlyphPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
