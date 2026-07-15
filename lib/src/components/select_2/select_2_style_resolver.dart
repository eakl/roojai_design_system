part of 'select_2.dart';

// The `resolveDsSelectStyle`/`resolveDsSelectItemStyle` functions consumed by
// `build()` below live in this file, split out as `part of` this library
// (not a separate import) so they stay private to DsSelect while living in
// their own file — same split as `DsInput`'s `input_2_style_resolver.dart`.

/// Resolves the trigger + menu-container style for a [DsSelect].
///
/// There is no `resolveDsSelectItemStyle` fragment merged in here: the
/// installed `remix` version's `RemixSelectStyle` has no `.item()` default
/// per-row setter (unlike the newer "Styler"-suffixed API on
/// docs.page/btwld/remix) — `RemixSelectItem.style` is applied per item by
/// the widget itself, so [resolveDsSelectItemStyle] is a separate entry
/// point `DsSelect.build()` applies to each item directly. See
/// `docs/superpowers/specs/2026-07-15-select-2-component-design.md`.
RemixSelectStyle resolveDsSelectStyle({
  required DsSelectSize size,
  required bool error,
}) {
  final baseStyle = RemixSelectStyle()
      .trigger(
        RemixSelectTriggerStyle()
            .borderRadiusAll($radius008())
            .borderAll(color: $borderDefault(), width: 1)
            .color($surfaceDefault())
            .label(TextStyler().color($contentPrimary()))
            .icon(IconStyler(color: $contentSecondary())),
      )
      .menuContainer(
        FlexBoxStyler()
            .color($surfaceDefault())
            .borderAll(color: $borderDefault(), width: 1)
            .borderRadiusAll($radius008())
            .paddingAll($spacing004())
            .marginTop($spacing004()),
      )
      .onFocused(
        RemixSelectStyle().trigger(
          RemixSelectTriggerStyle().borderAll(
            color: $surfaceInverted(),
            width: 1,
          ),
        ),
      )
      .onDisabled(
        RemixSelectStyle().trigger(
          RemixSelectTriggerStyle()
              .color($surfaceAlternative())
              .label(TextStyler().color($contentMuted()))
              .icon(IconStyler(color: $contentMuted())),
        ),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm => RemixSelectStyle().trigger(
      RemixSelectTriggerStyle()
          .label(TextStyler(style: $bodySm.mix()))
          .icon(IconStyler(size: 16))
          .paddingX($spacing012())
          .paddingY($spacing006()),
    ),
    DsSelectSize.md => RemixSelectStyle().trigger(
      RemixSelectTriggerStyle()
          .label(TextStyler(style: $bodyMd.mix()))
          .icon(IconStyler(size: 20))
          .paddingX($spacing012())
          .paddingY($spacing008()),
    ),
    DsSelectSize.lg => RemixSelectStyle().trigger(
      RemixSelectTriggerStyle()
          .label(TextStyler(style: $bodyLg.mix()))
          .icon(IconStyler(size: 24))
          .paddingX($spacing016())
          .paddingY($spacing012()),
    ),
  };

  // Mirrors `resolveDsInputStyle`'s `stateStyle`: `error` has no built-in
  // `.onError()` helper on `RemixSelectStyle` — a plain top-level merge
  // instead, driven by the same explicit `error` bool the widget takes as a
  // constructor param.
  final stateStyle = error
      ? RemixSelectStyle().trigger(
          RemixSelectTriggerStyle().borderAll(color: $negativeUi(), width: 1),
        )
      : RemixSelectStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}

/// Resolves the per-row style applied to every [RemixSelectItem] in a
/// [DsSelect]'s menu, before each item's own (optional) `style` override is
/// merged on top by `DsSelect.build()`.
RemixSelectMenuItemStyle resolveDsSelectItemStyle({
  required DsSelectSize size,
}) {
  final baseStyle = RemixSelectMenuItemStyle()
      .borderRadiusAll($radius004())
      // Transparent (not null) until hovered, so a row never paints over
      // the menu container's own background — same "null/transparent
      // until interactive" precedent as the legacy `AppSelect`'s
      // `_SelectOptionRow.color`.
      .color(const Color(0x00000000))
      .text(TextStyler().color($contentPrimary()))
      .icon(IconStyler(color: $contentPrimary()))
      .onHovered(RemixSelectMenuItemStyle().color($surfaceAlternative()))
      .onDisabled(
        RemixSelectMenuItemStyle()
            .text(TextStyler().color($contentMuted()))
            .icon(IconStyler(color: $contentMuted())),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm =>
      RemixSelectMenuItemStyle()
          .text(TextStyler(style: $bodySm.mix()))
          .icon(IconStyler(size: 16))
          .paddingX($spacing008())
          .paddingY($spacing006()),
    DsSelectSize.md =>
      RemixSelectMenuItemStyle()
          .text(TextStyler(style: $bodyMd.mix()))
          .icon(IconStyler(size: 20))
          .paddingX($spacing012())
          .paddingY($spacing008()),
    DsSelectSize.lg =>
      RemixSelectMenuItemStyle()
          .text(TextStyler(style: $bodyLg.mix()))
          .icon(IconStyler(size: 24))
          .paddingX($spacing012())
          .paddingY($spacing010()),
  };

  return baseStyle.merge(sizeStyle);
}
