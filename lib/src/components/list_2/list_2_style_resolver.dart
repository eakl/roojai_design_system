part of 'list_2.dart';

/// Resolves the row style for a [DsListItem].
///
/// `container` carries padding (by [size]) plus, when [interactive],
/// `.onHovered()`/`.onPressed()` background variants — the exact
/// declarative state-styling idiom `button_2_style_resolver.dart` already
/// uses for `RemixButtonStyler`, applied here to a plain `BoxStyler`
/// instead (Mix's `WidgetStateVariantMixin` is available on any
/// `MixStyler`, not just Remix-generated ones). `title`/`subtitle` are
/// `TextStyler`s dimmed to `$contentPlaceholder()` when [disabled], same
/// treatment `label_2_style_resolver.dart` applies for its own `disabled`
/// state.
({BoxStyler container, TextStyler title, TextStyler subtitle})
resolveDsListItemStyle({
  required DsListSize size,
  required bool disabled,
  required bool interactive,
}) {
  final paddingStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing012(),
        vertical: $spacing008(),
      ),
    ),
    DsListSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing016(),
        vertical: $spacing012(),
      ),
    ),
    DsListSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing020(),
        vertical: $spacing016(),
      ),
    ),
  };

  final interactiveStyle = interactive
      ? BoxStyler()
            .onHovered(BoxStyler().color($neutralUiHover()))
            .onPressed(BoxStyler().color($neutralUiHover()))
      : BoxStyler();

  final titleToken = switch (size) {
    DsListSize.sm => $bodySm.mix(),
    DsListSize.md => $bodyMd.mix(),
    DsListSize.lg => $bodyLg.mix(),
  };
  final subtitleToken = switch (size) {
    DsListSize.sm => $captionSm.mix(),
    DsListSize.md => $captionMd.mix(),
    // No $captionLg token exists — cap subtitle scale at $captionMd.
    DsListSize.lg => $captionMd.mix(),
  };

  final titleColor = disabled ? $contentPlaceholder() : $contentPrimary();
  final subtitleColor = disabled
      ? $contentPlaceholder()
      : $contentSecondary();

  return (
    container: paddingStyle.merge(interactiveStyle),
    title: TextStyler().style(titleToken).color(titleColor),
    subtitle: TextStyler().style(subtitleToken).color(subtitleColor),
  );
}

/// Resolves the outer container style for a [DsList].
///
/// `bordered: true` reuses `card_2`'s `bordered`-variant tokens
/// (`$radius008`/`$borderStrong`, transparent background) so a bordered
/// list reads consistently with a bordered card. `bordered: false` adds
/// no border/radius/background at all — the list sits flush in its
/// parent's surface.
BoxStyler resolveDsListStyle({
  required bool bordered,
  required DsListSize size,
}) {
  final sizeStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing012()),
    ),
    DsListSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing016()),
    ),
    DsListSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing020()),
    ),
  };

  final borderedStyle = bordered
      ? BoxStyler()
            .borderRadiusAll($radius008())
            .borderAll(color: $borderStrong(), width: 1)
      : BoxStyler();

  return sizeStyle.merge(borderedStyle);
}
