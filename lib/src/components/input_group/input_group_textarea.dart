// See the same `flutter/material.dart` exception noted in
// `input_group_input.dart` — `TextField` (multi-line here) is the one
// accepted Material import for text-editing/IME behavior.
import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// A multi-line alternative to [InputGroupInput] for use inside an
/// [InputGroup] — e.g. a group with a top-aligned label/icon addon next
/// to a growing text area — shadcn/ui's `InputGroupTextarea`. Paints
/// **no border, background, or radius of its own**, same as
/// [InputGroupInput]; [InputGroup] supplies the shared chrome.
///
/// Unlike [InputGroupInput], this has no [InputType] parameter — a
/// multi-line field has no meaningful "email"/"phone"/"number" keyboard
/// restriction or obscured-entry mode, so it always renders as plain,
/// unobscured multi-line text.
class InputGroupTextarea extends StatelessWidget {
  const InputGroupTextarea({
    super.key,
    this.controller,
    this.placeholder,
    this.disabled = false,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    this.minLines = 3,
    this.maxLines,
  });

  /// Backing controller. Optional — `TextField` manages its own internal
  /// controller when null.
  final TextEditingController? controller;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Public state: renders muted text and stops accepting keyboard input.
  /// Never inferred — mirrors [InputGroupInput.disabled].
  final bool disabled;

  /// Called with the field's text on every edit.
  final ValueChanged<String>? onChanged;

  /// Optional external focus node — same contract as
  /// [InputGroupInput.focusNode].
  final FocusNode? focusNode;

  /// Whether this field should request focus when first built.
  final bool autofocus;

  /// The field's minimum visible height, in lines. Defaults to 3, tall
  /// enough to read as a text area rather than a single-line field.
  final int minLines;

  /// The field's maximum height, in lines, before it scrolls internally
  /// instead of growing further. Null (the default) lets it grow
  /// unbounded with content, matching `Input`/[InputGroupInput]'s own
  /// "no artificial cap" behavior.
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ------------------------------------------------
    final textStyle = typography.bodyMd;
    final textColor = disabled ? colors.content.placeholder : colors.content.primary;

    // --- Layout ---------------------------------------------------------
    // Same `Expanded`-as-build()-root shape as `InputGroupInput` — see
    // the comment there for why this correctly claims the enclosing
    // `Row`'s remaining width despite `InputGroup` placing this widget
    // itself, not an `Expanded`, directly in its `children` list.
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: !disabled,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: onChanged,
        style: textStyle.copyWith(color: textColor),
        cursorColor: colors.surface.inverted,
        decoration: InputDecoration.collapsed(
          hintText: placeholder,
          hintStyle: textStyle.copyWith(color: colors.content.placeholder),
        ),
      ),
    );
  }
}
