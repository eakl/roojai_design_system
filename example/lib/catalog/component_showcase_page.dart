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
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

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
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text(spec.title, style: typography.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
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
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.overline.copyWith(color: colors.content.muted),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Wrap(
            spacing: AppSpacing.spacing12,
            runSpacing: AppSpacing.spacing12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widgets,
          ),
        ],
      ),
    );
  }
}
