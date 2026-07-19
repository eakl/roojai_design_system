part of 'checkbox_2.dart';

// Style resolver for DsCheckbox.
//
// Single entry point `resolveDsCheckboxStyle` builds one
// `RemixCheckboxStyler` by merging fragments — base, then size — mirroring
// `switch_2_style_resolver.dart`'s composition. Unlike
// `resolveDsButtonStyle`/`resolveDsSwitchStyle`, `disabled` isn't a
// parameter here: [RemixCheckboxStyler] mixes in
// `SelectedWidgetStateVariantMixin` and its own `WidgetStateVariantMixin`
// (via `RemixContainerStyler`), so disabled dimming is expressed as an
// `.onDisabled()` state variant fragment instead of a resolver parameter —
// `RemixCheckbox` already threads its own `enabled` flag through to
// `NakedCheckbox`, which drives that variant's `context` condition.

/// Resolves the full `RemixCheckboxStyler` for a [DsCheckbox], given its
/// [size].
///
/// Order of composition: base (border/fill/glyph colors, selected and
/// disabled state variants), then size (box/icon dimensions). Later merges
/// win on overlapping properties.
RemixCheckboxStyler resolveDsCheckboxStyle({required DsCheckboxSize size}) {
  final baseStyle = RemixCheckboxStyler()
      .borderRadiusAll($radius004())
      .fillColor(const Color(0x00000000))
      .borderAll(color: $borderStrong(), width: 1.5)
      .indicatorColor($contentOnBrand())
      .onSelected(
        RemixCheckboxStyler()
            .fillColor($surfaceInverted())
            .borderAll(color: $surfaceInverted(), width: 1.5),
      )
      .onDisabled(
        RemixCheckboxStyler()
            .fillColor($surfaceAlternative())
            .borderAll(color: $borderDefault(), width: 1.5)
            .indicatorColor($contentMuted()),
      )
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // Box/icon dimensions per `size` — the checkmark/dash glyph is drawn
  // through `RemixCheckboxStyler.icon()` (an `IconStyler`), not a separate
  // "indicator box" like `DsRadio`'s dot, since `RemixCheckbox` renders its
  // glyph through a `StyledIcon`.
  final sizeStyle = switch (size) {
    DsCheckboxSize.sm =>
      RemixCheckboxStyler().size(16, 16).icon(IconStyler().size(10)),
    DsCheckboxSize.md =>
      RemixCheckboxStyler().size(20, 20).icon(IconStyler().size(14)),
    DsCheckboxSize.lg =>
      RemixCheckboxStyler().size(24, 24).icon(IconStyler().size(18)),
  };

  return baseStyle.merge(sizeStyle);
}
