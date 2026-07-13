// `TextField`/`TextEditingController`/`InputDecoration`/`TextInputType`
// below come from `package:flutter/material.dart`, not `widgets.dart` —
// the same accepted exception `Input` documents in `input.dart` for the
// same reason: `TextField` provides text-editing/IME/selection/clipboard
// behavior with no low-level primitive equivalent in `widgets.dart`.
import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../input/input_keyboard_behavior.dart';
import '../input/input_type.dart';

/// The primary field inside an [InputGroup] — a single-line text field
/// that paints **no border, background, or radius of its own**;
/// [InputGroup] supplies the shared chrome around it instead. This is
/// the structural difference from embedding a plain `Input` directly
/// (which always paints its own border and would show a redundant inner
/// border next to the group's outer one) — shadcn/ui's
/// `InputGroupInput`.
///
/// Reuses [InputType] from `Input` for keyboard layout / obscured-entry /
/// keystroke-filtering behavior, via the shared
/// `resolveInputType*` functions in `input_keyboard_behavior.dart` — the
/// single source of truth for that mapping, also used by `Input` itself.
/// Only the container/border/background logic is deliberately *not*
/// shared, since this widget must not inherit `Input`'s own chrome.
class InputGroupInput extends StatelessWidget {
  const InputGroupInput({
    super.key,
    this.controller,
    this.placeholder,
    this.type = InputType.text,
    this.disabled = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  /// Backing controller. Optional — `TextField` manages its own internal
  /// controller when null.
  final TextEditingController? controller;

  /// Hint text shown when empty.
  final String? placeholder;

  /// The kind of text content collected — see [InputType]. Governs
  /// keyboard layout, obscured entry, and keystroke filtering.
  final InputType type;

  /// Public state: renders muted text and stops accepting keyboard input.
  /// Never inferred — mirrors `Input.disabled`. This only affects the
  /// field's own text color; pair with [InputGroup.disabled] to also dim
  /// the shared border/background and block pointer events.
  final bool disabled;

  /// Called with the field's text on every edit.
  final ValueChanged<String>? onChanged;

  /// Called with the field's text when editing is submitted (e.g. the
  /// keyboard's "done"/"go" action).
  final ValueChanged<String>? onSubmitted;

  /// Optional external focus node — pass the same node to a sibling
  /// [InputGroupAddon.onTap] (`() => focusNode.requestFocus()`) to make
  /// tapping that addon focus this field, since [InputGroup] has no
  /// built-in "focus-within" coordination (see `input_group.dart`).
  final FocusNode? focusNode;

  /// Whether this field should request focus when first built.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ------------------------------------------------
    final textStyle = typography.bodyMd;
    final textColor = disabled ? colors.content.placeholder : colors.content.primary;

    // --- Layout ---------------------------------------------------------
    // `Expanded` is this widget's own build() root — not applied by
    // `InputGroup` around it — so it claims the enclosing `Row`'s
    // remaining width. `Expanded`/`Flexible` only need to sit somewhere
    // between the `Row` and the `RenderBox` they size, with nothing but
    // `StatelessWidget`/`StatefulWidget`s in between (per Flutter's
    // `Expanded` contract) — that holds here even though `InputGroup`
    // places this widget itself, not an `Expanded`, directly in its
    // `children` list. Without this, an unconstrained-width `TextField`
    // inside a `Row` throws a layout error.
    return Expanded(
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: !disabled,
        keyboardType: resolveInputTypeKeyboardType(type),
        obscureText: resolveInputTypeObscureText(type),
        inputFormatters: resolveInputTypeFormatters(type),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
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
