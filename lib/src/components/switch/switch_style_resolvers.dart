part of 'switch.dart';

// Track/thumb color resolvers for AppSwitch. One resolver per property,
// each taking the raw (value, disabled) flags directly rather than a
// combined state enum — unlike Button/Badge, AppSwitch has no ephemeral
// gesture-derived state to fold into the matrix, so a flat pair of
// booleans stays readable without one.

Color _resolveTrackColor(SemanticColors colors, bool value, bool disabled) {
  final restingColor = value ? colors.surface.inverted : colors.border.strong;
  // A washed-out tint of the resting on/off color (rather than one flat
  // neutral for both) so a disabled switch still visibly communicates
  // which position it's in, matching AppSwitch.disabled's doc.
  return disabled ? restingColor.withOpacity(0.4) : restingColor;
}

Color _resolveThumbColor(SemanticColors colors, bool disabled) {
  return disabled
      ? colors.surface.base.withOpacity(0.8)
      : colors.surface.base;
}
