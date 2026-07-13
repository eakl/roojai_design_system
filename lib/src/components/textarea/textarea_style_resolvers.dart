part of 'textarea.dart';

// Style resolvers for Textarea.
//
// One pure function per resolved *property* (border color, ring color,
// background, text color, padding, radius) rather than one function per
// state — same convention as Button's `button_style_resolvers.dart` and
// Input's `input_style_resolvers.dart`. Values are chosen to match
// `Input` exactly (both widgets switch over the same shared
// [InputInteractionState]) so the two read as one family wherever they
// appear together in a form.

Color _resolveBorderColor(SemanticColors colors, InputInteractionState state) {
  switch (state) {
    case InputInteractionState.enabled:
    case InputInteractionState.disabled:
      return colors.border.base;
    case InputInteractionState.focused:
      // Reuses the same "darkest surface" token Input's focus border
      // reuses, so focus reads identically across both widgets.
      return colors.surface.inverted;
    case InputInteractionState.invalid:
      return colors.negative.border;
  }
}

/// A soft ring drawn *outside* the field's own border via `BoxShadow` —
/// null for states that don't need one. Identical treatment to
/// `Input._resolveRingColor`, including its rationale: a wider `Border`
/// is additive to the box's layout size, so it would shift surrounding
/// layout on every focus/invalid transition; a `BoxShadow` never does.
Color? _resolveRingColor(SemanticColors colors, InputInteractionState state) {
  switch (state) {
    case InputInteractionState.enabled:
    case InputInteractionState.disabled:
      return null;
    case InputInteractionState.focused:
      return colors.surface.inverted.withOpacity(0.15);
    case InputInteractionState.invalid:
      return colors.negative.border.withOpacity(0.15);
  }
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  InputInteractionState state,
) {
  return state == InputInteractionState.disabled
      ? colors.surface.alternative
      : colors.surface.base;
}

/// Color of the field's own typed text (not the placeholder, which always
/// uses `colors.content.placeholder` regardless of state). Disabled text
/// is muted to the placeholder color so it visually recedes — same choice
/// `InputGroupTextarea` makes for its disabled state.
Color _resolveTextColor(SemanticColors colors, InputInteractionState state) {
  return state == InputInteractionState.disabled
      ? colors.content.placeholder
      : colors.content.primary;
}

/// Kept as a resolver function (rather than a bare constant used directly
/// in `build()`) so it follows the same one-resolver-per-property shape
/// as every other property here, and so a future size-specific padding is
/// a one-line change instead of restructuring `build()` — same rationale
/// as Input's `_resolvePadding`. Matches `Input`'s `InputSize.md` padding
/// exactly, since Textarea has no size variants of its own.
EdgeInsets _resolvePadding() {
  return const EdgeInsets.symmetric(
    horizontal: AppSpacing.spacing12,
    vertical: AppSpacing.spacing8,
  );
}

/// Corner radius. Matches `Input`'s radius, which is likewise constant
/// across all of its sizes — see the rationale on `Input._resolveRadius`.
double _resolveRadius() => AppRadius.radius8;
