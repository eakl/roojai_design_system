import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../label/label.dart';

/// A labeled wrapper around a single form input, built from a plain
/// `Column` (no Material `Form`/`FormField`/`TextFormField` machinery) —
/// shadcn/ui's form-item building block, but named `AppFormField` to avoid
/// colliding with Flutter's own `FormField`.
///
/// Composes three independently-optional pieces around [child]:
/// - a [Label] above it, carrying [required]/[disabled] through unchanged
///   (see [Label] for what those two flags do visually);
/// - [helperText] below it, shown when [errorText] is null;
/// - [errorText] below it instead of [helperText] when non-null, in the
///   negative/error color — this widget doesn't validate [child]'s
///   content itself, the caller decides when a value is invalid and
///   passes this flag explicitly, mirroring [Input.invalid]/
///   [Textarea.invalid].
///
/// This widget owns no interaction state of its own — there's nothing to
/// derive (no focus/press/hover signal belongs to a label+helper
/// wrapper) — so, like [Label], it's a `StatelessWidget` with its
/// resolver kept inline rather than split into a `_style_resolvers.dart`
/// part file.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.disabled = false,
    required this.child,
  });

  /// Text shown in the [Label] above [child].
  final String label;

  /// Passed straight through to [Label.required] — appends a `*` after
  /// [label]. Has no effect on [child] itself; the caller must also pass
  /// e.g. `Input(required: ...)` if that matters to them.
  final bool required;

  /// Shown below [child], in a muted color, when [errorText] is null.
  /// Typically field guidance (e.g. "We'll never share your email.").
  final String? helperText;

  /// Shown below [child] instead of [helperText], in the negative/error
  /// color, when non-null. The caller is responsible for also passing the
  /// matching invalid flag to [child] (e.g. `Input(invalid: true)`) so
  /// the pair stays visually consistent — this widget only renders the
  /// text, it doesn't reach into [child] to set that itself.
  final String? errorText;

  /// Passed straight through to [Label.disabled]. Has no effect on
  /// [child] itself — the caller must also pass the matching disabled
  /// flag to whatever input widget they supply as [child], e.g.
  /// `Input(disabled: ...)`, so the pair stays visually and functionally
  /// consistent. Never inferred from other props, per the package's
  /// disabled-is-never-inferred rule.
  final bool disabled;

  /// The field's input widget — typically an [Input] or [Textarea], but
  /// any widget is accepted so this wrapper works for any current or
  /// future input-like component.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties -------------------------------------------
    final hasError = errorText != null;
    final helpText = errorText ?? helperText;
    final helpTextColor = _resolveHelpTextColor(colors, hasError);

    // --- Layout ---------------------------------------------------------
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Label(text: label, required: required, disabled: disabled),
        const SizedBox(height: AppSpacing.spacing6),
        child,
        if (helpText != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          Text(
            helpText,
            style: typography.captionSm.copyWith(color: helpTextColor),
          ),
        ],
      ],
    );
  }
}

// Style resolver for AppFormField — a single-axis resolver, same
// "kept inline, no part file" convention as Label's `_resolve*`
// functions.

/// The helper/error line below [AppFormField.child] reads as an error
/// (negative/red) whenever [AppFormField.errorText] is set, and as muted
/// guidance text otherwise — same negative-color convention as
/// [Label]'s required-marker and [Input.invalid]'s border.
Color _resolveHelpTextColor(SemanticColors colors, bool hasError) {
  return hasError ? colors.negative.text : colors.content.muted;
}
