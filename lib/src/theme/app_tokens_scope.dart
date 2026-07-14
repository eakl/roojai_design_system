import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import 'app_theme_data.dart';

/// Installs the design system's Mix tokens at the app root via [MixScope].
///
/// Defaults to the package's built-in [defaultLightTokens]; a consuming
/// app may pass typed override maps (mirroring [MixScope]'s own
/// constructor params) to retheme every component without touching
/// component code. Overrides are merged on top of the defaults, so a
/// partial override map only replaces the tokens it specifies.
class AppTokensScope extends StatelessWidget {
  const AppTokensScope({
    super.key,
    this.colors = const <ColorToken, Color>{},
    this.textStyles = const <TextStyleToken, TextStyle>{},
    this.spaces = const <SpaceToken, double>{},
    this.radii = const <RadiusToken, Radius>{},
    this.boxShadows = const <BoxShadowToken, List<BoxShadow>>{},
    this.tokens = const <MixToken, Object>{},
    required this.child,
  });

  final Map<ColorToken, Color> colors;
  final Map<TextStyleToken, TextStyle> textStyles;
  final Map<SpaceToken, double> spaces;
  final Map<RadiusToken, Radius> radii;
  final Map<BoxShadowToken, List<BoxShadow>> boxShadows;

  /// Overrides for token types without a dedicated typed param above
  /// (e.g. [DurationToken], [CurveToken]).
  final Map<MixToken, Object> tokens;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // `.cast<MixToken, Object>()` mirrors how `mix`'s own `MixScope` factory
    // combines its typed override maps internally (see
    // `mix_theme.dart`'s `MixScope` factory constructor) — required because
    // a `Map<ColorToken, Color>` spread directly into a
    // `Map<MixToken, Object>` literal is not automatically widened.
    return MixScope(
      tokens: <MixToken, Object>{
        ...defaultLightTokens,
        ...colors.cast<MixToken, Object>(),
        ...textStyles.cast<MixToken, Object>(),
        ...spaces.cast<MixToken, Object>(),
        ...radii.cast<MixToken, Object>(),
        ...boxShadows.cast<MixToken, Object>(),
        ...tokens,
      },
      child: child,
    );
  }
}
