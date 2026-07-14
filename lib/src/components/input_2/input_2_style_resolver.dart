part of 'input_2.dart';

RemixTextFieldStyle resolveDsInputStyle({
  required DsInputSize size,
  required bool error,
}) {
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
      ? RemixTextFieldStyle().borderAll(color: $negativeUi(), width: 1) // SHould also be red when focused
      : RemixTextFieldStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
