part of 'dialog_2.dart';

// AppElevation.level3's concrete shadow, inlined as a literal — Mix's
// BoxDecorationMix.boxShadow (and RemixDialogStyle.shadow, which delegates
// to it) only accepts `List<BoxShadowMix>`/`BoxShadowMix`, with no way to
// feed in a `BoxShadowToken` (`MixToken<List<BoxShadow>>`) token reference
// directly. Same class of limitation button_2's resolver hit with
// Curve/Duration token refs — falls back to a literal matching
// `AppElevation.level3` (lib/src/tokens/primitives/elevation.dart) until
// Mix supports resolving this token type outside of a theme lookup.
final _dialogShadow = BoxShadowMix(
  color: const Color(0x1F000000),
  offset: const Offset(0, 4),
  blurRadius: 12,
);

RemixDialogStyle resolveDsDialogStyle() {
  return RemixDialogStyle(
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
