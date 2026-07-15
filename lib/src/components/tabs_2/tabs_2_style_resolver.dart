part of 'tabs_2.dart';

/// Resolves the container style for a [DsTabBar], per [DsTabsVariant].
RemixTabBarStyle resolveDsTabBarStyle(DsTabsVariant variant) {
  return switch (variant) {
    DsTabsVariant.underline => _underlineTabBarStyle(),
    DsTabsVariant.segmented => _segmentedTabBarStyle(),
  };
}

/// Draws one hairline under the whole bar so the tab row reads as a single
/// separated region before any tab is selected — the selected [DsTab]'s own
/// underline indicator (see [_underlineTabStyle]) then overlaps it visually.
RemixTabBarStyle _underlineTabBarStyle() {
  return RemixTabBarStyle().decoration(
    BoxDecorationMix(
      border: BorderMix.bottom(BorderSideMix(color: $borderDefault(), width: 1)),
    ),
  );
}

/// A gray, rounded container the selected [DsTab] renders its pill inside
/// of — the iOS `UISegmentedControl` shape. `$spacing004()` inset padding
/// leaves room for the pill (see [_segmentedTabStyle]) to sit fully inside
/// the container's own rounded corners without touching its edge.
RemixTabBarStyle _segmentedTabBarStyle() {
  return RemixTabBarStyle()
      .color($surfaceAlternative())
      .borderRadiusAll($radius008())
      .padding(EdgeInsetsMix.all($spacing004()));
}

/// Resolves the style for an individual [DsTab], per [DsTabsVariant].
RemixTabStyle resolveDsTabStyle({
  required DsTabsVariant variant,
  required DsTabsSize size,
  required bool disabled,
}) {
  final baseStyle = switch (variant) {
    DsTabsVariant.underline => _underlineTabStyle(),
    DsTabsVariant.segmented => _segmentedTabStyle(),
  };

  final sizeStyle = switch (size) {
    DsTabsSize.sm => RemixTabStyle()
        .label(TextStyler(style: $labelSm.mix()))
        .icon(IconStyler(size: 16))
        .padding(
          EdgeInsetsMix.symmetric(
            vertical: $spacing006(),
            horizontal: $spacing008(),
          ),
        ),
    DsTabsSize.md => RemixTabStyle()
        .label(TextStyler(style: $labelMd.mix()))
        .icon(IconStyler(size: 18))
        .padding(
          EdgeInsetsMix.symmetric(
            vertical: $spacing008(),
            horizontal: $spacing012(),
          ),
        ),
    DsTabsSize.lg => RemixTabStyle()
        .label(TextStyler(style: $labelLg.mix()))
        .icon(IconStyler(size: 20))
        .padding(
          EdgeInsetsMix.symmetric(
            vertical: $spacing010(),
            horizontal: $spacing016(),
          ),
        ),
  };

  final stateStyle = disabled
      ? RemixTabStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixTabStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}

/// The selected-tab indicator is a 2px bottom border applied as a widget
/// modifier (not a style property) — same "opacity/border modifier, not a
/// style property" split `resolveDsButtonStyle`'s pressed-feedback comment
/// documents — transparent by default and `$brandUi()` once selected, the
/// same underline pattern the installed `remix` package's own
/// `FortalTabsStyles.base()` uses, ported onto this design system's
/// semantic tokens instead of `FortalTokens`.
RemixTabStyle _underlineTabStyle() {
  const transparent = Color(0x00000000);

  return RemixTabStyle()
      .container(
        FlexBoxStyler()
            .direction(Axis.horizontal)
            .mainAxisAlignment(MainAxisAlignment.center)
            .crossAxisAlignment(CrossAxisAlignment.center)
            .spacing($spacing008()),
      )
      .label(TextStyler().color($contentSecondary()))
      .icon(IconStyler(color: $contentSecondary()))
      .wrap(
        WidgetModifierConfig.box(
          BoxStyler().borderBottom(color: transparent, width: 2),
        ),
      )
      .onHovered(
        RemixTabStyle()
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentPrimary())),
      )
      .onSelected(
        RemixTabStyle()
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentPrimary()))
            .wrap(
              WidgetModifierConfig.box(
                BoxStyler().borderBottom(color: $brandUi(), width: 2),
              ),
            ),
      );
}

/// The selected-tab indicator is a rounded, `$surfaceDefault()` pill behind
/// the label/icon — an iOS `UISegmentedControl`-style "thumb" sitting inside
/// the gray [_segmentedTabBarStyle] container. Unlike [_underlineTabStyle],
/// the indicator is a container decoration (`.color()`/`.borderRadius()`,
/// merged straight into the same `FlexBoxStyler` used for layout) rather
/// than a `.wrap(...)` modifier, since the pill needs to be inset by the
/// bar's own padding, not drawn as an edge-to-edge border.
RemixTabStyle _segmentedTabStyle() {
  const transparent = Color(0x00000000);

  return RemixTabStyle()
      .container(
        FlexBoxStyler()
            .direction(Axis.horizontal)
            .mainAxisAlignment(MainAxisAlignment.center)
            .crossAxisAlignment(CrossAxisAlignment.center)
            .spacing($spacing008()),
      )
      .color(transparent)
      .borderRadiusAll($radius004())
      .label(TextStyler().color($contentSecondary()))
      .icon(IconStyler(color: $contentSecondary()))
      .onHovered(
        RemixTabStyle()
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentPrimary())),
      )
      .onSelected(
        RemixTabStyle()
            .color($surfaceDefault())
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentPrimary())),
      );
}

/// Resolves the container style for a [DsTabView].
RemixTabViewStyle resolveDsTabViewStyle() {
  return RemixTabViewStyle().padding(EdgeInsetsMix.all($spacing016()));
}
