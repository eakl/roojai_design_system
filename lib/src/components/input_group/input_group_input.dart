// `TextField`/`TextEditingController`/`InputDecoration`/`TextInputType`
// below come from `package:flutter/material.dart`, not `widgets.dart` —
// the same accepted exception `Input` documents in `input.dart` for the
// same reason: `TextField` provides text-editing/IME/selection/clipboard
// behavior with no low-level primitive equivalent in `widgets.dart`.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;

import '../../theme/app_tokens.dart';
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
/// keystroke-filtering behavior (see `_resolveKeyboardType` etc. below),
/// but re-implements those small helpers locally rather than importing
/// `Input`'s — they live as `part of 'input.dart'` and are private to
/// that file. Duplicating ~15 lines here keeps `InputGroupInput`
/// decoupled from `Input`'s own container/border logic, which this
/// widget must *not* inherit.
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
        keyboardType: _resolveKeyboardType(type),
        obscureText: _resolveObscureText(type),
        inputFormatters: _resolveInputFormatters(type),
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

// Local re-implementation of `Input`'s `InputType` → keyboard-behavior
// mapping (see `_resolveKeyboardType`/`_resolveObscureText`/
// `_resolveInputFormatters` in `input_style_resolvers.dart`), kept
// private to this file — see the class doc above for why this is
// duplicated rather than shared.

TextInputType _resolveKeyboardType(InputType type) {
  switch (type) {
    case InputType.text:
    case InputType.password:
      return TextInputType.text;
    case InputType.email:
      return TextInputType.emailAddress;
    case InputType.number:
      return TextInputType.number;
    case InputType.phone:
      return TextInputType.phone;
    case InputType.url:
      return TextInputType.url;
  }
}

/// Only [InputType.password] obscures entered characters.
bool _resolveObscureText(InputType type) => type == InputType.password;

/// `keyboardType` alone only *suggests* which soft keyboard layout to
/// show — it never restricts what a user can actually type, including on
/// desktop/web where there's no soft keyboard to swap at all.
/// [InputType.number]/[InputType.phone] need an explicit
/// `TextInputFormatter` to actually reject non-matching characters.
List<TextInputFormatter>? _resolveInputFormatters(InputType type) {
  switch (type) {
    case InputType.number:
      return [FilteringTextInputFormatter.digitsOnly];
    case InputType.phone:
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))];
    case InputType.text:
    case InputType.email:
    case InputType.password:
    case InputType.url:
      return null;
  }
}
