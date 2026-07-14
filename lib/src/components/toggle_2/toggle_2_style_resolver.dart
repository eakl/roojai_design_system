part of 'toggle_2.dart';

// Style resolver for DsToggle.
//
// Single entry point `resolveDsToggleStyle` builds one `RemixToggleStyle` by
// merging fragments — size, then variant, then disabled state — mirroring
// the size/variant/state composition in `button_2_style_resolver.dart` and
// `switch_2_style_resolver.dart`. Sizing reuses Remix's own
// `FortalToggleStyles.base()` fragment (pure layout/metrics, no DS-specific
// color) rather than re-deriving padding/spacing/radius/icon-size/label-size
// per step from scratch.

/// Resolves the full `RemixToggleStyle` for a [DsToggle], given its
/// [variant], [size] and current [disabled] state.
///
/// Order of composition: size (via `FortalToggleStyles.base`), then variant
/// (colors), then interactive state (opacity). Later merges win on
/// overlapping properties, so `stateStyle` — applied last — always has
/// final say (disabled's dimming wins over whatever variant set, including
/// `FortalToggleStyles.base`'s own built-in `onDisabled` fragment).
RemixToggleStyle resolveDsToggleStyle({
  required DsToggleVariant variant,
  required DsToggleSize size,
  required bool disabled,
}) {
  final sizeStyle = switch (size) {
    DsToggleSize.sm => FortalToggleStyles.base(size: FortalToggleSize.size1),
    DsToggleSize.md => FortalToggleStyles.base(size: FortalToggleSize.size2),
    DsToggleSize.lg => FortalToggleStyles.base(size: FortalToggleSize.size3),
  };

  const transparent = Color(0x00000000);

  // Selected color reuses the same `$surfaceInverted`/`$contentOnBrand` pair
  // `DsButton.primary` and `DsSwitch`'s on-track color use, for visual
  // continuity across the migrated `_2` family.
  final variantStyle = switch (variant) {
    DsToggleVariant.ghost => RemixToggleStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand()),
        ),
    DsToggleVariant.outline => RemixToggleStyle()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1)
        .foregroundColor($contentPrimary())
        .onHovered(RemixToggleStyle().backgroundColor($surfaceAlternative()))
        .onSelected(
          RemixToggleStyle()
              .backgroundColor($surfaceInverted())
              .foregroundColor($contentOnBrand())
              .borderAll(color: $surfaceInverted()),
        ),
  };

  // Disabled wins over every other interactive/selected state — a disabled
  // toggle never shows brighter selected/hover feedback regardless of
  // `selected`, matching `resolveDsButtonStyle`/`resolveDsSwitchStyle`'s
  // equivalent comment. This also supersedes `FortalToggleStyles.base`'s own
  // built-in `onDisabled` fragment (a grayed background/foreground swap),
  // since `stateStyle` is merged in last.
  final stateStyle = disabled
      ? RemixToggleStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixToggleStyle();

  return sizeStyle.merge(variantStyle).merge(stateStyle);
}
