part of 'input_otp.dart';

// Style resolvers for InputOtp.
//
// One pure function per resolved *property* (border color, ring color,
// background, text color) — same convention as Input's
// `input_style_resolvers.dart`. There is no size axis (no `InputOtpSize`)
// today, so box dimensions are plain constants in `input_otp.dart` rather
// than a `_resolve*(size)` function with a single-branch switch.

/// Border color for every box. Constant across [state] except [invalid] —
/// still resolved through a switch (rather than a bare ternary) so it
/// follows the same one-resolver-per-property shape as every other
/// property here.
Color _resolveBorderColor(SemanticColors colors, InputOtpInteractionState state) {
  switch (state) {
    case InputOtpInteractionState.enabled:
    case InputOtpInteractionState.focused:
    case InputOtpInteractionState.disabled:
      return colors.border.base;
    case InputOtpInteractionState.invalid:
      return colors.negative.border;
  }
}

/// A soft ring drawn *outside* the active box's own border via `BoxShadow`
/// — null for every box that isn't the one about to be filled, and for
/// every state where nothing should ring at all. Mirrors Input's
/// `_resolveRingColor`: `BoxShadow` doesn't participate in layout sizing
/// (unlike a wider `Border`), so the active box can be highlighted without
/// ever shifting the row's overall width.
Color? _resolveRingColor(
  SemanticColors colors,
  InputOtpInteractionState state, {
  required bool isActive,
}) {
  if (!isActive) return null;
  switch (state) {
    case InputOtpInteractionState.enabled:
    case InputOtpInteractionState.disabled:
      return null;
    case InputOtpInteractionState.focused:
      return colors.surface.inverted.withOpacity(0.15);
    case InputOtpInteractionState.invalid:
      return colors.negative.border.withOpacity(0.15);
  }
}

/// The active box's own border darkens to match Input's focused treatment,
/// reusing the same "darkest surface" token so focus reads consistently
/// across every text-entry component in the package.
Color _resolveActiveBorderColor(
  SemanticColors colors,
  InputOtpInteractionState state,
) {
  return state == InputOtpInteractionState.invalid
      ? colors.negative.border
      : colors.surface.inverted;
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  InputOtpInteractionState state,
) {
  return state == InputOtpInteractionState.disabled
      ? colors.surface.alternative
      : colors.surface.base;
}

Color _resolveTextColor(SemanticColors colors, InputOtpInteractionState state) {
  return state == InputOtpInteractionState.disabled
      ? colors.content.placeholder
      : colors.content.primary;
}
