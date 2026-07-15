import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSpinner2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Spinner 2',
    sizesBuilder: () =>
        DsSpinnerSize.values.map((size) => DsSpinner(size: size)).toList(),
    // `inverted` only reads correctly against a dark/brand surface — see
    // `DsSpinner.inverted`'s doc comment — so unlike every other boolean
    // state in the catalog (rendered bare on the page's light canvas),
    // the inverted entry here is wrapped in its own `surface.inverted`
    // swatch to actually demonstrate what it's for.
    statesBuilder: () => [
      const DsSpinner(),
      const _InvertedSwatch(child: DsSpinner(inverted: true)),
    ],
  );
}

class _InvertedSwatch extends StatelessWidget {
  const _InvertedSwatch({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp012),
      decoration: BoxDecoration(
        color: $surfaceInverted.resolve(context),
        borderRadius: BorderRadius.circular(AppRadius.rd008),
      ),
      child: child,
    );
  }
}
