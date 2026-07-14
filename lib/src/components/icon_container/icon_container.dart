import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variant.dart';
import 'icon_container_size.dart';

// The `_resolveIconContainerSize`/`_resolveIconContainerBackground`
// functions consumed by `build()` below live in
// icon_container_style_resolver.dart, split out as `part of` this library
// (not a separate import) so they stay private to IconContainer while
// living in their own file — same split as Icon/DsButton.
part 'icon_container_style_resolver.dart';

/// Renders a Phosphor glyph (via [Icon]) centered inside a rounded-square
/// background, sized by [size] and colored as one coherent unit by
/// [variant] — the square's background and the glyph's color both key off
/// the same [DsIconVariant].
///
/// Built on Mix's [Box] — the same `BoxStyler`-driven primitive used
/// throughout this package — so the background color and corner radius
/// are resolved from the ambient `MixScope` without this widget ever
/// touching a raw [Color] in plain Dart.
class IconContainer extends StatelessWidget {
  const IconContainer(
    this.glyph, {
    super.key,
    this.variant = DsIconVariant.neutral,
    this.size = DsIconContainerSize.md,
    this.style,
  });

  /// The glyph to render, forwarded to the inner [Icon] unchanged.
  final IconData glyph;

  /// Semantic color treatment, shared between the square's background and
  /// the glyph's color — see [DsIconVariant].
  final DsIconVariant variant;

  /// Physical size — see [DsIconContainerSize].
  final DsIconContainerSize size;

  /// Escape hatch merged on top of the resolved style (e.g. a one-off
  /// background/radius override), same shape as `Icon.style`.
  final BoxStyler? style;

  @override
  Widget build(BuildContext context) {
    final (dimension, iconSize) = _resolveIconContainerSize(size);

    final resolvedStyle = BoxStyler()
        .size(dimension, dimension)
        .color(_resolveIconContainerBackground(variant))
        .borderRadiusAll($radius008())
        .merge(style);

    return Box(
      style: resolvedStyle,
      child: Center(child: Icon(glyph, size: iconSize, variant: variant)),
    );
  }
}
