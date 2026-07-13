// `TextField`/`TextEditingController`/`InputDecoration`/`TextInputType`
// below come from `package:flutter/material.dart`, not `widgets.dart` —
// the same accepted exception to the package's "no Material widget
// wrapping" rule that `Input` documents: `TextField` provides the
// text-editing/IME/paste behavior (including SMS-autofill paste of a full
// code) with no low-level primitive equivalent in `widgets.dart`. It is
// rendered fully transparent and invisibly overlays the boxes below —
// every visual pixel on screen comes from the token-driven `_OtpBox`es,
// never from the field itself.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'input_otp_interaction_state.dart';

// The `_resolve*` functions consumed by `build()` below live in
// input_otp_style_resolvers.dart, split out as `part of` this library —
// same convention as `Input`/`input_style_resolvers.dart`.
part 'input_otp_style_resolvers.dart';

/// A fixed-length one-time-code input: [length] single-digit boxes backed
/// by one hidden, fully transparent `TextField` that drives them all.
///
/// Structurally this is the same "invisible real text field + token-drawn
/// boxes on top" idea as `Input`, extended with one extra constraint the
/// task requires: entry is number-only and *append/delete-at-the-end
/// only* — there is no such thing as "select box 3 and edit it". Callers
/// never see individual boxes as separate fields; [controller] holds the
/// whole code as a single string, exactly like `Input.controller` holds a
/// whole string of arbitrary text.
///
/// The append/delete-only behavior is enforced by [_OtpEditFormatter]
/// (below), not by trusting where the OS thinks the cursor is — see its
/// doc comment for why a position-based approach isn't good enough here.
///
/// Public state is managed the same way as [Input]: [disabled] and
/// [invalid] are explicit constructor params, never inferred. The one
/// state the widget derives itself is "focused", from a live `FocusNode`
/// signal (see [_InputOtpState._isFocused]) — same pattern as
/// `_InputState._isFocused`.
class InputOtp extends StatefulWidget {
  const InputOtp({
    super.key,
    required this.length,
    this.controller,
    this.disabled = false,
    this.invalid = false,
    this.required = false,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  }) : assert(length > 0, 'InputOtp.length must be at least 1');

  /// Number of single-digit boxes rendered, and the max number of digits
  /// [controller] will ever hold.
  final int length;

  /// Backing controller for the whole code, as one string — e.g. `"123"`
  /// while three of six boxes are filled. When null, the widget owns and
  /// disposes an internal one, exactly like [Input.controller].
  final TextEditingController? controller;

  /// Public state: renders muted colors, rejects focus, and stops
  /// accepting keyboard input entirely. Takes precedence over [invalid]
  /// when both are true — mirrors [Input.disabled].
  final bool disabled;

  /// Public state: renders the negative/error border + ring. This widget
  /// doesn't validate its own content (e.g. "was the code correct?") —
  /// the caller decides and passes this flag explicitly, same as
  /// [Input.invalid].
  final bool invalid;

  /// Whether the code this InputOtp collects is required. Like `Input`,
  /// this widget has no `Label` of its own, so this flag's only effect
  /// here is accessibility: it's surfaced to screen readers via a
  /// wrapping [Semantics] node — mirrors [Input.required].
  final bool required;

  /// Called with the full code on every edit (append, delete, or paste).
  final ValueChanged<String>? onChanged;

  /// Optional external focus node. When null, the widget owns and
  /// disposes an internal one — see [_InputOtpState._focusNode].
  final FocusNode? focusNode;

  /// Whether this InputOtp should request focus when first built.
  final bool autofocus;

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  // Owned only when the caller doesn't supply their own controller/focus
  // node, so we know whether we're responsible for disposing them — same
  // pattern as `_InputState`.
  TextEditingController? _internalController;
  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param. Driven purely by real
  // FocusNode signals, not simulated. Same convention as
  // `_InputState._isFocused`.
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'InputOtp');
    }
    // The controller (not just `onChanged` on the `TextField`) is the
    // single source of truth for the code, so listen here to rebuild the
    // boxes whenever it changes — including changes the caller makes
    // directly to a controller they supplied themselves.
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(InputOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own controller: swap our
    // internally-owned one in or out accordingly, moving the listener
    // across — same pattern as `_InputState`'s focus-node handling,
    // extended here to the controller too since InputOtp owns one.
    if (oldWidget.controller == null && widget.controller != null) {
      _internalController?.removeListener(_handleTextChange);
      _internalController?.dispose();
      _internalController = null;
      widget.controller!.addListener(_handleTextChange);
    } else if (oldWidget.controller != null && widget.controller == null) {
      oldWidget.controller!.removeListener(_handleTextChange);
      _internalController = TextEditingController(
        text: oldWidget.controller!.text,
      )..addListener(_handleTextChange);
    }

    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
      widget.focusNode!.addListener(_handleFocusChange);
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      oldWidget.focusNode!.removeListener(_handleFocusChange);
      _internalFocusNode = FocusNode(debugLabel: 'InputOtp')
        ..addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _internalController?.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    // Rebuild so the boxes reflect the controller's latest text, then
    // notify the caller — mirrors how `Input` forwards `TextField.
    // onChanged`, except InputOtp listens to the controller directly
    // since the hidden `TextField` below is wired to it either way.
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  /// True when the field accepts focus/input at all. [disabled] always
  /// wins — mirrors [Input]'s `_interactive` getter.
  bool get _interactive => !widget.disabled;

  /// Resolves the single [InputOtpInteractionState] this frame is styled
  /// for. Order matters: disabled beats invalid beats the live focused
  /// signal beats the enabled default — mirrors `_InputState.
  /// _interactionState` exactly.
  InputOtpInteractionState get _interactionState {
    if (widget.disabled) return InputOtpInteractionState.disabled;
    if (widget.invalid) return InputOtpInteractionState.invalid;
    if (_isFocused) return InputOtpInteractionState.focused;
    return InputOtpInteractionState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ------------------------------------------------
    final state = _interactionState;
    final value = _controller.text;
    final borderColor = _resolveBorderColor(colors, state);
    final activeBorderColor = _resolveActiveBorderColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);
    final textColor = _resolveTextColor(colors, state);
    final digitStyle = typography.h4.copyWith(color: textColor);

    // The one box the user is about to fill next. Only meaningful (and
    // only ever drawn as "active") while focused and not yet full —
    // there's no per-box selection, so at most one box is ever active.
    final activeIndex = value.length;
    final isFull = value.length >= widget.length;

    // --- Layout ---------------------------------------------------------
    return Semantics(
      // `required` has no dedicated visual here — same as `Input`, the
      // `*` marker lives on a paired `Label` widget — but screen readers
      // should still be told this field must be filled in.
      label: widget.required ? 'Required' : null,
      child: MouseRegion(
        cursor: _interactive
            ? SystemMouseCursors.text
            : SystemMouseCursors.forbidden,
        // Tapping anywhere in the row focuses the single hidden field —
        // there is no per-box tap target, matching the "user can't
        // select one box" requirement.
        child: GestureDetector(
          onTap: _interactive ? () => _focusNode.requestFocus() : null,
          child: Stack(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.spacing8),
                    _OtpBox(
                      char: i < value.length ? value[i] : '',
                      isActive: !isFull && _isFocused && i == activeIndex,
                      borderColor: borderColor,
                      activeBorderColor: activeBorderColor,
                      ringColor: _resolveRingColor(
                        colors,
                        state,
                        isActive: !isFull && _isFocused && i == activeIndex,
                      ),
                      backgroundColor: backgroundColor,
                      textStyle: digitStyle,
                    ),
                  ],
                ],
              ),
              // Fully transparent field stacked over the boxes: it
              // captures every real keyboard/paste event (including full
              // SMS-autofill codes) and stays invisible itself, so the
              // boxes above are the only thing ever painted.
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.autofocus,
                    enabled: _interactive,
                    keyboardType: TextInputType.number,
                    // No visible cursor/selection handles — there is
                    // nothing to see anyway (opacity 0), and disabling
                    // interactive selection prevents touch-drag from
                    // trying to place the cursor mid-string. Combined
                    // with `_OtpEditFormatter` below (which normalizes
                    // *every* edit to append-at-end/delete-from-end
                    // regardless of where the OS thinks the cursor
                    // landed), this guarantees the box the user is
                    // editing is always "the next empty one", never an
                    // arbitrary box picked by tapping or dragging.
                    showCursor: false,
                    enableInteractiveSelection: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _OtpEditFormatter(length: widget.length),
                    ],
                    decoration: const InputDecoration.collapsed(hintText: null),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Normalizes every edit of the hidden `TextField` to append-at-the-end or
/// delete-from-the-end, regardless of where the OS's own text-editing
/// machinery thinks the cursor/selection is.
///
/// A position-based approach (just forcing `selection` to the end after
/// each edit) isn't reliable enough on its own: it fixes the cursor for
/// the *next* keystroke, but says nothing about where the keystroke that
/// just happened was actually applied — e.g. a hardware keyboard's Home/
/// Left arrow keys can move the cursor without ever going through this
/// formatter (formatters only run on edits that change text). So instead
/// this formatter looks only at the *lengths* of the old and new digit
/// strings, not their content or the reported selection, and always
/// produces the corresponding append-at-end or delete-from-end result.
/// This has a useful side effect for free: pasting a full code (e.g. from
/// SMS autofill) is just a large single "insertion", so it's appended in
/// one shot the same way a single digit would be.
class _OtpEditFormatter extends TextInputFormatter {
  const _OtpEditFormatter({required this.length});

  /// Max digits this InputOtp holds — matches [InputOtp.length].
  final int length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // `newValue.text` is already digits-only here: this formatter is
    // chained after `FilteringTextInputFormatter.digitsOnly` in the
    // field's `inputFormatters`.
    final oldDigits = oldValue.text;
    final newDigits = newValue.text;

    String result;
    if (newDigits.length >= oldDigits.length) {
      // Insertion (or a same-length replace, e.g. select-all + retype):
      // take only the *count* of newly added digits and append them to
      // the end of the existing value — never wherever in `newDigits`
      // the OS placed them.
      final addedCount = newDigits.length - oldDigits.length;
      final appended = addedCount > 0
          ? newDigits.substring(newDigits.length - addedCount)
          : '';
      result = oldDigits + appended;
    } else {
      // Deletion: drop exactly that many characters from the end,
      // regardless of where the backspace/selection happened to land.
      final removedCount = oldDigits.length - newDigits.length;
      result = oldDigits.substring(0, oldDigits.length - removedCount);
    }

    if (result.length > length) {
      result = result.substring(0, length);
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

/// A single digit box. Purely presentational — all interaction lives on
/// the hidden `TextField` in `_InputOtpState.build`.
class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.char,
    required this.isActive,
    required this.borderColor,
    required this.activeBorderColor,
    required this.ringColor,
    required this.backgroundColor,
    required this.textStyle,
  });

  final String char;
  final bool isActive;
  final Color borderColor;
  final Color activeBorderColor;
  final Color? ringColor;
  final Color backgroundColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.spacing40,
      height: AppSpacing.spacing48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(
          color: isActive ? activeBorderColor : borderColor,
          // Constant width regardless of state — a wider border on the
          // active box would be additive to layout size and shift
          // neighboring boxes, exactly the pitfall `Input`'s
          // `_resolveBorderWidth` doc warns about. The active box is
          // highlighted via `ringColor` (a `BoxShadow`, painted outside
          // the box bounds) instead.
          width: 1,
        ),
        // Painted outside the box bounds and therefore never affects
        // layout size — see `Input`'s `_resolveRingColor` for the same
        // rationale applied here.
        boxShadow: ringColor != null
            ? [BoxShadow(color: ringColor!, spreadRadius: 2)]
            : null,
      ),
      child: Text(char, style: textStyle),
    );
  }
}
