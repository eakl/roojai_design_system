import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter;
import 'package:flutter/widgets.dart' show TextInputType;

import 'input_type.dart';

// Single source of truth for how [InputType] maps to `TextField` keyboard
// behavior — keyboard layout, obscured entry, and keystroke filtering.
//
// `Input` (via `input_style_resolvers.dart`) and `InputGroupInput` both
// render a bare `TextField` for the same `InputType` values, but must
// *not* share border/container styling — `InputGroupInput` paints no
// chrome of its own so it can sit inside `InputGroup`'s shared border,
// whereas `Input` always paints its own (see `InputGroup`'s class doc in
// `input_group.dart` for why those can't be unified). This file is the
// shared seam that keeps only the keyboard-behavior mapping identical
// between the two, so a change here (e.g. a new `InputType` value, a
// fixed phone regex) can never be applied to one and silently missed on
// the other.

/// Keyboard layout suggested for [type]. This only *suggests* which soft
/// keyboard layout to show — it never restricts what a user can actually
/// type, including on desktop/web where there's no soft keyboard to swap
/// at all. See [resolveInputTypeFormatters] for the keystroke-level
/// restriction.
TextInputType resolveInputTypeKeyboardType(InputType type) {
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
bool resolveInputTypeObscureText(InputType type) =>
    type == InputType.password;

/// Keystroke-level restriction for [type]. `keyboardType` alone (see
/// [resolveInputTypeKeyboardType]) never restricts what a user can
/// actually type — [InputType.number]/[InputType.phone] need an explicit
/// `TextInputFormatter` to actually reject non-matching characters.
List<TextInputFormatter>? resolveInputTypeFormatters(InputType type) {
  switch (type) {
    case InputType.number:
      return [FilteringTextInputFormatter.digitsOnly];
    case InputType.phone:
      // Phone numbers legitimately contain more than digits, so allow
      // the common punctuation too rather than digits-only.
      return [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))];
    case InputType.text:
    case InputType.email:
    case InputType.password:
    case InputType.url:
      return null;
  }
}
