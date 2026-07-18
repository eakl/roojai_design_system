import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'callout_2_variants.dart';

part 'callout_2_style_resolver.dart';

// TODO: Check Spacing on different size, Icon sizes

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
    this.tone = DsCalloutTone.soft,
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

  /// Emphasis level — see [DsCalloutTone].
  final DsCalloutTone tone;

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
      tone: tone,
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
