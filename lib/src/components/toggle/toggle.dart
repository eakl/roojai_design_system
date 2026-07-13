import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'toggle_interaction_state.dart';
import 'toggle_size.dart';
import 'toggle_variant.dart';

// The `_resolve*` functions consumed by `build()` below live in
// toggle_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to Toggle while living in their
// own file — same split as Button's `button_style_resolvers.dart`.
part 'toggle_style_resolvers.dart';

/// A two-state pressable button that toggles between "on" and "off" (e.g.
/// "Bold" in a toolbar), built from low-level primitives
/// (`GestureDetector` + `Focus`, no Material `ToggleButtons`).
///
/// [pressed] and [disabled] are both explicit constructor params — like
/// [Button], public state is never inferred from other props. The one
/// state the widget derives itself is the live tap-down feedback, from a
/// real `GestureDetector` signal (see [_ToggleState._isTapped]).
class Toggle extends StatefulWidget {
  const Toggle({
    super.key,
    required this.label,
    required this.pressed,
    required this.onPressedChange,
    this.variant = ToggleVariant.standard,
    this.size = ToggleSize.md,
    this.disabled = false,
    this.leading,
    this.focusNode,
    this.autofocus = false,
  });

  /// The toggle's text content. Always shown, regardless of [pressed].
  final String label;

  /// Whether the toggle is currently "on". Always reflects the caller's
  /// state — this widget holds no internal on/off state of its own.
  final bool pressed;

  /// Called with the next pressed value on tap. Ignored (and the toggle
  /// rendered non-interactive) while [disabled] is true, or when null.
  final ValueChanged<bool>? onPressedChange;

  /// Visual treatment — see [ToggleVariant].
  final ToggleVariant variant;

  /// Physical size — see [ToggleSize].
  final ToggleSize size;

  /// Public state: renders muted colors and suppresses taps and focus
  /// entirely. [pressed] still governs the resolved colors while
  /// disabled, so the toggle keeps communicating its on/off state.
  final bool disabled;

  /// Optional widget shown before [label] (typically an `Icon`).
  final Widget? leading;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_ToggleState._focusNode].
  final FocusNode? focusNode;

  /// Whether this toggle should request focus when first built.
  final bool autofocus;

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param. Driven purely by real
  // GestureDetector callbacks, not simulated. Kept distinct from
  // `widget.pressed` (the on/off value) — see ToggleInteractionState's doc.
  bool _isTapped = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button's `_internalFocusNode`.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Toggle(${widget.label})');
    }
  }

  @override
  void didUpdateWidget(Toggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Toggle(${widget.label})');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the toggle accepts taps at all. [disabled] always wins,
  /// and a null [Toggle.onPressedChange] makes it inert even when not
  /// disabled — mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onPressedChange != null;

  /// Resolves the single [ToggleInteractionState] this frame is styled
  /// for. Order matters: disabled beats the live tapped signal beats the
  /// enabled default.
  ToggleInteractionState get _interactionState {
    if (widget.disabled) return ToggleInteractionState.disabled;
    if (_isTapped) return ToggleInteractionState.tapped;
    return ToggleInteractionState.enabled;
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isTapped = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isTapped = false);
  }

  void _handleTapCancel() {
    setState(() => _isTapped = false);
  }

  void _handleTap() => widget.onPressedChange!(!widget.pressed);

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties -------------------------------------------
    final state = _interactionState;
    final backgroundColor = _resolveBackgroundColor(
      colors,
      widget.variant,
      widget.pressed,
      state,
    );
    final foregroundColor =
        _resolveForegroundColor(colors, widget.pressed, state);
    final borderColor = _resolveBorderColor(colors, widget.variant, state);
    final textStyle = _resolveTextStyle(typography, widget.size);
    final padding = _resolvePadding(widget.size);
    final iconGap = _resolveIconGap(widget.size);
    final iconExtent = _resolveIconExtent(widget.size);
    final radius = _resolveRadius(widget.size);

    // --- Layout ---------------------------------------------------------
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.leading != null) ...[
          SizedBox(
            width: iconExtent,
            height: iconExtent,
            child: widget.leading,
          ),
          SizedBox(width: iconGap),
        ],
        Text(widget.label, style: textStyle.copyWith(color: foregroundColor)),
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
          onTap: _interactive ? _handleTap : null,
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            curve: AppMotion.curveStandard,
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
