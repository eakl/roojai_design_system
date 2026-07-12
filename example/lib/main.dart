import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'catalog/catalog_home_page.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTokensScope(
      child: MaterialApp(
        title: 'ui_storybook',
        debugShowCheckedModeBanner: false,
        home: const CatalogHomePage(),
      ),
    );
  }
}
