part of 'separator_2.dart';

RemixDividerStyle resolveDsSeparatorStyle({
  required DsSeparatorOrientation orientation,
}) {
  final base = RemixDividerStyle().color($borderDefault());

  return orientation == DsSeparatorOrientation.horizontal
      ? base.thickness(1)
      : base.constraints(BoxConstraintsMix(minWidth: 1, maxWidth: 1));
}
