import 'package:flutter/widgets.dart' hide Icon;
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variants.dart';
import 'icon_container_variants.dart';

// The `resolveDsIconContainerStyle`/`_resolveGlyph*` functions consumed by
// `build()` below live in icon_container_style_resolver.dart, split out as
// `part of` this library (not a separate import) so they stay private to
// IconContainer while living in their own file — same split as Icon/DsButton.
//
// Mix's `BoxStyler` has no way to carry a nested `IconStyler` for its child
// (unlike a composite Remix spec such as `RemixButtonStyle`), so the
// container's background/size and the glyph's color/size are necessarily
// two separate styles rather than one — `style` overrides the box, and
// `glyphStyle` overrides the glyph, each merged onto their own resolved
// default.
part 'icon_container_style_resolver.dart';

/// Renders a Phosphor glyph (via [Icon]) centered inside a rounded-square
/// background, sized by [size] and colored as one coherent unit by
/// [variant] — the square's background and the glyph's color both key off
/// the same [DsIconContainerVariant].
///
/// Built on Mix's [Box] — the same `BoxStyler`-driven primitive used
/// throughout this package — so the background color and corner radius
/// are resolved from the ambient `MixScope` without this widget ever
/// touching a raw [Color] in plain Dart.
class IconContainer extends StatelessWidget {
  const IconContainer(
    this.glyph, {
    super.key,
    this.variant = DsIconContainerVariant.neutral,
    this.size = DsIconContainerSize.md,
    this.style,
    this.iconStyle,
  });

  final IconData glyph;
  final DsIconContainerVariant variant;
  final DsIconContainerSize size;
  final BoxStyler? style;
  final IconStyler? iconStyle;

  @override
  Widget build(BuildContext context) {
    final containerStyle =
        resolveDsIconContainerStyle(variant: variant, size: size).merge(style);

    // Icon Style should not be the props. It should come from the resolver and be overriden by the props.
    // Resolver probably needs to return two style object.
    
    return Box(
      style: containerStyle,
      child: Center(
        child: Icon(
          glyph,
          variant: _resolveGlyphVariant(variant),
          size: _resolveGlyphSize(size),
          style: iconStyle,
        ),
      ),
    );
  }
}
