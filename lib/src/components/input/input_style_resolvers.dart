part of 'input.dart';

// Style resolvers for Input.
//
// One pure function per resolved *property* (border color, border width,
// background, icon color, text style, padding, radius, icon extent,
// keyboard type, obscure text) rather than one function per variant/size/
// type — same convention as Button's `button_style_resolvers.dart`.

Color _resolveBorderColor(SemanticColors colors, InputInteractionState state) {
  switch (state) {
    case InputInteractionState.enabled:
    case InputInteractionState.disabled:
      return colors.border.base;
    case InputInteractionState.focused:
      // Reuses the same "darkest surface" token Button's primary variant
      // sits on, so focus reads as a strong, unambiguous outline without
      // needing a dedicated "focus" color in the token set.
      return colors.surface.inverted;
    case InputInteractionState.invalid:
      return colors.negative.border;
  }
}

/// Kept constant across every [InputInteractionState] — still resolved
/// through a per-state switch (rather than a bare constant) so it follows
/// the same one-resolver-per-property shape as every other property here.
///
/// This used to return `2` for focused/invalid to make those states read
/// more strongly. That grew the field by 2px in both directions on every
/// focus/invalid transition, because `Container`'s `decoration` border is
/// *additive* to its box size (border width adds outside the padding) —
/// a visible layout shift. Focus/invalid now signal via [_resolveRingColor]
/// instead, a `BoxShadow` painted outside the box bounds, which (like
/// CSS's `box-shadow`/`ring`) never affects layout.
double _resolveBorderWidth(InputInteractionState state) {
  switch (state) {
    case InputInteractionState.enabled:
    case InputInteractionState.disabled:
    case InputInteractionState.focused:
    case InputInteractionState.invalid:
      return 1;
  }
}

/// A soft ring drawn *outside* the field's own border via `BoxShadow` —
/// null for states that don't need one. `BoxShadow` doesn't participate
/// in layout sizing (unlike a wider `Border`), so this reinforces
/// focused/invalid without ever shifting surrounding layout. Mirrors
/// shadcn's `ring`/`ring-offset` focus treatment.
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

/// Color of the file-variant's icon (either the caller-supplied
/// [Input.icon] or the default [_UploadIcon]).
Color _resolveIconColor(SemanticColors colors, InputInteractionState state) {
  return state == InputInteractionState.disabled
      ? colors.content.placeholder
      : colors.content.secondary;
}

TextStyle _resolveTextStyle(SemanticTypography typography, InputSize size) {
  switch (size) {
    case InputSize.sm:
      return typography.bodySm;
    case InputSize.md:
      return typography.bodyMd;
    case InputSize.lg:
      return typography.bodyLg;
  }
}

EdgeInsets _resolvePadding(InputSize size) {
  switch (size) {
    case InputSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      );
    case InputSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      );
    case InputSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      );
  }
}

/// Corner radius. Kept constant across [InputSize] today — still resolved
/// through a per-size switch (rather than a bare constant used directly
/// in `build()`) so it follows the same one-resolver-per-property shape
/// as every other property here, and so a future size-specific radius is
/// a one-line change instead of a new function. Same rationale as
/// Button's `_resolveRadius`.
double _resolveRadius(InputSize size) {
  switch (size) {
    case InputSize.sm:
    case InputSize.md:
    case InputSize.lg:
      return AppRadius.radius8;
  }
}

double _resolveIconExtent(InputSize size) {
  switch (size) {
    case InputSize.sm:
      return 20;
    case InputSize.md:
      return 24;
    case InputSize.lg:
      return 28;
  }
}

/// Keyboard layout for [InputVariant.text]. Not called for
/// [InputVariant.file], which renders no `TextField`.
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

/// Keystroke-level restriction for [InputVariant.text]. `keyboardType`
/// alone (see [_resolveKeyboardType]) only *suggests* which soft keyboard
/// layout to show — it never restricts what a user can actually type,
/// including on desktop/web where there's no soft keyboard to swap at
/// all. [InputType.number]/[InputType.phone] need an explicit
/// `TextInputFormatter` to actually reject non-matching characters.
List<TextInputFormatter>? _resolveInputFormatters(InputType type) {
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
