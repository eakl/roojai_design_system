import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/radius.dart';
import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'button_interaction_state.dart';
import 'button_size.dart';
import 'button_variant.dart';

// The `_resolve*` functions consumed by `build()` below live in
// button_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to Button while living in their
// own file.
part 'button_style_resolvers.dart';

/// A pressable action button built from low-level primitives
/// (`GestureDetector` + `Focus`, no Material `InkWell`/`ElevatedButton`).
///
/// Public states are explicit constructor params — [loading] and
/// [disabled] are never inferred from other props. The one state the
/// widget derives itself is "pressed", from a live `GestureDetector`
/// signal (see [_ButtonState._isPressed]).
class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.leading,
    this.trailing,
  });

  /// The button's text content. Always shown, including while [loading].
  final String label;

  /// Called on tap. Ignored (and the button rendered non-interactive)
  /// while [disabled] or [loading] is true, or when null.
  final VoidCallback? onPressed;

  /// Visual treatment — see [ButtonVariant].
  final ButtonVariant variant;

  /// Physical size — see [ButtonSize].
  final ButtonSize size;

  /// Public state: shows a spinner in place of [leading] and suppresses
  /// [trailing] and taps, while keeping [label] visible.
  final bool loading;

  /// Public state: renders muted colors and suppresses taps/focus.
  /// Takes precedence over [loading] when both are true.
  final bool disabled;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_ButtonState._focusNode].
  final FocusNode? focusNode;

  /// Whether this button should request focus when first built.
  final bool autofocus;

  /// Widget shown before [label] (typically an `Icon`). Replaced by a
  /// spinner while [loading] is true.
  final Widget? leading;

  /// Widget shown after [label] (typically an `Icon`). Hidden while
  /// [loading] is true.
  final Widget? trailing;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param. Driven purely by real
  // GestureDetector callbacks, not simulated.
  bool _isPressed = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Button(${widget.label})');
    }
  }

  @override
  void didUpdateWidget(Button oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Button(${widget.label})');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the button accepts taps at all. [disabled] wins over
  /// [loading] when both are set, matching the doc on [Button.disabled].
  bool get _interactive =>
      !widget.disabled && !widget.loading && widget.onPressed != null;

  /// Resolves the single [ButtonInteractionState] this frame is styled
  /// for. Order matters: disabled beats loading beats the live pressed
  /// signal beats the enabled default.
  ButtonInteractionState get _interactionState {
    if (widget.disabled) return ButtonInteractionState.disabled;
    if (widget.loading) return ButtonInteractionState.loading;
    if (_isPressed) return ButtonInteractionState.pressed;
    return ButtonInteractionState.enabled;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties -------------------------------------------
    final state = _interactionState;
    final backgroundColor =
        _resolveBackgroundColor(colors, widget.variant, state);
    final foregroundColor =
        _resolveForegroundColor(colors, widget.variant, state);
    final borderColor = _resolveBorderColor(colors, widget.variant, state);
    final textStyle = _resolveTextStyle(typography, widget.size);
    final padding = _resolvePadding(widget.size);
    final iconGap = _resolveIconGap(widget.size);
    final iconExtent = _resolveIconExtent(widget.size);
    final radius = _resolveRadius(widget.size);

    // --- Layout ---------------------------------------------------------
    // Loading takes over the leading slot with a spinner (so the button's
    // width doesn't jump) and drops the trailing slot entirely, since a
    // trailing affordance implies an action the tap is already busy with.
    final effectiveLeading = state == ButtonInteractionState.loading
        ? SizedBox(
            width: iconExtent,
            height: iconExtent,
            child: _ButtonSpinner(color: foregroundColor),
          )
        : widget.leading;
    final effectiveTrailing =
        state == ButtonInteractionState.loading ? null : widget.trailing;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (effectiveLeading != null) ...[
          SizedBox(width: iconExtent, height: iconExtent, child: effectiveLeading),
          SizedBox(width: iconGap),
        ],
        Text(widget.label, style: textStyle.copyWith(color: foregroundColor)),
        if (effectiveTrailing != null) ...[
          SizedBox(width: iconGap),
          SizedBox(width: iconExtent, height: iconExtent, child: effectiveTrailing),
        ],
      ],
    );

    return MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _interactive,
        child: GestureDetector(
          onTapDown: _interactive ? _handleTapDown : null,
          onTapUp: _interactive ? _handleTapUp : null,
          onTapCancel: _interactive ? _handleTapCancel : null,
          onTap: _interactive ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(radius),
              border:
                  borderColor != null ? Border.all(color: borderColor) : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Minimal indeterminate spinner built from `CustomPaint`, so the loading
/// state doesn't depend on a Material `CircularProgressIndicator`.
class _ButtonSpinner extends StatefulWidget {
  const _ButtonSpinner({required this.color});

  final Color color;

  @override
  State<_ButtonSpinner> createState() => _ButtonSpinnerState();
}

class _ButtonSpinnerState extends State<_ButtonSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
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
      child: CustomPaint(painter: _SpinnerPainter(color: widget.color)),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final rect = Offset.zero & size;
    // Three-quarter arc: reads as a spinner while rotating rather than a
    // static ring.
    canvas.drawArc(rect.deflate(1), 0, 4.71, false, paint);
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) =>
      oldDelegate.color != color;
}
