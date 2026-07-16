part of 'popover_2.dart';

final _popoverShadow = BoxShadowMix(
  color: const Color(0x1A000000),
  offset: const Offset(0, 2),
  blurRadius: 6,
);

BoxStyler resolveDsPopoverStyle() {
  return BoxStyler()
      .decoration(
        BoxDecorationMix(
          color: $surfaceDefault(),
          borderRadius: BorderRadiusGeometryMix.all($radius008()),
          boxShadow: [_popoverShadow],
        ),
      )
      .padding(EdgeInsetsGeometryMix.all($spacing012()))
      .constraints(BoxConstraintsMix(maxWidth: 320));
}
