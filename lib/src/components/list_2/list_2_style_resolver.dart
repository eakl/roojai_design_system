part of 'list_2.dart';

/// Resolves the outer container style for a [DsList].
///
/// `bordered: true` reuses `card_2`'s `bordered`-variant tokens
/// (`$radius008`/`$borderStrong`, transparent background) so a bordered
/// list reads consistently with a bordered card. `bordered: false` adds
/// no border/radius/background at all — the list sits flush in its
/// parent's surface.
BoxStyler resolveDsListStyle({
  required bool bordered,
  required DsListSize size,
}) {
  final sizeStyle = switch (size) {
    DsListSize.none => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing000()),
    ),
    DsListSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing012()),
    ),
    DsListSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing016()),
    ),
    DsListSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing020()),
    ),
  };

  final borderedStyle = bordered
      ? BoxStyler()
            .borderRadiusAll($radius008())
            .borderAll(color: $borderStrong(), width: 1)
      : BoxStyler();

  return sizeStyle.merge(borderedStyle);
}
