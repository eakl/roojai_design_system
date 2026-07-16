part of 'dialog_2.dart';

final _dialogShadow = BoxShadowMix(
  color: const Color(0x1F000000),
  offset: const Offset(0, 4),
  blurRadius: 12,
);

RemixDialogStyler resolveDsDialogStyle() {
  return RemixDialogStyler(
    title: TextStyler(style: $labelLg.mix()).color($contentPrimary()),
    description: TextStyler(
      style: $bodyMd.mix(),
    ).color($contentSecondary()),
    actions: FlexBoxStyler()
        .direction(Axis.horizontal)
        .mainAxisAlignment(MainAxisAlignment.end)
        .spacing($spacing008())
        .padding(EdgeInsetsGeometryMix.only(top: $spacing016())),
  )
      .borderRadiusAll($radius008())
      .backgroundColor($surfaceDefault())
      .padding(EdgeInsetsGeometryMix.all($spacing020()))
      .shadow(_dialogShadow);
}
