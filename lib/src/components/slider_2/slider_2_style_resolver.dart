part of 'slider_2.dart';

// Style resolver for DsSlider.
//
// Single entry point `resolveDsSliderStyle` builds one `RemixSliderStyle` by
// merging fragments — base, then size, then disabled state — mirroring the
// base/size/state composition in `switch_2_style_resolver.dart` (no variant
// fragment: DsSlider has no visual-skin axis, same decision `input_2` and
// `switch_2` made — see the design spec's "DsSliderSize" section).

/// Resolves the full `RemixSliderStyle` for a [DsSlider], given its [size]
/// and current [disabled] state.
///
/// Order of composition: base track/range/thumb colors, then size
/// (thumb dimensions + track/range thickness), then disabled. Later merges
/// win on overlapping properties, so `stateStyle` — applied last — always
/// has final say, mirroring `resolveDsButtonStyle`'s "disabled always wins"
/// comment.
RemixSliderStyle resolveDsSliderStyle({
  required DsSliderSize size,
  required bool disabled,
}) {
  // Track color and thumb ring treatment are a direct port of legacy
  // `AppSlider`'s `_resolveTrackColor`/`_resolveThumbRingColor`
  // (`colors.surface.alternative` -> `$surfaceAlternative`, `colors.surface.
  // base` -> `$surfaceDefault` thumb fill). Range/fill color is
  // `$accentUi()` — a deliberate divergence from legacy's neutral
  // `colors.surface.inverted` fill, confirmed during design (see spec's
  // style-resolver notes).
  final baseStyle = RemixSliderStyle()
      .trackColor($surfaceAlternative())
      .rangeColor($accentUi())
      .thumb(
        BoxStyler()
            .color($surfaceDefault())
            .shapeCircle(
              side: BorderSideMix()
                  .color($borderStrong())
                  .strokeAlign(BorderSide.strokeAlignOutside),
            ),
      );

  // `md` matches legacy `AppSlider`'s only size (18px thumb, 4px track)
  // exactly, so the default size renders identically to the widget it
  // replaces. `sm`/`lg` scale down/up from there.
  final sizeStyle = switch (size) {
    DsSliderSize.sm => RemixSliderStyle(
        thumb: BoxStyler().size(14, 14),
        trackWidth: 3,
        rangeWidth: 3,
      ),
    DsSliderSize.md => RemixSliderStyle(
        thumb: BoxStyler().size(18, 18),
        trackWidth: 4,
        rangeWidth: 4,
      ),
    DsSliderSize.lg => RemixSliderStyle(
        thumb: BoxStyler().size(22, 22),
        trackWidth: 5,
        rangeWidth: 5,
      ),
  };

  // Disabled wins over every other state — a disabled slider never shows
  // brighter feedback regardless of value, matching `resolveDsButtonStyle`'s
  // equivalent comment. Opacity wrap is the established `_2`-migration
  // convention (`button_2`/`switch_2`), replacing legacy `AppSlider`'s
  // separate muted-fill-color approach.
  final stateStyle = disabled
      ? RemixSliderStyle().wrap(WidgetModifierConfig.opacity(0.5))
      : RemixSliderStyle();

  return baseStyle.merge(sizeStyle).merge(stateStyle);
}
