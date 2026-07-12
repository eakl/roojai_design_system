import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// Flat, alphabetically sorted list of every design-system component.
/// Component entries are appended here as each is built (Task 9 onward).
class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  static const List<String> componentNames = <String>[];

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Scaffold(
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text('Components', style: typography.h3),
      ),
      body: componentNames.isEmpty
          ? Center(
              child: Text(
                'No components yet',
                style: typography.bodyMd.copyWith(color: colors.content.muted),
              ),
            )
          : ListView.separated(
              itemCount: componentNames.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border.base,
              ),
              itemBuilder: (context, index) {
                final name = componentNames[index];
                return ListTile(
                  title: Text(name, style: typography.bodyMd),
                  onTap: () {
                    // Navigation to ComponentShowcasePage wired in Task 8.
                  },
                );
              },
            ),
    );
  }
}
