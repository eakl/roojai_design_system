part of 'radio.dart';

// Border/dot color resolvers for AppRadio. One resolver per property —
// same shape as Button's/Badge's `_resolve*` split — so restyling the
// radio never touches the gesture/animation code in radio.dart.

Color _resolveBorderColor(SemanticColors colors, bool selected, bool disabled) {
  if (disabled) return colors.border.base;
  return selected ? colors.surface.inverted : colors.border.strong;
}

Color _resolveDotColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.surface.inverted;
}
