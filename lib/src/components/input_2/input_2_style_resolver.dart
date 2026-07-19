part of 'input_2.dart';

RemixTextFieldStyler resolveDsInputStyle({
  required DsInputSize size,
  required bool error,
}) {
  final baseStyle = RemixTextFieldStyler()
      .borderRadiusAll($radius008())
      .borderAll(color: $borderDefault(), width: 1)
      .backgroundColor($surfaceDefault())
      .color($contentPrimary())
      .hintColor($contentPlaceholder())
      .cursorColor($contentPrimary())
      .onFocused(
        RemixTextFieldStyler().borderAll(color: $surfaceInverted(), width: 1),
      )
      .onDisabled(
        RemixTextFieldStyler()
            .backgroundColor($surfaceAlternative())
            .color($contentMuted())
            .hintColor($contentMuted()),
      );

  final sizeStyle = switch (size) {
    DsInputSize.sm => RemixTextFieldStyler(
        text: TextStyler(style: $bodySm.mix()),
        hintText: TextStyler(style: $bodySm.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelSm.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing006())
        .spacing($spacing004()),
    DsInputSize.md => RemixTextFieldStyler(
        text: TextStyler(style: $bodyMd.mix()),
        hintText: TextStyler(style: $bodyMd.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing012())
        .paddingY($spacing008())
        .spacing($spacing004()),
    DsInputSize.lg => RemixTextFieldStyler(
        text: TextStyler(style: $bodyLg.mix()),
        hintText: TextStyler(style: $bodyLg.mix()),
        helperText: TextStyler(style: $captionMd.mix()),
        label: TextStyler(style: $labelMd.mix()),
      )
        .paddingX($spacing016())
        .paddingY($spacing012())
        .spacing($spacing006()),
  };

  // `error` has no built-in `.onError()` helper on `RemixTextFieldStyler`
  // (`WidgetStateVariantMixin` only ships hovered/pressed/focused/disabled/
  // enabled) — it's a plain top-level merge instead, driven by the same
  // explicit `error` bool the widget also forwards to
  // `RemixTextField.error` directly. See the design spec's "Style
  // resolver" section for the full rationale.
  final stateStyle = error
      ? RemixTextFieldStyler()
          .backgroundColor($negativeSurface())
          .borderAll(color: $negativeUi(), width: 1)
          .onFocused(
            RemixTextFieldStyler().borderAll(color: $negativeUi(), width: 1),
          )
      : RemixTextFieldStyler();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
