import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/spacing.dart';
import 'icon_variant.dart';

// The `resolveIconStyle` function consumed by `build()` below lives in
// icon_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to Icon while living in its own
// file — same split as Badge/DsButton.
part 'icon_style_resolver.dart';

/// Renders a Phosphor glyph at a design-system [DsIconSize], colored by
/// [DsIconVariant].
///
/// Built on Mix's [StyledIcon] — the same primitive [RemixButton] uses
/// internally to render its own `leadingIcon`/`trailingIcon` — so size and
/// color are resolved from the ambient `MixScope` without this widget ever
/// touching a raw [Color] in plain Dart.
class Icon extends StatelessWidget {
  const Icon(
    this.glyph, {
    super.key,
    this.variant = DsIconVariant.neutral,
    this.size = DsIconSize.md,
    this.style,
  });

  /// The glyph to render, e.g. `PhosphorIcons.check()`. Any Phosphor style
  /// variant (regular/bold/duotone/fill/thin/light) is selected by the
  /// caller via which glyph accessor they call — [Icon] only controls
  /// size/color, never the glyph's own style.
  final IconData glyph;

  /// Semantic color treatment — see [DsIconVariant].
  final DsIconVariant variant;

  /// Physical size — see [DsIconSize].
  final DsIconSize size;

  /// Escape hatch merged on top of the resolved style (e.g. a one-off
  /// color/opacity override), same shape as `DsButton.style`. When null,
  /// the style resolved from [size]/[variant] is used as-is.
  final IconStyler? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        resolveDsIconStyle(size: size, variant: variant).merge(style);

    return StyledIcon(icon: glyph, style: resolvedStyle);
  }
}
