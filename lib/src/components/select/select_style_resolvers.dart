part of 'select.dart';

// Style resolvers for AppSelect.
//
// One pure function per resolved property (border color, ring color,
// background, text color, chevron color) rather than one function per
// state — same convention as Button/Input's `_style_resolvers.dart`
// files. The color-bearing resolvers switch over every
// [SelectInteractionState] value explicitly, so the analyzer enforces
// completeness whenever a state is added.

Color _resolveBorderColor(SemanticColors colors, SelectInteractionState state) {
  switch (state) {
    case SelectInteractionState.closed:
    case SelectInteractionState.disabled:
      return colors.border.base;
    case SelectInteractionState.open:
      // Reuses the same "darkest surface" token Input's focused border
      // sits on, so an open Select reads as a strong, unambiguous outline
      // without needing a dedicated "focus" color in the token set.
      return colors.surface.inverted;
    case SelectInteractionState.invalid:
      return colors.negative.border;
  }
}

/// A soft ring drawn *outside* the trigger's own border via `BoxShadow` —
/// null for states that don't need one. Mirrors `Input._resolveRingColor`:
/// `BoxShadow` doesn't participate in layout sizing, so this reinforces
/// open/invalid without ever shifting surrounding layout.
Color? _resolveRingColor(SemanticColors colors, SelectInteractionState state) {
  switch (state) {
    case SelectInteractionState.closed:
    case SelectInteractionState.disabled:
      return null;
    case SelectInteractionState.open:
      return colors.surface.inverted.withOpacity(0.15);
    case SelectInteractionState.invalid:
      return colors.negative.border.withOpacity(0.15);
  }
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  SelectInteractionState state,
) {
  return state == SelectInteractionState.disabled
      ? colors.surface.alternative
      : colors.surface.base;
}

/// The trigger's text reads muted/placeholder-colored both when disabled
/// and when nothing has been picked yet ([hasSelection] is false) — the
/// same "unset" treatment `Input`'s own placeholder text gets.
Color _resolveTextColor(
  SemanticColors colors,
  SelectInteractionState state,
  bool hasSelection,
) {
  if (state == SelectInteractionState.disabled) {
    return colors.content.placeholder;
  }
  return hasSelection ? colors.content.primary : colors.content.placeholder;
}

Color _resolveChevronColor(SemanticColors colors, SelectInteractionState state) {
  return state == SelectInteractionState.disabled
      ? colors.content.placeholder
      : colors.content.secondary;
}
