// `TextField`/`TextEditingController`/`InputDecoration`/`TextInputType`
// below come from `package:flutter/material.dart`, not `widgets.dart` —
// this is the one accepted exception to the package's "no Material
// widget wrapping" rule: `TextField` provides text-editing/IME/selection/
// clipboard behavior with no low-level primitive equivalent in
// `widgets.dart`. Every visual property (border, background, padding,
// type style) is still fully controlled by the token-driven `Container`
// below and `InputDecoration.collapsed`, which strips all of TextField's
// own chrome.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter;

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'input_interaction_state.dart';
import 'input_keyboard_behavior.dart';
import 'input_size.dart';
import 'input_type.dart';
import 'input_variant.dart';

// The `_resolve*` functions consumed by `build()` below live in
// input_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to Input while living in their
// own file — same convention as `Button`/`button_style_resolvers.dart`.
part 'input_style_resolvers.dart';

/// A single-line text field, built from low-level primitives
/// (`TextField` stripped of its own chrome, wrapped in a token-driven
/// `Container` — no Material `InputDecorator`/outline/underline styling).
///
/// Two structurally different [InputVariant]s share this one widget:
/// - [InputVariant.text] renders the text field described above, with
///   [InputType] choosing the keyboard layout and, for
///   [InputType.password], obscured entry.
/// - [InputVariant.file] renders an icon-only, dashed-border drop target
///   instead — no text field, no [InputType]. Tapping it calls
///   [onFilePick]; actually invoking a native file picker is left to the
///   caller, since this package has no file-picker dependency.
///
/// Public states are explicit constructor params — [disabled] and
/// [invalid] are never inferred. The one state the widget derives itself
/// is "focused", from a live `FocusNode` signal (see
/// [_InputState._isFocused]).
class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.placeholder,
    this.variant = InputVariant.text,
    this.type = InputType.text,
    this.size = InputSize.md,
    this.disabled = false,
    this.invalid = false,
    this.required = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.icon,
    this.onFilePick,
  });

  /// Backing controller for [InputVariant.text]. Ignored for
  /// [InputVariant.file], which has no text content.
  final TextEditingController? controller;

  /// Hint text shown when [InputVariant.text] is empty. Ignored for
  /// [InputVariant.file].
  final String? placeholder;

  /// Which structural layout this Input renders — see [InputVariant].
  final InputVariant variant;

  /// The kind of text content collected — see [InputType]. Only
  /// meaningful when [variant] is [InputVariant.text].
  final InputType type;

  /// Physical size — see [InputSize].
  final InputSize size;

  /// Public state: renders muted colors, rejects focus, and (for
  /// [InputVariant.text]) stops accepting keyboard input. Takes
  /// precedence over [invalid] when both are true.
  final bool disabled;

  /// Public state: renders the negative/error border color. Mirrors
  /// shadcn's `aria-invalid` — this widget doesn't validate its own
  /// content, the caller decides when a value is invalid and passes this
  /// flag explicitly.
  final bool invalid;

  /// Whether the field this Input collects is required. Input has no
  /// [Label] of its own (the `*` marker lives on the paired `Label`
  /// widget), so this flag's only effect here is accessibility: it's
  /// surfaced to screen readers via a wrapping [Semantics] node.
  final bool required;

  /// Called with the field's text on every edit. Only invoked for
  /// [InputVariant.text].
  final ValueChanged<String>? onChanged;

  /// Called with the field's text when editing is submitted (e.g. the
  /// keyboard's "done"/"go" action). Only invoked for [InputVariant.text].
  final ValueChanged<String>? onSubmitted;

  /// Optional external focus node. When null, the widget owns and
  /// disposes an internal one — see [_InputState._focusNode].
  final FocusNode? focusNode;

  /// Whether this Input should request focus when first built.
  final bool autofocus;

  /// Icon shown in an [InputVariant.file] drop target. Falls back to a
  /// built-in upload glyph when null. Ignored for [InputVariant.text].
  final Widget? icon;

  /// Called on tap for [InputVariant.file]. Ignored (and the drop target
  /// rendered non-interactive) while [disabled] is true, or when null.
  /// Ignored entirely for [InputVariant.text].
  final VoidCallback? onFilePick;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param. Driven purely by real
  // FocusNode signals, not simulated. Same convention as
  // `_ButtonState._isPressed`.
  bool _isFocused = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button/AppCheckbox, extended to also move the focus-change listener
  // when the caller starts/stops supplying their own node.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Input');
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
      widget.focusNode!.addListener(_handleFocusChange);
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      oldWidget.focusNode!.removeListener(_handleFocusChange);
      _internalFocusNode = FocusNode(debugLabel: 'Input')
        ..addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  /// True when the field accepts focus/input at all. [disabled] always
  /// wins — mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled;

  /// Resolves the single [InputInteractionState] this frame is styled
  /// for. Order matters: disabled beats invalid beats the live focused
  /// signal beats the enabled default.
  InputInteractionState get _interactionState {
    if (widget.disabled) return InputInteractionState.disabled;
    if (widget.invalid) return InputInteractionState.invalid;
    if (_isFocused) return InputInteractionState.focused;
    return InputInteractionState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ------------------------------------------------
    final state = _interactionState;
    final borderColor = _resolveBorderColor(colors, state);
    final borderWidth = _resolveBorderWidth(state);
    final ringColor = _resolveRingColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);
    final textStyle = _resolveTextStyle(typography, widget.size);
    final padding = _resolvePadding(widget.size);
    final radius = _resolveRadius(widget.size);
    final iconExtent = _resolveIconExtent(widget.size);
    final iconColor = _resolveIconColor(colors, state);

    // --- Layout ---------------------------------------------------------
    final Widget field = widget.variant == InputVariant.file
        ? _FileDropTarget(
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            interactive: _interactive,
            onTap: widget.onFilePick,
            icon: widget.icon,
            iconColor: iconColor,
            iconExtent: iconExtent,
            padding: padding,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            radius: radius,
          )
        : MouseRegion(
            cursor: _interactive
                ? SystemMouseCursors.text
                : SystemMouseCursors.forbidden,
            child: AnimatedContainer(
              duration: AppMotion.durationFast,
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor, width: borderWidth),
                // Painted outside the box bounds and therefore, unlike a
                // wider border, never affects layout size — see
                // `_resolveRingColor`.
                boxShadow: ringColor != null
                    ? [BoxShadow(color: ringColor, spreadRadius: 2)]
                    : null,
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: !widget.disabled,
                keyboardType: _resolveKeyboardType(widget.type),
                obscureText: _resolveObscureText(widget.type),
                inputFormatters: _resolveInputFormatters(widget.type),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                style: textStyle.copyWith(color: colors.content.primary),
                cursorColor: colors.surface.inverted,
                decoration: InputDecoration.collapsed(
                  hintText: widget.placeholder,
                  hintStyle:
                      textStyle.copyWith(color: colors.content.placeholder),
                ),
              ),
            ),
          );

    return Semantics(
      // `required` has no dedicated visual on Input itself — the `*`
      // marker lives on the paired `Label` widget — but screen readers
      // should still be told this field must be filled in.
      label: widget.required ? 'Required' : null,
      child: field,
    );
  }
}

/// The icon-only, dashed-border drop target rendered when
/// [Input.variant] is [InputVariant.file]. Kept as a separate widget so
/// `_InputState.build` doesn't have to interleave the very different
/// text-field and file-variant layouts inline.
class _FileDropTarget extends StatelessWidget {
  const _FileDropTarget({
    required this.focusNode,
    required this.autofocus,
    required this.interactive,
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.iconExtent,
    required this.padding,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.radius,
  });

  final FocusNode focusNode;
  final bool autofocus;
  final bool interactive;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color iconColor;
  final double iconExtent;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          interactive ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        canRequestFocus: interactive,
        child: GestureDetector(
          onTap: interactive ? onTap : null,
          child: CustomPaint(
            // A foreground painter, not `painter:`, so the dashed border
            // is drawn *on top of* the background-filled Container below
            // rather than under it — a same-size solid fill painted after
            // a background painter would otherwise completely cover it.
            foregroundPainter: _DashedBorderPainter(
              color: borderColor,
              strokeWidth: borderWidth,
              radius: radius,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Center(
                child: SizedBox(
                  width: iconExtent,
                  height: iconExtent,
                  child: icon ?? _UploadIcon(color: iconColor),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimal upload glyph used as the default icon for [InputVariant.file]
/// when the caller doesn't supply [Input.icon]. Built from `CustomPaint`
/// for the same reason as `_DashedBorderPainter` and Button's
/// `_ButtonSpinner` — no icon set ships with this package.
class _UploadIcon extends StatelessWidget {
  const _UploadIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _UploadIconPainter(color: color));
  }
}

class _UploadIconPainter extends CustomPainter {
  const _UploadIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final shaftTop = size.height * 0.05;
    final shaftBottom = size.height * 0.65;
    final trayY = size.height * 0.85;

    // Upward shaft.
    canvas.drawLine(
      Offset(centerX, shaftBottom),
      Offset(centerX, shaftTop),
      paint,
    );
    // Arrowhead.
    canvas.drawLine(
      Offset(centerX, shaftTop),
      Offset(centerX - size.width * 0.22, shaftTop + size.height * 0.22),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, shaftTop),
      Offset(centerX + size.width * 0.22, shaftTop + size.height * 0.22),
      paint,
    );
    // Tray.
    canvas.drawLine(
      Offset(size.width * 0.15, trayY),
      Offset(size.width * 0.85, trayY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _UploadIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Paints a dashed rounded-rect border. Flutter's `Border`/`BoxDecoration`
/// only support solid borders, so [InputVariant.file]'s dashed border is
/// hand-rolled here as a `CustomPainter` — the same "no low-level-
/// primitive equivalent, build it with CustomPaint" precedent as
/// `Button`'s `_ButtonSpinner`.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double radius;

  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Deflate by half the stroke width so the stroke is drawn fully
    // inside the widget's bounds instead of being clipped at the edges.
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}
