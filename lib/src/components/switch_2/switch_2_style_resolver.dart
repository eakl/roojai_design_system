part of 'switch_2.dart';

// Style resolver for DsSwitch.
//
// Single entry point `resolveDsSwitchStyle` builds one `RemixSwitchStyle` by
// merging fragments — base, then size, then disabled state — mirroring the
// base/size/variant/state composition in `button_2_style_resolver.dart`
// (minus the variant fragment: DsSwitch has no visual-skin axis, same
// decision `input_2` made — see the design spec's "Variant axis" section).

/// Resolves the full `RemixSwitchStyle` for a [DsSwitch], given its [size]
/// and current [disabled] state.
///
/// Order of composition: base track/thumb colors and on-selected color,
/// then size (track/thumb dimensions), then disabled. Later merges win on
/// overlapping properties, so `stateStyle` — applied last — always has
/// final say (disabled's dimming wins over whatever size/base set,
/// mirroring `resolveDsButtonStyle`'s "disabled always wins" comment).
RemixSwitchStyle resolveDsSwitchStyle({
  required DsSwitchSize size,
  required bool disabled,
}) {
  // Neither `Curve` nor arithmetic on a `Duration` token reference is
  // supported by Mix's inline token-ref mechanism (see
  // `resolveDsButtonStyle`'s identical comment in
  // `button_2_style_resolver.dart`), so the 100ms `Curves.easeInOut`
  // transition is a literal here too, matching the legacy `AppSwitch`'s
  // `AppMotion.durationFast`/`AppMotion.curveStandard` transition.
  final baseStyle = RemixSwitchStyle()
      .trackColor($borderStrong())
      .thumbColor($surfaceDefault())
      .borderRadiusAll($radiusFull())
      .thumb(BoxStyler().borderRadiusAll($radiusFull()))
      .onSelected(RemixSwitchStyle().trackColor($surfaceInverted()))
      .animate(
        AnimationConfig.curve(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
        ),
      );

  // `RemixSwitch._buildStyle()` already sets `alignment(.centerLeft)` /
  // `.onSelected(alignment(.centerRight))` internally to slide the thumb —
  // this resolver only needs to size the track/thumb boxes and inset the
  // thumb via container padding (mirrors legacy `AppSwitch`'s
  // `thumbInset`), not touch alignment itself.
  final sizeStyle = switch (size) {
    DsSwitchSize.sm => RemixSwitchStyle(
        container: BoxStyler()
            .width(32)
            .height(18)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(14, 14),
      ),
    DsSwitchSize.md => RemixSwitchStyle(
        container: BoxStyler()
            .width(40)
            .height(24)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(20, 20),
      ),
    DsSwitchSize.lg => RemixSwitchStyle(
        container: BoxStyler()
            .width(48)
            .height(28)
            .padding(EdgeInsetsGeometryMix.all(2)),
        thumb: BoxStyler().size(24, 24),
      ),
  };

  // Disabled wins over every other interactive/selected state — a disabled
  // switch never shows brighter selected/hover feedback regardless of
  // `selected`, matching `resolveDsButtonStyle`'s equivalent comment.
  final stateStyle = disabled
      ? RemixSwitchStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSwitchStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
