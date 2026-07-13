import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/semantic_colors.dart';

part 'switch_style_resolvers.dart';

/// A binary on/off control built from low-level primitives
/// (`GestureDetector` + `AnimatedContainer`/`AnimatedAlign`, no Material
/// `Switch`).
///
/// Named `AppSwitch` (not `Switch`) to avoid colliding with
/// `package:flutter/widgets.dart`'s `Switch` and Dart's own `switch`
/// keyword/statement.
///
/// [value] and [disabled] are both explicit constructor params — like
/// [Button], public state is never inferred from other props. Unlike
/// [Button], there is no internally-derived "pressed" style here; the
/// track and thumb just animate directly between their on/off/disabled
/// colors and positions.
class AppSwitch extends StatefulWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether the switch is on. Always reflects the caller's state — this
  /// widget holds no internal on/off state of its own.
  final bool value;

  /// Called with the new value on tap. Ignored (and the switch rendered
  /// non-interactive) while [disabled] is true, or when null.
  final ValueChanged<bool>? onChanged;

  /// Public state: renders muted track/thumb colors and suppresses taps
  /// and focus entirely. [value] still governs thumb position while
  /// disabled, so the switch keeps communicating which position it's in.
  final bool disabled;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_AppSwitchState._focusNode].
  final FocusNode? focusNode;

  /// Whether this switch should request focus when first built.
  final bool autofocus;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button's `_internalFocusNode`.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSwitch');
    }
  }

  @override
  void didUpdateWidget(AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSwitch');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the switch accepts taps at all. [disabled] always wins,
  /// and a null [AppSwitch.onChanged] makes the switch inert even when
  /// not disabled — mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onChanged != null;

  void _handleTap() => widget.onChanged!(!widget.value);

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties --------------------------------------------
    final trackColor = _resolveTrackColor(colors, widget.value, widget.disabled);
    final thumbColor = _resolveThumbColor(colors, widget.disabled);

    // --- Layout -----------------------------------------------------------
    const trackWidth = 40.0;
    const trackHeight = 24.0;
    const thumbDiameter = 20.0;
    const thumbInset = (trackHeight - thumbDiameter) / 2;

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
            width: trackWidth,
            height: trackHeight,
            padding: const EdgeInsets.all(thumbInset),
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
            child: AnimatedAlign(
              duration: AppMotion.durationFast,
              curve: AppMotion.curveStandard,
              alignment:
                  widget.value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: thumbDiameter,
                height: thumbDiameter,
                decoration: BoxDecoration(
                  color: thumbColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
