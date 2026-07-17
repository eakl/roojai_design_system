import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'component_showcase_spec.dart';

/// Single reusable detail page. Renders each non-null builder on [spec] as
/// a labeled section with its widgets laid out in a wrapped row. Written
/// once, reused for every component in the catalog.
class ComponentShowcasePage extends StatelessWidget {
  const ComponentShowcasePage({super.key, required this.spec});

  final ComponentShowcaseSpec spec;

  @override
  Widget build(BuildContext context) {
    final canvasBase = $canvasDefault.resolve(context);
    final h3 = $headingH3.resolve(context);

    final sections = <Widget>[];
    if (spec.variantsBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'Variants',
        widgets: spec.variantsBuilder!(),
      ));
    }
    if (spec.sizesBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'Sizes',
        widgets: spec.sizesBuilder!(),
      ));
    }
    if (spec.statesBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'States',
        widgets: spec.statesBuilder!(),
      ));
    }

    return Scaffold(
      backgroundColor: canvasBase,
      appBar: AppBar(
        backgroundColor: canvasBase,
        elevation: 0,
        title: Text(spec.title, style: h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SemSpacing.spacing016),
        children: sections,
      ),
    );
  }
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({required this.label, required this.widgets});

  final String label;
  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    final contentMuted = $contentMuted.resolve(context);
    final overline = $overline.resolve(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: SemSpacing.spacing032),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: overline.copyWith(color: contentMuted),
          ),
          const SizedBox(height: SemSpacing.spacing012),
          Wrap(
            spacing: SemSpacing.spacing012,
            runSpacing: SemSpacing.spacing012,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widgets,
          ),
        ],
      ),
    );
  }
}
