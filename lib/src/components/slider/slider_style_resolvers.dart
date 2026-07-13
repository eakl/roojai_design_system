part of 'slider.dart';

// Track/fill/thumb-ring color resolvers for AppSlider. One resolver per
// property, mirroring Button's/Badge's `_resolve*` split.

/// The resting (unfilled) track color. Currently the same regardless of
/// [disabled] — disabled communicates itself through [_resolveFillColor]'s
/// muted color instead — but keeps the `(colors, disabled)` signature
/// every resolver here shares, so a disabled-specific track tint later is
/// a one-line change instead of a signature change (same rationale as
/// Button's `_resolveRadius`).
Color _resolveTrackColor(SemanticColors colors, bool disabled) {
  return colors.surface.alternative;
}

Color _resolveFillColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.surface.inverted;
}

/// Always the base surface color, regardless of value/disabled — the ring
/// exists purely to separate the (colored) thumb from whatever's behind
/// it, not to communicate state.
Color _resolveThumbRingColor(SemanticColors colors) {
  return colors.surface.base;
}
