part of 'notification_2.dart';

// Resolver functions for DsNotification. Split into container/title/text/gap
// (rather than one composite style, the way `resolveDsCalloutStyle` returns
// a single `RemixCalloutStyler`) because there is no composite Remix spec
// backing this hand-rolled component — see the class doc comment in
// notification_2.dart for why this isn't built on RemixCallout.

BoxStyler resolveDsNotificationContainerStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
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

  // `soft` tints with `*Surface` (today's only look); `solid` fills with the
  // saturated `*Ui` token — same soft/solid pairing `DsAvatarVariant`
  // already establishes, applied here to the container background instead
  // of an avatar's circle/square fill.
  final variantStyle = switch (tone) {
    DsNotificationTone.soft => switch (variant) {
      DsNotificationVariant.neutral => BoxStyler().color($neutralSurface()),
      DsNotificationVariant.brand => BoxStyler().color($brandSurface()),
      DsNotificationVariant.positive => BoxStyler().color($positiveSurface()),
      DsNotificationVariant.negative => BoxStyler().color($negativeSurface()),
      DsNotificationVariant.warning => BoxStyler().color($warningSurface()),
    },
    DsNotificationTone.solid => switch (variant) {
      DsNotificationVariant.neutral => BoxStyler().color($neutralUi()),
      DsNotificationVariant.brand => BoxStyler().color($brandUi()),
      DsNotificationVariant.positive => BoxStyler().color($positiveUi()),
      DsNotificationVariant.negative => BoxStyler().color($negativeUi()),
      DsNotificationVariant.warning => BoxStyler().color($warningUi()),
    },
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(sizeStyle)
      .merge(variantStyle);
}

TextStyler resolveDsNotificationTitleStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
  required DsNotificationSize size,
}) {
  return TextStyler(
    style: $headingH4.mix(),
  ).color(_resolveDsNotificationTextColor(variant, tone));
}

TextStyler resolveDsNotificationTextStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $bodySm.mix()),
    DsNotificationSize.md => TextStyler(style: $bodyMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $bodyLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant, tone));
}

/// Shared by [resolveDsNotificationTitleStyle] and
/// [resolveDsNotificationTextStyle] (and the leading icon color in
/// `notification_2.dart`'s `build()`) — all three use the same
/// variant/tone-paired foreground color, only type size differs between
/// title and text.
Color _resolveDsNotificationTextColor(
  DsNotificationVariant variant,
  DsNotificationTone tone,
) {
  return switch (tone) {
    DsNotificationTone.soft => switch (variant) {
      DsNotificationVariant.neutral => $neutralText(),
      DsNotificationVariant.brand => $brandText(),
      DsNotificationVariant.positive => $positiveText(),
      DsNotificationVariant.negative => $negativeText(),
      DsNotificationVariant.warning => $warningText(),
    },
    DsNotificationTone.solid => $contentOnBrand(),
  };
}

/// Gap between leading/title/text/actions in the hand-rolled Row/Column
/// layout. Needs [context] (unlike the resolvers above) because it feeds a
/// plain `SizedBox`/`Row.spacing`, not a `Styler`'s fluent chain — same
/// reasoning `toggle_group_2_style_resolver.dart`'s `_resolveGap` documents.
double resolveDsNotificationGap(BuildContext context, DsNotificationSize size) {
  return switch (size) {
    DsNotificationSize.sm => $spacing002.resolve(context),
    DsNotificationSize.md => $spacing004.resolve(context),
    DsNotificationSize.lg => $spacing006.resolve(context),
  };
}
