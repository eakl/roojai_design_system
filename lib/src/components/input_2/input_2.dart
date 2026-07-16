import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variants.dart';
import 'input_2_variants.dart';

// The `resolveDsInputStyle` function consumed by `build()` below lives in
// input_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsInput while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'input_2_style_resolver.dart';

/// Maps [DsInput]'s own size enum onto [Icon]'s, so leading/trailing
/// glyphs scale with the field instead of needing a second size prop from
/// callers — same pattern as `IconContainer`'s `_resolveGlyphSize`.
DsIconSize _resolveDsInputIconSize(DsInputSize size) {
  return switch (size) {
    DsInputSize.sm => DsIconSize.sm,
    DsInputSize.md => DsIconSize.md,
    DsInputSize.lg => DsIconSize.lg,
  };
}

/// A single-line text field built on top of the `remix` package's
/// [RemixTextField], styled through the design system's Mix semantic
/// tokens.
///
/// Unlike the legacy hand-rolled `Input`, [DsInput] delegates all
/// interaction handling (focus/hover, IME, selection, semantics) to
/// [RemixTextField] and only supplies a resolved [RemixTextFieldStyler] —
/// see [resolveDsInputStyle] — for [size] and [error].
///
/// Text-only: there is no file-drop or multiline/textarea variant here —
/// see `docs/superpowers/specs/2026-07-14-input-2-component-design.md`
/// for why those are separate future components.
class DsInput extends StatelessWidget {
  const DsInput({
    super.key,
    this.controller,
    this.hintText,
    this.label,
    this.helperText,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingIconBuilder,
    this.trailingIconBuilder,
    this.size = DsInputSize.md,
    this.error = false,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.semanticHint,
    this.style = const RemixTextFieldStyler.create(),
    this.styleSpec,
  });

  /// Controls the text being edited.
  final TextEditingController? controller;

  /// Hint text shown when the field is empty.
  final String? hintText;

  /// Label text shown above the field, styled via [resolveDsInputStyle].
  final String? label;

  /// Helper text shown below the field, styled via [resolveDsInputStyle].
  /// Always rendered when non-null, regardless of [error] — there is no
  /// separate error-message slot, so callers wanting distinct error copy
  /// should swap [helperText]'s content themselves when [error] is true.
  final String? helperText;

  /// Icon shown at the field's leading edge, rendered through the DS
  /// [Icon] widget. Ignored when [leadingIconBuilder] is set.
  final IconData? leadingIcon;

  /// Icon shown at the field's trailing edge, rendered through the DS
  /// [Icon] widget. Ignored when [trailingIconBuilder] is set.
  final IconData? trailingIcon;

  /// Full override for the leading accessory, bypassing [leadingIcon] and
  /// the default DS-[Icon] rendering entirely.
  final WidgetBuilder? leadingIconBuilder;

  /// Full override for the trailing accessory, bypassing [trailingIcon]
  /// and the default DS-[Icon] rendering entirely.
  final WidgetBuilder? trailingIconBuilder;

  /// Physical size — see [DsInputSize].
  final DsInputSize size;

  /// Public state: renders the negative/error border color. Mirrors the
  /// legacy `Input.invalid` — this widget doesn't validate its own
  /// content, the caller decides when a value is invalid. Never inferred.
  final bool error;

  /// Public state: disables input and renders muted colors when false.
  /// Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Whether to hide the text being edited (e.g. password fields).
  final bool obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// The maximum number of lines for the text to span. Kept at `1` by
  /// default — multiline entry is out of scope, see class doc.
  final int? maxLines;

  /// The minimum number of lines to occupy.
  final int? minLines;

  /// The maximum number of characters to allow in the field.
  final int? maxLength;

  /// Called on every edit to the field's value.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits editable content (e.g. keyboard's
  /// "done"/"go" action).
  final ValueChanged<String>? onSubmitted;

  /// Called when the user indicates they are done editing.
  final VoidCallback? onEditingComplete;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixTextField]/`NakedTextField`.
  final FocusNode? focusNode;

  /// Whether this field should request focus when first built.
  final bool autofocus;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [label] when null (same fallback [RemixTextField] applies).
  final String? semanticLabel;

  /// Additional semantic hint. Defaults to [hintText] when null.
  final String? semanticHint;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsInputStyle]'s output).
  final RemixTextFieldStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixTextFieldSpec] directly, bypassing style resolution entirely.
  final RemixTextFieldSpec? styleSpec;

  Widget? _buildLeading(BuildContext context) {
    if (leadingIconBuilder != null) return leadingIconBuilder!(context);
    if (leadingIcon == null) return null;
    return Icon(leadingIcon!, size: _resolveDsInputIconSize(size));
  }

  Widget? _buildTrailing(BuildContext context) {
    if (trailingIconBuilder != null) return trailingIconBuilder!(context);
    if (trailingIcon == null) return null;
    return Icon(trailingIcon!, size: _resolveDsInputIconSize(size));
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsInputStyle(
      size: size,
      error: error,
    ).merge(style);
  
    return RemixTextField(
      controller: controller,
      hintText: hintText,
      label: label,
      helperText: helperText,
      error: error,
      leading: _buildLeading(context),
      trailing: _buildTrailing(context),
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onEditingComplete: onEditingComplete,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
