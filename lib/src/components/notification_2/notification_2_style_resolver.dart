part of 'notification_2.dart';

// Resolver functions for DsNotification. Split into container/title/text/gap
// (rather than one composite style, the way `resolveDsCalloutStyle` returns
// a single `RemixCalloutStyler`) because there is no composite Remix spec
// backing this hand-rolled component — see the class doc comment in
// notification_2.dart for why this isn't built on RemixCallout.

BoxStyler resolveDsNotificationContainerStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing012()),
    ),
    DsNotificationSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing016()),
    ),
    DsNotificationSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing020()),
    ),
  };

  final variantStyle = switch (variant) {
    DsNotificationVariant.neutral => BoxStyler().color($neutralSurface()),
    DsNotificationVariant.brand => BoxStyler().color($brandSurface()),
    DsNotificationVariant.positive => BoxStyler().color($positiveSurface()),
    DsNotificationVariant.negative => BoxStyler().color($negativeSurface()),
    DsNotificationVariant.warning => BoxStyler().color($warningSurface()),
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(sizeStyle)
      .merge(variantStyle);
}

TextStyler resolveDsNotificationTitleStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $labelSm.mix()),
    DsNotificationSize.md => TextStyler(style: $labelMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $labelLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant));
}

TextStyler resolveDsNotificationTextStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $bodySm.mix()),
    DsNotificationSize.md => TextStyler(style: $bodyMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $bodyLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant));
}

/// Shared by [resolveDsNotificationTitleStyle] and
/// [resolveDsNotificationTextStyle] — both text slots use the same
/// variant-paired `*Text` foreground color, only their type size differs.
Color _resolveDsNotificationTextColor(DsNotificationVariant variant) {
  return switch (variant) {
    DsNotificationVariant.neutral => $neutralText(),
    DsNotificationVariant.brand => $brandText(),
    DsNotificationVariant.positive => $positiveText(),
    DsNotificationVariant.negative => $negativeText(),
    DsNotificationVariant.warning => $warningText(),
  };
}

/// Gap between leading/title/text/actions in the hand-rolled Row/Column
/// layout. Needs [context] (unlike the three resolvers above) because it
/// feeds a plain `SizedBox`/`Row.spacing`, not a `Styler`'s fluent chain —
/// same reasoning `toggle_group_2_style_resolver.dart`'s `_resolveGap`
/// documents.
double resolveDsNotificationGap(BuildContext context, DsNotificationSize size) {
  return switch (size) {
    DsNotificationSize.sm => $spacing002.resolve(context),
    DsNotificationSize.md => $spacing004.resolve(context),
    DsNotificationSize.lg => $spacing006.resolve(context),
  };
}
