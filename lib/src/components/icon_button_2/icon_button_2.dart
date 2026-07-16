import 'package:flutter/widgets.dart' hide Icon;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../icon_2/icon.dart';
import 'icon_button_2_variants.dart';

// The `resolveDsIconButtonStyle` function consumed by `build()` below lives
// in icon_button_2_style_resolver.dart, split out as `part of` this library
// (not a separate import) so it stays private to DsIconButton while living
// in its own file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'icon_button_2_style_resolver.dart';

// The default `loading` spinner lives in its own `part` file for the same
// reason as the style resolver above — it's an implementation detail of
// DsIconButton, not something callers construct directly. Duplicated rather
// than shared with `DsButton`'s equivalent since both spinners are private
// to their own component file.
part 'icon_button_2_loading_spinner.dart';

/// Default [RemixIconButtonIconBuilder] for [DsIconButton]'s glyph.
///
/// Renders through the design system's own [Icon] rather than Remix's
/// built-in `StyledIcon`, so the glyph goes through the same widget as every
/// other icon in the design system. The resolved [IconSpec]'s `color`/`size`
/// (set per `variant`/`size` in `resolveDsIconButtonStyle`) are forwarded as
/// an explicit override, which wins over [Icon]'s own variant/size
/// defaults — same pattern as `DsButton`'s `_dsButtonIconBuilder`.
Widget _dsIconButtonIconBuilder(
  BuildContext context,
  IconSpec spec,
  IconData? icon,
) {
  if (icon == null) return const SizedBox.shrink();

  var style = IconStyler();
  if (spec.color != null) style = style.color(spec.color!);
  if (spec.size != null) style = style.size(spec.size!);

  return Icon(icon, style: style);
}

/// An icon-only pressable action button built on top of the `remix`
/// package's [RemixIconButton], styled through the design system's Mix
/// semantic tokens.
///
/// Unlike the legacy hand-rolled components, [DsIconButton] delegates all
/// interaction handling (hover/press/focus, semantics, gestures) to
/// [RemixIconButton] and only supplies a resolved [RemixIconButtonStyler] —
/// see [resolveDsIconButtonStyle] — for [variant] and [size]. Mirrors
/// [DsButton] but without a label, leading/trailing icon slots, or a text
/// builder — this component always renders exactly one glyph.
class DsIconButton extends StatelessWidget {
  const DsIconButton({
    super.key,
    required this.icon,
    this.iconBuilder,
    this.loadingBuilder,
    this.variant = DsIconButtonVariant.primary,
    this.size = DsIconButtonSize.md,
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
    this.style = const RemixIconButtonStyler.create(),
    this.styleSpec,
  });

  /// The icon to display in the button.
  final IconData icon;

  /// Builder for customizing the icon rendering.
  final RemixIconButtonIconBuilder? iconBuilder;

  /// Builder for customizing the loading spinner rendering.
  final RemixIconButtonLoadingBuilder? loadingBuilder;

  /// Visual treatment — see [DsIconButtonVariant].
  final DsIconButtonVariant variant;

  /// Physical size — see [DsIconButtonSize].
  final DsIconButtonSize size;

  /// Public state: shows a spinner and suppresses taps while the icon is
  /// hidden. Never inferred — always driven by this constructor param.
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
  /// [RemixIconButton]/`NakedButton`.
  final FocusNode? focusNode;

  /// Whether this button should request focus when first built.
  final bool autofocus;

  /// Whether to provide platform feedback (e.g. haptics) on tap.
  final bool enableFeedback;

  /// Overrides the semantic label read by screen readers.
  final String? semanticLabel;

  /// Additional semantic hint describing the tap action's effect.
  final String? semanticHint;

  /// Whether to exclude child semantics from the accessibility tree.
  final bool excludeSemantics;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsIconButtonStyle]'s output).
  final RemixIconButtonStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixIconButtonSpec] directly, bypassing style resolution entirely.
  final RemixIconButtonSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsIconButtonStyle(
      variant: variant,
      size: size,
      disabled: !enabled,
      loading: loading,
    ).merge(style);

    return RemixIconButton(
      icon: icon,
      iconBuilder: iconBuilder ?? _dsIconButtonIconBuilder,
      loadingBuilder: loadingBuilder ?? _dsIconButtonLoadingSpinnerBuilder,
      loading: loading,
      enabled: enabled,
      enableFeedback: enableFeedback,
      onPressed: onPressed,
      onLongPress: onLongPress,
      focusNode: focusNode,
      autofocus: autofocus,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      excludeSemantics: excludeSemantics,
      mouseCursor: mouseCursor,
      style: resolvedStyle,
      styleSpec: styleSpec,
    );
  }
}
