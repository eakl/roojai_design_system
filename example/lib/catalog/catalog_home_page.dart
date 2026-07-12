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
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final names = componentRegistry.keys.toList()..sort();

    return Scaffold(
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text('Components', style: typography.h3),
      ),
      body: names.isEmpty
          ? Center(
              child: Text(
                'No components yet',
                style: typography.bodyMd.copyWith(color: colors.content.muted),
              ),
            )
          : ListView.separated(
              itemCount: names.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border.base,
              ),
              itemBuilder: (context, index) {
                final name = names[index];
                return ListTile(
                  title: Text(name, style: typography.bodyMd),
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
