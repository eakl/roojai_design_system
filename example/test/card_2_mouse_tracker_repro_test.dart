import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui/ui.dart';
import 'package:ui_storybook/catalog/component_showcase_page.dart';
import 'package:ui_storybook/catalog/specs/card_2_showcase_spec.dart';

void main() {
  testWidgets('hovering the card_2 showcase does not trip MouseTracker',
      (tester) async {
    // Small viewport so the ListView has a nonzero scroll extent and the
    // desktop ScrollBehavior attaches an interactive Scrollbar.
    await tester.binding.setSurfaceSize(const Size(400, 300));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(AppTokensScope(
      child: MaterialApp(
        home: ComponentShowcasePage(spec: buildCard2ShowcaseSpec()),
      ),
    ));
    await tester.pumpAndSettle();

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: const Offset(200, 150));
    await tester.pump();

    // Sweep across the content, including the scrollbar track on the
    // right edge, while frames are still settling.
    for (final dy in [10.0, 50.0, 100.0, 150.0, 200.0, 250.0, 290.0]) {
      await gesture.moveTo(Offset(390, dy));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  });
}
