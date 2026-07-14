part of 'input_2.dart';

// Style resolver for DsInput.
//
// Single entry point `resolveDsInputStyle` builds one `RemixTextFieldStyle`
// by merging fragments — base, then size, then error state — mirroring the
// base/size/variant/state composition in `button_2_style_resolver.dart`
// (minus the variant fragment: DsInput has no visual-skin axis, see the
// design spec's "Variant axis" decision).

/// Resolves the full `RemixTextFieldStyle` for a [DsInput], given its
/// [size] and current [error] state.
///
/// Order of composition: base metrics/colors/focus-disabled states, then
/// size (padding/typography), then error. Later merges win on overlapping
/// properties, so `stateStyle` — applied last — always has final say (e.g.
/// an errored field's red border wins over the size fragment, which sets
/// no border color of its own).
RemixTextFieldStyle resolveDsInputStyle({
  required DsInputSize size,
  required bool error,
}) {
  // Focus/disabled use Remix's own `.onFocused()`/`.onDisabled()`
  // widget-state variant helpers (from `WidgetStateVariantMixin`, mixed
  // into `RemixTextFieldStyle` via `RemixFlexContainerStyle`) — Naked's
  // `NakedTextFieldState` already derives these live, so (unlike the
  // legacy `Input`) this widget never needs to track a `FocusNode`
  // listener itself.
  final baseStyle = RemixTextFieldStyle()
      .borderRadiusAll($radius008())
      .borderAll(color: $borderDefault(), width: 1)
      .backgroundColor($surfaceDefault())
      .color($contentPrimary())
      .hintColor($contentPlaceholder())
      .cursorColor($surfaceInverted())
      .onFocused(
        RemixTextFieldStyle().borderAll(color: $surfaceInverted(), width: 1),
      )
      .onDisabled(
        RemixTextFieldStyle()
            .backgroundColor($surfaceAlternative())
            .color($contentMuted())
            .hintColor($contentMuted()),
      );

  final sizeStyle = switch (size) {
    DsInputSize.sm => RemixTextFieldStyle(
        text: TextStyler(style: $bodySm.mix()),
        hintText: TextStyler(style: $bodySm.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelSm.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing006())
        .spacing($spacing004()),
    DsInputSize.md => RemixTextFieldStyle(
        text: TextStyler(style: $bodyMd.mix()),
        hintText: TextStyler(style: $bodyMd.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing008())
        .spacing($spacing004()),
    DsInputSize.lg => RemixTextFieldStyle(
        text: TextStyler(style: $bodyLg.mix()),
        hintText: TextStyler(style: $bodyLg.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing016())
        .paddingY($spacing012())
        .spacing($spacing006()),
  };

  // `error` has no built-in `.onError()` helper on `RemixTextFieldStyle`
  // (`WidgetStateVariantMixin` only ships hovered/pressed/focused/disabled/
  // enabled) — it's a plain top-level merge instead, driven by the same
  // explicit `error` bool the widget also forwards to
  // `RemixTextField.error` directly. See the design spec's "Style
  // resolver" section for the full rationale.
  final stateStyle = error
      ? RemixTextFieldStyle().borderAll(color: $negativeBorder(), width: 1)
      : RemixTextFieldStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
