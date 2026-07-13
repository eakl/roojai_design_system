part of 'input_group.dart';

// Style resolvers for InputGroup.
//
// One pure function per resolved property (border color, background),
// same convention as Button/Input's `_style_resolvers.dart` files.
//
// Unlike Button/Input, InputGroup has no live-derived interaction state
// (no hover/press/focus) — its only two states are the explicit
// `disabled`/`invalid` constructor flags, so each resolver only branches
// on those two booleans rather than switching over a dedicated
// `*InteractionState` enum. A "focus-within" ring (shadcn/ui highlights
// the whole group's border when its inner field is focused) is
// deliberately not implemented here: Flutter has no built-in
// "any-descendant-focused" signal the way CSS's `:focus-within` does, and
// building one would mean either the group owning a `FocusNode` its
// children must be wired to (extra required plumbing on every field) or
// polling `FocusManager.instance.primaryFocus` globally. Revisit only if
// this static border turns out not to be enough in practice.

Color _resolveBorderColor(
  SemanticColors colors, {
  required bool disabled,
  required bool invalid,
}) {
  if (invalid) return colors.negative.border;
  return disabled ? colors.border.base : colors.border.strong;
}

Color _resolveBackgroundColor(SemanticColors colors, {required bool disabled}) {
  return disabled ? colors.surface.alternative : colors.surface.base;
}
