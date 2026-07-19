part of 'list_item_2.dart';

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
    DsListSize.none => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing000(),
        vertical: $spacing000(),
      ),
    ),
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
    DsListSize.none => $bodySm.mix(),
    DsListSize.sm => $bodySm.mix(),
    DsListSize.md => $bodyMd.mix(),
    DsListSize.lg => $bodyLg.mix(),
  };
  final subtitleToken = switch (size) {
    DsListSize.none => $captionSm.mix(),
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
