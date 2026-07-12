import 'package:flutter/widgets.dart';

/// Declares how a single design-system component is showcased. Each
/// builder returns one widget per showcased value; a null builder means
/// that axis doesn't apply to this component and its section is omitted.
class ComponentShowcaseSpec {
  const ComponentShowcaseSpec({
    required this.title,
    this.variantsBuilder,
    this.sizesBuilder,
    this.statesBuilder,
  });

  final String title;
  final List<Widget> Function()? variantsBuilder;
  final List<Widget> Function()? sizesBuilder;
  final List<Widget> Function()? statesBuilder;
}
