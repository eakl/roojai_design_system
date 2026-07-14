// `TextField`/`TextEditingController`/`InputDecoration` below come from
// `package:flutter/material.dart` — the same accepted exception noted in
// `input.dart`: `TextField` provides text-editing/IME/selection/clipboard
// behavior with no low-level primitive equivalent in `widgets.dart`. Every
// visual property (border, background, padding, type style) is still
// fully controlled by the token-driven `Container` below and
// `InputDecoration.collapsed`, which strips all of TextField's own chrome.
import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/motion.dart';
import '../../tokens/primitives/radius.dart';
import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../input/input_interaction_state.dart';

// The `_resolve*` functions consumed by `build()` below live in
// textarea_style_resolvers.dart, split out as `part of` this library (not
// a separate import) so they stay private to Textarea while living in
// their own file — same convention as `Button`/`button_style_resolvers.dart`
// and `Input`/`input_style_resolvers.dart`.
part 'textarea_style_resolvers.dart';

/// A multi-line text field, built from low-level primitives (`TextField`
/// stripped of its own chrome, wrapped in a token-driven `Container` — no
/// Material `InputDecorator`/outline/underline styling) — shadcn/ui's
/// `Textarea`.
///
/// This is the standalone counterpart to `InputGroupTextarea`: that widget
/// paints no chrome of its own and relies on `InputGroup` to supply a
/// shared border, whereas this widget owns its full border/background/
/// focus-ring treatment. It deliberately reuses [InputInteractionState]
/// and matches [Input]'s border/ring/disabled colors exactly, so the two
/// read as one family when used together in a form.
///
/// Public states are explicit constructor params — [disabled] and
/// [invalid] are never inferred. The one state the widget derives itself
/// is "focused", from a live `FocusNode` signal (see
/// [_TextareaState._isFocused]) — identical convention to [Input].
class Textarea extends StatefulWidget {
  const Textarea({
    super.key,
    this.controller,
    this.placeholder,
    this.minLines = 3,
    this.maxLines = 10,
    this.disabled = false,
    this.invalid = false,
    this.required = false,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
  });

  /// Backing controller. `TextField` manages its own internal controller
  /// when null.
  final TextEditingController? controller;

  /// Hint text shown when the field is empty.
  final String? placeholder;

  /// The field's minimum visible height, in lines. Defaults to 3, tall
  /// enough to read as a text area rather than a single-line [Input]. The
  /// field starts at this height and grows with each wrapped/typed line
  /// up to [maxLines].
  final int minLines;

  /// The field's maximum height, in lines. The field grows one line at a
  /// time as content is entered — from [minLines] up to this cap — after
  /// which it stops growing and its content scrolls internally instead.
  /// Defaults to 10. Pass null to remove the cap and let the field grow
  /// unbounded with content instead of ever scrolling internally — same
  /// "no artificial cap" behavior as `InputGroupTextarea`.
  final int? maxLines;

  /// Public state: renders muted colors, rejects focus, and stops
  /// accepting keyboard input. Takes precedence over [invalid] when both
  /// are true — mirrors [Input.disabled].
  final bool disabled;

  /// Public state: renders the negative/error border and focus-ring
  /// color. Mirrors shadcn's `aria-invalid` — this widget doesn't
  /// validate its own content, the caller decides when a value is invalid
  /// and passes this flag explicitly. Mirrors [Input.invalid].
  final bool invalid;

  /// Whether the field this Textarea collects is required. Like [Input],
  /// Textarea has no `Label` of its own (the `*` marker lives on the
  /// paired `Label` widget), so this flag's only effect here is
  /// accessibility: it's surfaced to screen readers via a wrapping
  /// [Semantics] node.
  final bool required;

  /// Called with the field's text on every edit.
  final ValueChanged<String>? onChanged;

  /// Optional external focus node. When null, the widget owns and
  /// disposes an internal one — see [_TextareaState._focusNode].
  final FocusNode? focusNode;

  /// Whether this Textarea should request focus when first built.
  final bool autofocus;

  @override
  State<Textarea> createState() => _TextareaState();
}

class _TextareaState extends State<Textarea> {
  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param. Driven purely by real
  // FocusNode signals, not simulated. Same convention as
  // `_InputState._isFocused`.
  bool _isFocused = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // `_InputState`, including moving the focus-change listener when the
  // caller starts/stops supplying their own node.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'Textarea');
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(Textarea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
      widget.focusNode!.addListener(_handleFocusChange);
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      oldWidget.focusNode!.removeListener(_handleFocusChange);
      _internalFocusNode = FocusNode(debugLabel: 'Textarea')
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

  /// Resolves the single [InputInteractionState] this frame is styled
  /// for. Order matters: disabled beats invalid beats the live focused
  /// signal beats the enabled default — identical precedence to [Input].
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
    final ringColor = _resolveRingColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);
    final textColor = _resolveTextColor(colors, state);
    final textStyle = typography.bodyMd;
    final padding = _resolvePadding();
    final radius = _resolveRadius();

    // --- Layout ---------------------------------------------------------
    final field = MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.text,
      child: AnimatedContainer(
        duration: AppMotion.durationFast,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
          // Painted outside the box bounds and therefore, unlike a wider
          // border, never affects layout size — same rationale as
          // `Input`'s `_resolveRingColor`.
          boxShadow: ringColor != null
              ? [BoxShadow(color: ringColor, spreadRadius: 2)]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: !widget.disabled,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          onChanged: widget.onChanged,
          style: textStyle.copyWith(color: textColor),
          cursorColor: colors.surface.inverted,
          decoration: InputDecoration.collapsed(
            hintText: widget.placeholder,
            hintStyle: textStyle.copyWith(color: colors.content.placeholder),
          ),
        ),
      ),
    );

    return Semantics(
      // `required` has no dedicated visual on Textarea itself — the `*`
      // marker lives on the paired `Label` widget — but screen readers
      // should still be told this field must be filled in. Mirrors
      // `Input`'s `Semantics` wrapping exactly.
      label: widget.required ? 'Required' : null,
      child: field,
    );
  }
}
