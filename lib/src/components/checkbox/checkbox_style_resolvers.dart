part of 'checkbox.dart';

// Background/border/glyph color resolvers for AppCheckbox. One resolver
// per property — same shape as Button's/Badge's `_resolve*` split — so
// restyling the checkbox never touches the gesture/paint code in
// checkbox.dart.

Color _resolveBackgroundColor(
  SemanticColors colors,
  CheckboxValue value,
  bool disabled,
) {
  if (disabled) return colors.surface.alternative;
  // Checked and indeterminate are both "filled" states — only unchecked
  // is transparent — so both map to the same inverted-surface fill.
  return value == CheckboxValue.unchecked
      ? const Color(0x00000000)
      : colors.surface.inverted;
}

Color _resolveBorderColor(
  SemanticColors colors,
  CheckboxValue value,
  bool disabled,
) {
  if (disabled) return colors.border.base;
  return value == CheckboxValue.unchecked
      ? colors.border.strong
      : colors.surface.inverted;
}

Color _resolveGlyphColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.content.onBrand;
}
