import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'callout_2_variants.dart';

// The `resolveDsCalloutStyle` function consumed by `build()` below lives in
// callout_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsCallout while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'callout_2_style_resolver.dart';

/// A prominent, non-interactive message component built on top of the
/// `remix` package's [RemixCallout], styled through the design system's Mix
/// semantic tokens.
///
/// Unlike [DsButton]/[DsInput], [DsCallout] has no interaction states
/// (hover/press/focus/disabled) to resolve — it only varies along [variant]
/// (semantic color treatment) and [size].
class DsCallout extends StatelessWidget {
  /// Creates a callout with optional [text] or [child]. At least one of
  /// [text] or [child] must be provided — mirrors [RemixCallout]'s own
  /// assertion.
  const DsCallout({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.variant = DsCalloutVariant.neutral,
    this.size = DsCalloutSize.md,
    this.style = const RemixCalloutStyler.create(),
    this.styleSpec,
  }) : assert(
         text != null || child != null,
         'Provide either text or child to DsCallout.',
       );

  /// The text to display in the callout.
  final String? text;

  /// The icon to display in the callout, rendered through Remix's built-in
  /// icon slot (sized/colored per [variant]/[size] — see
  /// [resolveDsCalloutStyle]).
  final IconData? icon;

  /// Optional custom child content for the callout body, bypassing [text]
  /// entirely.
  final Widget? child;

  /// Semantic color treatment — see [DsCalloutVariant].
  final DsCalloutVariant variant;

  /// Physical size — see [DsCalloutSize].
  final DsCalloutSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsCalloutStyle]'s output).
  final RemixCalloutStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixCalloutSpec] directly, bypassing style resolution entirely.
  final RemixCalloutSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCalloutStyle(
      variant: variant,
      size: size,
    ).merge(style);

    return RemixCallout(
      text: text,
      icon: icon,
      style: resolvedStyle,
      styleSpec: styleSpec,
      child: child,
    );
  }
}
