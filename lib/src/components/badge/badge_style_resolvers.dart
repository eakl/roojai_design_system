part of 'badge.dart';

// Style resolvers for Badge.
//
// One pure function per resolved *property* (background, foreground,
// border, text style, padding, icon gap, icon extent), same split as
// Button's resolvers — see button_style_resolvers.dart for the rationale.
//
// Unlike Button, there is no ButtonInteractionState axis here: Badge is
// always non-interactive, so each color resolver switches over
// BadgeVariant alone rather than a variant x state matrix.

Color _resolveBackgroundColor(SemanticColors colors, BadgeVariant variant) {
  switch (variant) {
    case BadgeVariant.primary:
      return colors.surface.inverted;
    case BadgeVariant.secondary:
      return colors.surface.alternative;
    case BadgeVariant.outline:
    case BadgeVariant.ghost:
      // Transparent — outline relies on its border for definition, ghost
      // has neither fill nor border.
      return const Color(0x00000000);
    case BadgeVariant.destructive:
      return colors.negative.surface;
  }
}

Color _resolveForegroundColor(SemanticColors colors, BadgeVariant variant) {
  switch (variant) {
    case BadgeVariant.primary:
      return colors.content.onBrand;
    case BadgeVariant.secondary:
    case BadgeVariant.outline:
    case BadgeVariant.ghost:
      return colors.content.primary;
    case BadgeVariant.destructive:
      return colors.negative.textStrong;
  }
}

Color? _resolveBorderColor(SemanticColors colors, BadgeVariant variant) {
  switch (variant) {
    case BadgeVariant.primary:
    case BadgeVariant.secondary:
    case BadgeVariant.ghost:
      return null;
    case BadgeVariant.outline:
      return colors.border.strong;
    case BadgeVariant.destructive:
      return null;
  }
}

TextStyle _resolveTextStyle(SemanticTypography typography, BadgeSize size) {
  switch (size) {
    case BadgeSize.sm:
      return typography.captionSm;
    case BadgeSize.md:
      return typography.captionMd;
    case BadgeSize.lg:
      return typography.labelSm;
  }
}

EdgeInsets _resolvePadding(BadgeSize size) {
  switch (size) {
    case BadgeSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing2,
      );
    case BadgeSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing4,
      );
    case BadgeSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing6,
      );
  }
}

double _resolveIconGap(BadgeSize size) {
  switch (size) {
    case BadgeSize.sm:
    case BadgeSize.md:
      return AppSpacing.spacing4;
    case BadgeSize.lg:
      return AppSpacing.spacing6;
  }
}

double _resolveIconExtent(BadgeSize size) {
  switch (size) {
    case BadgeSize.sm:
      return 10;
    case BadgeSize.md:
      return 12;
    case BadgeSize.lg:
      return 14;
  }
}
