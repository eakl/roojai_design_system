import 'package:flutter/widgets.dart';
import 'package:naked_ui/naked_ui.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildPopover2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Popover 2',
    // No variantsBuilder/sizesBuilder — popover_2 has no variant or size
    // axis (only one fixed container style, same as dialog_2).
    statesBuilder: () => [
      const DsPopover(
        popoverChild: SizedBox(
          width: 240,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Signed in as'),
              SizedBox(height: 8),
              Text('person@example.com'),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('Account'),
        ),
      ),
      Builder(
        builder: (context) {
          final controller = MenuController();
          return DsPopover(
            controller: controller,
            openOnTap: false,
            popoverChild: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Controlled content'),
            ),
            child: DsButton(
              label: 'Open controlled popover',
              onPressed: () => controller.open(),
            ),
          );
        },
      ),
      const DsPopover(
        positioning: OverlayPositionConfig(
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          offset: Offset(0, -8),
        ),
        popoverChild: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Anchored top-right'),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text('Custom position'),
        ),
      ),
    ],
  );
}
