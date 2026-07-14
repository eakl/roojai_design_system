import 'package:flutter/widgets.dart' hide Icon;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:remix/remix.dart';
import 'package:ui/src/tokens/semantic/typography.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../icon_2/icon.dart';
import 'button_2_variants.dart';

// The `resolveDsButtonStyle` function consumed by `build()` below lives in
// button_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsButton while living in its own
// file — same split as the legacy Button's `button_style_resolvers.dart`.
part 'button_2_style_resolver.dart';

// The default `loading` spinner lives in its own `part` file for the same
// reason as the style resolver above — it's an implementation detail of
// DsButton, not something callers construct directly.
part 'button_2_loading_spinner.dart';

/// Default [RemixButtonIconBuilder] for [DsButton]'s leading/trailing icons.
///
/// Renders through the design system's own [Icon] rather than Remix's
/// built-in `StyledIcon`, so the glyph goes through the same widget as every
/// other icon in the design system. The resolved [IconSpec]'s `color`/`size`
/// (set per `variant`/`size` in `resolveDsButtonStyle`) are forwarded as an
/// explicit override, which wins over [Icon]'s own variant/size defaults.
Widget _dsButtonIconBuilder(BuildContext context, IconSpec spec, IconData? icon) {
  if (icon == null) return const SizedBox.shrink();

  var style = IconStyler();
  if (spec.color != null) style = style.color(spec.color!);
  if (spec.size != null) style = style.size(spec.size!);

  return Icon(icon, style: style);
}

/// A pressable action button built on top of the `remix` package's
/// [RemixButton], styled through the design system's Mix semantic tokens.
///
/// Unlike the legacy hand-rolled `Button`, [DsButton] delegates all
/// interaction handling (hover/press/focus, semantics, gestures) to
/// [RemixButton] and only supplies a resolved [RemixButtonStyle] — see
/// [resolveDsButtonStyle] — for [variant] and [size].
class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.textBuilder,
    this.leadingIconBuilder,
    this.trailingIconBuilder,
    this.loadingBuilder,
    this.variant = DsButtonVariant.primary,
    this.size = DsButtonSize.md,
    this.loading = false,
    this.enabled = true,
    this.onPressed,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.enableFeedback = true,
    this.semanticLabel,
    this.semanticHint,
    this.excludeSemantics = false,
    this.mouseCursor = SystemMouseCursors.click,
    this.style = const RemixButtonStyle.create(),
    this.styleSpec,
  });

  /// The button's text content. Always shown, including while [loading].
  final String label;

  /// Icon shown before [label]. Ignored when [leadingIconBuilder] is set.
  final IconData? leadingIcon;

  /// Icon shown after [label]. Ignored when [trailingIconBuilder] is set.
  final IconData? trailingIcon;

  /// Builder for customizing the label rendering. Overrides [label]'s
  /// default text rendering when set.
  final RemixButtonTextBuilder? textBuilder;

  /// Builder for customizing the leading icon rendering.
  final RemixButtonIconBuilder? leadingIconBuilder;

  /// Builder for customizing the trailing icon rendering.
  final RemixButtonIconBuilder? trailingIconBuilder;

  /// Builder for customizing the loading spinner rendering.
  final RemixButtonLoadingBuilder? loadingBuilder;

  /// Visual treatment — see [DsButtonVariant].
  final DsButtonVariant variant;

  /// Physical size — see [DsButtonSize].
  final DsButtonSize size;

  /// Public state: shows a spinner and suppresses taps while [label] stays
  /// visible. Never inferred — always driven by this constructor param.
  final bool loading;

  /// Public state: renders muted/dimmed and suppresses taps/focus when
  /// false. Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Called on tap. Ignored (and the button rendered non-interactive)
  /// while [enabled] is false, [loading] is true, or when null.
  final VoidCallback? onPressed;

  /// Called on long-press. Subject to the same interactivity rules as
  /// [onPressed].
  final VoidCallback? onLongPress;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixButton]/`NakedButton`.
  final FocusNode? focusNode;

  /// Whether this button should request focus when first built.
  final bool autofocus;

  /// Whether to provide platform feedback (e.g. haptics) on tap.
  final bool enableFeedback;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [label] when null.
  final String? semanticLabel;

  /// Additional semantic hint describing the tap action's effect.
  final String? semanticHint;

  /// Whether to exclude child semantics from the accessibility tree.
  final bool excludeSemantics;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsButtonStyle]'s output).
  final RemixButtonStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixButtonSpec] directly, bypassing style resolution entirely.
  final RemixButtonSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsButtonStyle(
      variant: variant,
      size: size,
      disabled: !enabled,
      loading: loading,
    ).merge(style);

    return RemixButton(
      label: label,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      textBuilder: textBuilder,
      leadingIconBuilder: leadingIconBuilder ?? _dsButtonIconBuilder,
      trailingIconBuilder: trailingIconBuilder ?? _dsButtonIconBuilder,
      loadingBuilder: loadingBuilder ?? _dsButtonLoadingSpinnerBuilder,
      loading: loading,
      enabled: enabled,
      onPressed: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      enableFeedback: enableFeedback,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      excludeSemantics: excludeSemantics,
      mouseCursor: mouseCursor,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
