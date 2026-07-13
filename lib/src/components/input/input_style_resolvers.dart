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

/// A thicker border on focus/invalid gives a stronger visual signal than
/// a color change alone.
double _resolveBorderWidth(InputInteractionState state) {
  switch (state) {
    case InputInteractionState.enabled:
    case InputInteractionState.disabled:
      return 1;
    case InputInteractionState.focused:
    case InputInteractionState.invalid:
      return 2;
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
