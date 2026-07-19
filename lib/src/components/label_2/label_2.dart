import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'label_2_variants.dart';

// The `resolveDsLabelStyle` function consumed by `build()` below lives in
// label_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsLabel while living in its own
// file — same split as `icon_2`'s `icon_style_resolver.dart`.
part 'label_2_style_resolver.dart';

/// A form-field caption built on Mix's `StyledText`, styled through the
/// design system's `_2` semantic tokens.
///
/// The DS-2 replacement for the legacy hand-rolled `Label`. Unlike
/// `button_2`/`input_2`, there is no Remix widget to wrap — Remix ships a
/// label styling mixin used internally by other components, not a
/// standalone Label widget — so [DsLabel] is a plain `StatelessWidget`
/// rendering directly through Mix's `StyledText`/`TextStyler`, the same
/// approach `icon_2` uses for `StyledIcon`.
///
/// Carries two independent boolean modifiers — [required] (appends a `*`
/// in the negative/error color) and [disabled] (mutes the text to match a
/// disabled sibling field) — plus a [size] axis (new relative to legacy
/// `Label`, which had none) so the caption can be sized to match the
/// `DsInputSize`/`DsButtonSize` of the field it's paired with.
///
/// [disabled] is always an explicit, caller-supplied flag, never inferred
/// from a sibling widget's state — this package has no CSS-`peer-disabled`
/// equivalent, and disabled is never inferred elsewhere in the DS either.
class DsLabel extends StatelessWidget {
  const DsLabel({
    super.key,
    required this.text,
    this.size = DsLabelSize.md,
    this.required = false,
    this.disabled = false,
  });

  /// The label's text content. Always shown.
  final String text;

  /// Physical size — see [DsLabelSize].
  final DsLabelSize size;

  /// Whether the field this label describes is required. When true, a `*`
  /// is appended after [text] in the negative/error color.
  final bool required;

  /// Whether the field this label describes is disabled. When true, the
  /// text (and the `*`, if [required] is also true) is muted to the same
  /// placeholder color a disabled input's own text would use.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsLabelStyle(size: size, disabled: disabled);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StyledText(text, style: resolvedStyle.text),
        if (required) ...[
          SizedBox(width: $spacing002()),
          StyledText('*', style: resolvedStyle.marker),
        ],
      ],
    );
  }
}
