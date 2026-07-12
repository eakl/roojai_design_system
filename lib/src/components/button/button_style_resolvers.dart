part of 'button.dart';

// Style resolvers for Button.
//
// One pure function per resolved *property* (background, foreground,
// border, radius, text style, padding, icon gap, icon extent) rather than
// one function per variant or per size. A per-property split is what the
// package's Global Constraints call for, and it also reads better here:
// most properties only vary along a single axis (radius/padding/text by
// size; background/foreground/border by variant + state), so a
// per-variant or per-size split would force every function to needlessly
// repeat the same switch, or to accept axes it doesn't use.
//
// The two color-bearing resolvers (background, border) switch over every
// ButtonVariant x ButtonInteractionState pair explicitly via nested
// exhaustive switches — no fallback ranges — so a reader sees the full
// matrix at a glance and the analyzer enforces completeness whenever a
// variant or state is added.

/// 8% black overlay used to darken an already-dark background on press.
///
/// Solid variants (primary) sit on `colors.surface.inverted`, which is
/// already the darkest surface token available — there's no distinct
/// "pressed" surface token to swap to the way `secondary` swaps to
/// `colors.surface.alternative`. Blending a fixed overlay on top of
/// whatever the base color resolves to gives visible press feedback
/// without depending on two semantic tokens happening to differ.
const Color _pressedOverlayBlack = Color(0x14000000);

Color _resolveBackgroundColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonInteractionState state,
) {
  switch (variant) {
    case ButtonVariant.primary:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.loading:
          return colors.surface.inverted;
        case ButtonInteractionState.pressed:
          return Color.alphaBlend(_pressedOverlayBlack, colors.surface.inverted);
        case ButtonInteractionState.disabled:
          return colors.surface.alternative;
      }
    case ButtonVariant.secondary:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.loading:
          // `surface.base` is the same color as `canvas.base` in the
          // default theme, so it reads as "no background" — the same as
          // `outline`/`ghost`'s transparent resting state. `alternative`
          // gives secondary a visibly filled background at rest, the way
          // a filled (non-outline, non-ghost) variant should look.
          return colors.surface.alternative;
        case ButtonInteractionState.pressed:
          // No third, darker surface token exists beyond `alternative`,
          // so darken it the same way `primary` darkens its own
          // already-darkest surface token: blend a fixed black overlay
          // on top rather than depending on a token pair that doesn't
          // exist for this case.
          return Color.alphaBlend(_pressedOverlayBlack, colors.surface.alternative);
        case ButtonInteractionState.disabled:
          // `canvas.alternative` is a lighter tint than `surface.alternative`
          // (the enabled fill above) — using it here keeps disabled visibly
          // washed-out instead of matching the enabled background exactly.
          return colors.canvas.alternative;
      }
    case ButtonVariant.outline:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.loading:
        case ButtonInteractionState.disabled:
          // Transparent, but carrying the *same* RGB as the pressed color
          // below (alpha 0 instead of a plain Color(0x00000000)). Without
          // this, AnimatedContainer's Color.lerp interpolates RGB from
          // black towards surface.alternative while alpha fades in,
          // producing a visible dark flash mid-animation instead of a
          // clean fade. Matching the RGB channels means only alpha
          // animates.
          return colors.surface.alternative.withOpacity(0);
        case ButtonInteractionState.pressed:
          return colors.surface.alternative;
      }
    case ButtonVariant.ghost:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.loading:
        case ButtonInteractionState.disabled:
          // Same rationale as ButtonVariant.outline above.
          return colors.surface.alternative.withOpacity(0);
        case ButtonInteractionState.pressed:
          return colors.surface.alternative;
      }
    case ButtonVariant.destructive:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.loading:
          return colors.negative.ui;
        case ButtonInteractionState.pressed:
          // negative.ui -> negative.uiHover are already distinct tokens
          // (unlike primary's surface.inverted), so no overlay is needed.
          return colors.negative.uiHover;
        case ButtonInteractionState.disabled:
          return colors.surface.alternative;
      }
  }
}

Color _resolveForegroundColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonInteractionState state,
) {
  if (state == ButtonInteractionState.disabled) {
    return colors.content.placeholder;
  }
  switch (variant) {
    case ButtonVariant.primary:
      return colors.content.onBrand;
    case ButtonVariant.secondary:
      return colors.content.primary;
    case ButtonVariant.outline:
      return colors.content.primary;
    case ButtonVariant.ghost:
      return colors.content.primary;
    case ButtonVariant.destructive:
      return colors.content.onBrand;
  }
}

Color? _resolveBorderColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonInteractionState state,
) {
  switch (variant) {
    case ButtonVariant.primary:
    case ButtonVariant.secondary:
    case ButtonVariant.ghost:
    case ButtonVariant.destructive:
      return null;
    case ButtonVariant.outline:
      switch (state) {
        case ButtonInteractionState.enabled:
        case ButtonInteractionState.pressed:
        case ButtonInteractionState.loading:
          return colors.border.strong;
        case ButtonInteractionState.disabled:
          return colors.border.base;
      }
  }
}

/// Corner radius. Kept constant across [ButtonSize] today — still
/// resolved through a per-size switch (rather than a bare constant used
/// directly in `build()`) so it follows the same one-resolver-per-property
/// shape as every other property here, and so a future size-specific
/// radius is a one-line change instead of a new function.
double _resolveRadius(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
    case ButtonSize.md:
    case ButtonSize.lg:
      return AppRadius.radius8;
  }
}

TextStyle _resolveTextStyle(SemanticTypography typography, ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return typography.labelSm;
    case ButtonSize.md:
      return typography.labelMd;
    case ButtonSize.lg:
      return typography.labelLg;
  }
}

EdgeInsets _resolvePadding(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      );
    case ButtonSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing8,
      );
    case ButtonSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing12,
      );
  }
}

double _resolveIconGap(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return AppSpacing.spacing4;
    case ButtonSize.md:
    case ButtonSize.lg:
      return AppSpacing.spacing8;
  }
}

double _resolveIconExtent(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return 14;
    case ButtonSize.md:
      return 16;
    case ButtonSize.lg:
      return 18;
  }
}
