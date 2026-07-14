import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/spacing.dart';
import 'icon_variants.dart';

part 'icon_style_resolver.dart';

class Icon extends StatelessWidget {
  const Icon(
    this.glyph, {
    super.key,
    this.variant = DsIconVariant.neutral,
    this.size = DsIconSize.md,
    this.style,
  });

  final IconData glyph;
  final DsIconVariant variant;
  final DsIconSize size;
  final IconStyler? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        resolveDsIconStyle(size: size, variant: variant).merge(style);

    return StyledIcon(icon: glyph, style: resolvedStyle);
  }
}
