import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';

/// A form-field caption built from a plain `Text` (no Material `Text`
/// wrapping beyond what `widgets.dart` already provides).
///
/// Mirrors shadcn's `Label`: a small, low-emphasis piece of text that sits
/// above/beside an input and carries two independent boolean modifiers —
/// [required] (appends a `*` in the negative/error color, the universal
/// "this field must be filled in" convention) and [disabled] (mutes the
/// text to match a disabled sibling field). Unlike shadcn's web version,
/// which mutes itself via a CSS `peer-disabled` selector reacting to a
/// sibling input's `:disabled` state, this widget has no notion of a
/// "peer" — [disabled] is always an explicit, caller-supplied flag, in
/// keeping with the package's disabled-is-never-inferred rule.
///
/// Label has no [variant] or size axis: it renders at a single fixed type
/// scale ([SemanticTypography.labelMd]) regardless of context, matching
/// shadcn's Label (which also does not expose a size prop).
class Label extends StatelessWidget {
  const Label({
    super.key,
    required this.text,
    this.required = false,
    this.disabled = false,
  });

  /// The label's text content. Always shown.
  final String text;

  /// Whether the field this label describes is required. When true, a `*`
  /// is appended after [text] in the negative/error color — the
  /// conventional "required field" marker.
  final bool required;

  /// Whether the field this label describes is disabled. When true, the
  /// text (and the `*`, if [required] is also true) is muted to the same
  /// placeholder color a disabled input's own text would use, so the pair
  /// reads as a single disabled unit. Never inferred from other props —
  /// the caller must pass this explicitly, e.g. mirroring the input's own
  /// `disabled` flag.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    // --- Tokens ---------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ---------------------------------------------
    final textColor = _resolveTextColor(colors, disabled);
    final requiredMarkerColor = _resolveRequiredMarkerColor(colors, disabled);

    // --- Layout -----------------------------------------------------------
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: typography.labelMd.copyWith(color: textColor)),
        if (required) ...[
          const SizedBox(width: AppSpacing.spacing2),
          Text(
            '*',
            style: typography.labelMd.copyWith(color: requiredMarkerColor),
          ),
        ],
      ],
    );
  }
}

// Style resolvers for Label.
//
// One pure function per resolved property, same convention as
// Button/Badge's `_resolve*` split — kept inline here (no separate
// `_style_resolvers.dart` part file) because Label has only these two
// single-axis resolvers rather than a variant x state matrix worth
// isolating into its own file.

Color _resolveTextColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.content.primary;
}

/// The required-marker (`*`) always reads as an error/negative color when
/// enabled, since it signals a validation requirement — but it still
/// mutes to the shared disabled color when [disabled] is true, so a
/// disabled required label doesn't draw the eye with a bright red asterisk
/// on an otherwise-muted field.
Color _resolveRequiredMarkerColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.negative.text;
}
