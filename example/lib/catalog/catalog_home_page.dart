import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'component_registry.dart';
import 'component_showcase_page.dart';

/// Flat, alphabetically sorted list of every design-system component.
/// Tapping an entry opens its [ComponentShowcasePage].
class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final canvasDefault = $canvasDefault.resolve(context);
    final contentMuted = $contentMuted.resolve(context);
    final borderDefault = $borderDefault.resolve(context);
    final h3 = $headingH3.resolve(context);
    final bodyMd = $bodyMd.resolve(context);
    final names = componentRegistry.keys.toList()..sort();

    return Scaffold(
      backgroundColor: canvasDefault,
      appBar: AppBar(
        backgroundColor: canvasDefault,
        elevation: 0,
        title: Text('Components', style: h3),
      ),
      body: names.isEmpty
          ? Center(
              child: Text(
                'No components yet',
                style: bodyMd.copyWith(color: contentMuted),
              ),
            )
          : ListView.separated(
              itemCount: names.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: borderDefault,
              ),
              itemBuilder: (context, index) {
                final name = names[index];
                return ListTile(
                  title: Text(name, style: bodyMd),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComponentShowcasePage(
                          spec: componentRegistry[name]!(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
