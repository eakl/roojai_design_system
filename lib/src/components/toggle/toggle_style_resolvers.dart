part of 'toggle.dart';

// Style resolvers for Toggle.
//
// One pure function per resolved *property* (background, foreground,
// border, radius, text style, padding, icon gap, icon extent) — same shape
// as Button's `_resolve*` split in `button_style_resolvers.dart`.
//
// Background and foreground both switch over the `pressed` (on/off) flag
// crossed with `ToggleInteractionState`, since a toggle's fill/text color
// depend on whether it's currently "on" as much as on tap/disabled state.
// Border only depends on `variant` and `state` — [ToggleVariant.standard]
// never draws one.

/// 8% black overlay used to darken an already-dark "on" background on tap,
/// mirroring Button's `_pressedOverlayBlack`. `pressed`'s "on" fill sits on
/// `colors.surface.inverted` — the darkest surface token available — so
/// there's no distinct "tapped" surface token to swap to; blending a fixed
/// overlay on top gives visible tap feedback instead.
const Color _tapOverlayBlack = Color(0x14000000);

Color _resolveBackgroundColor(
  SemanticColors colors,
  ToggleVariant variant,
  bool pressed,
  ToggleInteractionState state,
) {
  switch (state) {
    case ToggleInteractionState.disabled:
      // Muted fill only while "on" — an "off" disabled toggle stays
      // transparent, the same way an "off" enabled toggle does, so
      // disabling never invents a background that wasn't there before.
      return pressed
          ? colors.surface.alternative
          : colors.surface.alternative.withOpacity(0);
    case ToggleInteractionState.enabled:
      if (pressed) return colors.surface.inverted;
      // Transparent, but carrying the same RGB as the tapped color below
      // (alpha 0 instead of a plain Color(0x00000000)) — see
      // ButtonVariant.outline's identical comment in
      // button_style_resolvers.dart: keeps AnimatedContainer's color
      // lerp from flashing dark mid-fade.
      return colors.surface.alternative.withOpacity(0);
    case ToggleInteractionState.tapped:
      if (pressed) {
        return Color.alphaBlend(_tapOverlayBlack, colors.surface.inverted);
      }
      // Off + tapped: same hover/press feedback regardless of variant —
      // outline's border already carries its own visual distinction.
      return colors.surface.alternative;
  }
}

Color _resolveForegroundColor(
  SemanticColors colors,
  bool pressed,
  ToggleInteractionState state,
) {
  if (state == ToggleInteractionState.disabled) {
    return colors.content.placeholder;
  }
  return pressed ? colors.content.onBrand : colors.content.primary;
}

Color? _resolveBorderColor(
  SemanticColors colors,
  ToggleVariant variant,
  ToggleInteractionState state,
) {
  switch (variant) {
    case ToggleVariant.standard:
      return null;
    case ToggleVariant.outline:
      switch (state) {
        case ToggleInteractionState.enabled:
        case ToggleInteractionState.tapped:
          return colors.border.strong;
        case ToggleInteractionState.disabled:
          return colors.border.base;
      }
  }
}

/// Corner radius. Kept constant across [ToggleSize] today — still resolved
/// through a per-size switch (rather than a bare constant used directly in
/// `build()`) so it follows the same one-resolver-per-property shape as
/// every other property here, matching Button's `_resolveRadius`.
double _resolveRadius(ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
    case ToggleSize.md:
    case ToggleSize.lg:
      return AppRadius.radius8;
  }
}

TextStyle _resolveTextStyle(SemanticTypography typography, ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
      return typography.labelSm;
    case ToggleSize.md:
      return typography.labelMd;
    case ToggleSize.lg:
      return typography.labelLg;
  }
}

EdgeInsets _resolvePadding(ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      );
    case ToggleSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing8,
      );
    case ToggleSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing12,
      );
  }
}

double _resolveIconGap(ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
      return AppSpacing.spacing4;
    case ToggleSize.md:
    case ToggleSize.lg:
      return AppSpacing.spacing8;
  }
}

double _resolveIconExtent(ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
      return 14;
    case ToggleSize.md:
      return 16;
    case ToggleSize.lg:
      return 18;
  }
}
