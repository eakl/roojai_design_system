import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/motion.dart';
import '../../tokens/semantic/semantic_colors.dart';

part 'radio_style_resolvers.dart';

/// A single-select control built from low-level primitives
/// (`GestureDetector` + `AnimatedContainer`/`AnimatedScale`, no Material
/// `Radio`).
///
/// Named `AppRadio` (not `Radio`) to avoid colliding with
/// `package:flutter/widgets.dart`'s `Radio`.
///
/// Unlike [AppCheckbox], [AppRadio] has no "unselect" affordance of its
/// own — tapping an already-[selected] radio still calls [onSelect].
/// Radio groups are exclusive-select by construction (selecting one
/// deselects the others), and enforcing that exclusivity is the
/// *caller's* responsibility, e.g. by tracking a single selected value
/// across a set of `AppRadio`s and passing each one `selected: value ==
/// thisOption`. This widget only reports "I was tapped" — it never
/// flips its own value, matching [Button]'s convention that public state
/// is never inferred from other props.
class AppRadio extends StatefulWidget {
  const AppRadio({
    super.key,
    required this.selected,
    required this.onSelect,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// Whether this radio is the selected option in its group. Always
  /// reflects the caller's state — this widget holds no internal
  /// selected/unselected state of its own.
  final bool selected;

  /// Called on every tap, regardless of [selected] — see the class doc
  /// for why. Ignored (and the radio rendered non-interactive) while
  /// [disabled] is true, or when null.
  final VoidCallback? onSelect;

  /// Public state: renders muted colors and suppresses taps and focus
  /// entirely. [selected] still governs whether the inner dot is drawn
  /// while disabled, so the radio keeps communicating its value.
  final bool disabled;

  /// Optional external focus node. When null, the widget owns and disposes
  /// an internal one — see [_AppRadioState._focusNode].
  final FocusNode? focusNode;

  /// Whether this radio should request focus when first built.
  final bool autofocus;

  @override
  State<AppRadio> createState() => _AppRadioState();
}

class _AppRadioState extends State<AppRadio> {
  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button's `_internalFocusNode`.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppRadio');
    }
  }

  @override
  void didUpdateWidget(AppRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppRadio');
    }
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the radio accepts taps at all. [disabled] always wins, and
  /// a null [AppRadio.onSelect] makes it inert even when not disabled —
  /// mirrors [Button]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onSelect != null;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties --------------------------------------------
    final borderColor =
        _resolveBorderColor(colors, widget.selected, widget.disabled);
    final dotColor = _resolveDotColor(colors, widget.disabled);

    // --- Layout -----------------------------------------------------------
    const size = 20.0;
    const dotDiameter = size * 0.5;

    return MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: Focus(
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _interactive,
        child: GestureDetector(
          onTap: _interactive ? widget.onSelect : null,
          child: AnimatedContainer(
            duration: AppMotion.durationFast,
            curve: AppMotion.curveStandard,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            // The inner dot scales in/out rather than being added/removed
            // outright, so selecting/deselecting reads as one continuous
            // motion instead of a hard cut.
            child: AnimatedScale(
              duration: AppMotion.durationFast,
              curve: AppMotion.curveStandard,
              scale: widget.selected ? 1.0 : 0.0,
              child: Container(
                width: dotDiameter,
                height: dotDiameter,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
