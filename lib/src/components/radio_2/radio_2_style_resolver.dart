part of 'radio_2.dart';

// Style resolver for DsRadio.
//
// Single entry point `resolveDsRadioStyle` builds one `RemixRadioStyler` by
// merging fragments — base, then size — mirroring
// `checkbox_2_style_resolver.dart`'s composition. Like `DsCheckbox`,
// `disabled` isn't a resolver parameter: `RemixRadioStyler` mixes in
// `SelectedWidgetStateVariantMixin`/`WidgetStateVariantMixin`, so it's
// expressed as an `.onDisabled()` state variant fragment instead —
// `RemixRadio` already threads its own `enabled` flag through to
// `NakedRadio`, which drives that variant's `context` condition.

/// Resolves the full `RemixRadioStyler` for a [DsRadio], given its [size].
///
/// Order of composition: base (border/dot colors, selected and disabled
/// state variants), then size (container/dot dimensions). Later merges win
/// on overlapping properties.
RemixRadioStyler resolveDsRadioStyle({required DsRadioSize size}) {
  final baseStyle = RemixRadioStyler()
      .borderRadiusAll($radiusFull())
      .alignment(Alignment.center)
      .fillColor($transparent())
      .borderAll(color: $borderStrong(), width: 1.5)
      .indicator(
        BoxStyler().color($surfaceInverted()).borderRadiusAll($radiusFull()),
      )
      .onSelected(
        RemixRadioStyler().borderAll(color: $surfaceInverted(), width: 1.5),
      )
      .onDisabled(
        RemixRadioStyler()
            .fillColor($surfaceAlternative())
            .borderAll(color: $borderDefault(), width: 1.5)
            .indicator(BoxStyler().color($contentMuted())),
      )
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // Container/dot dimensions per `size`. `RemixRadio` only paints
  // `spec.indicator` when the radio is the group's selected value (see
  // `radio_widget.dart`), so no explicit show/hide styling is needed here —
  // same "no glyph while unchecked" behavior `DsCheckbox` gets for free
  // from `RemixCheckbox`.
  final sizeStyle = switch (size) {
    DsRadioSize.sm => RemixRadioStyler(
        container: BoxStyler().width(16).height(16),
        indicator: BoxStyler().size(8, 8),
      ),
    DsRadioSize.md => RemixRadioStyler(
        container: BoxStyler().width(20).height(20),
        indicator: BoxStyler().size(10, 10),
      ),
    DsRadioSize.lg => RemixRadioStyler(
        container: BoxStyler().width(24).height(24),
        indicator: BoxStyler().size(12, 12),
      ),
  };

  return baseStyle.merge(sizeStyle);
}
