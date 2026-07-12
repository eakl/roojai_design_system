import 'package:flutter/material.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ui_storybook',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('ui_storybook')),
      ),
    );
  }
}
