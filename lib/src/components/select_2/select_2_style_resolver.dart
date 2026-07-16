part of 'select_2.dart';

// The `resolveDsSelectStyle`/`resolveDsSelectItemStyle` functions consumed by
// `build()` below live in this file, split out as `part of` this library
// (not a separate import) so they stay private to DsSelect while living in
// their own file — same split as `DsInput`'s `input_2_style_resolver.dart`.

/// Resolves the trigger + menu-container style for a [DsSelect].
///
/// There is no `resolveDsSelectItemStyle` fragment merged in here: the
/// installed `remix` version's `RemixSelectStyler` has no `.item()` default
/// per-row setter — `RemixSelectItem.style` is applied per item by the
/// widget itself, so [resolveDsSelectItemStyle] is a separate entry point
/// `DsSelect.build()` applies to each item directly. See
/// `docs/superpowers/specs/2026-07-15-select-2-component-design.md`.
RemixSelectStyler resolveDsSelectStyle({
  required DsSelectSize size,
  required bool error,
}) {
  final baseStyle = RemixSelectStyler()
      .trigger(
        RemixSelectTriggerStyler()
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
        RemixSelectStyler().trigger(
          RemixSelectTriggerStyler().borderAll(
            color: $surfaceInverted(),
            width: 1,
          ),
        ),
      )
      .onDisabled(
        RemixSelectStyler().trigger(
          RemixSelectTriggerStyler()
              .color($surfaceAlternative())
              .label(TextStyler().color($contentMuted()))
              .icon(IconStyler(color: $contentMuted())),
        ),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm => RemixSelectStyler().trigger(
      RemixSelectTriggerStyler()
          .label(TextStyler(style: $bodySm.mix()))
          .icon(IconStyler(size: 16))
          .paddingX($spacing012())
          .paddingY($spacing006()),
    ),
    DsSelectSize.md => RemixSelectStyler().trigger(
      RemixSelectTriggerStyler()
          .label(TextStyler(style: $bodyMd.mix()))
          .icon(IconStyler(size: 20))
          .paddingX($spacing012())
          .paddingY($spacing008()),
    ),
    DsSelectSize.lg => RemixSelectStyler().trigger(
      RemixSelectTriggerStyler()
          .label(TextStyler(style: $bodyLg.mix()))
          .icon(IconStyler(size: 24))
          .paddingX($spacing016())
          .paddingY($spacing012()),
    ),
  };

  // Mirrors `resolveDsInputStyle`'s `stateStyle`: `error` has no built-in
  // `.onError()` helper on `RemixSelectStyler` — a plain top-level merge
  // instead, driven by the same explicit `error` bool the widget takes as a
  // constructor param.
  final stateStyle = error
      ? RemixSelectStyler().trigger(
          RemixSelectTriggerStyler().borderAll(color: $negativeUi(), width: 1),
        )
      : RemixSelectStyler();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}

/// Resolves the per-row style applied to every [RemixSelectItem] in a
/// [DsSelect]'s menu, before each item's own (optional) `style` override is
/// merged on top by `DsSelect.build()`.
RemixSelectMenuItemStyler resolveDsSelectItemStyle({
  required DsSelectSize size,
}) {
  final baseStyle = RemixSelectMenuItemStyler()
      .borderRadiusAll($radius004())
      // Transparent (not null) until hovered, so a row never paints over
      // the menu container's own background — same "null/transparent
      // until interactive" precedent as the legacy `AppSelect`'s
      // `_SelectOptionRow.color`.
      .color(const Color(0x00000000))
      .text(TextStyler().color($contentPrimary()))
      .icon(IconStyler(color: $contentPrimary()))
      .onHovered(RemixSelectMenuItemStyler().color($surfaceAlternative()))
      .onDisabled(
        RemixSelectMenuItemStyler()
            .text(TextStyler().color($contentMuted()))
            .icon(IconStyler(color: $contentMuted())),
      );

  final sizeStyle = switch (size) {
    DsSelectSize.sm =>
      RemixSelectMenuItemStyler()
          .text(TextStyler(style: $bodySm.mix()))
          .icon(IconStyler(size: 16))
          .paddingX($spacing008())
          .paddingY($spacing006()),
    DsSelectSize.md =>
      RemixSelectMenuItemStyler()
          .text(TextStyler(style: $bodyMd.mix()))
          .icon(IconStyler(size: 20))
          .paddingX($spacing012())
          .paddingY($spacing008()),
    DsSelectSize.lg =>
      RemixSelectMenuItemStyler()
          .text(TextStyler(style: $bodyLg.mix()))
          .icon(IconStyler(size: 24))
          .paddingX($spacing012())
          .paddingY($spacing010()),
  };

  return baseStyle.merge(sizeStyle);
}
