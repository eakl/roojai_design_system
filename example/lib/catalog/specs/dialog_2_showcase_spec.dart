import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildDialog2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Dialog 2',
    // No variantsBuilder/sizesBuilder — dialog_2 has no variant or size
    // axis (see the component's design spec).
    statesBuilder: () => [
      Builder(
        builder: (context) => DsButton(
          label: 'title + description + actions',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => DsDialog(
              title: 'Delete item',
              description:
                  'Are you sure you want to delete this item? This '
                  'action cannot be undone.',
              actions: [
                DsButton(
                  label: 'Cancel',
                  variant: DsButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                DsButton(
                  label: 'Delete',
                  variant: DsButtonVariant.destructive,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'custom child',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => const DsDialog(
              child: SizedBox(
                width: 240,
                child: Text('Fully custom dialog content goes here.'),
              ),
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'non-modal',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => DsDialog(
              modal: false,
              title: 'Non-modal dialog',
              description: 'Background content stays interactive.',
              actions: [
                DsButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'non-dismissible',
          onPressed: () => showDsDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => DsDialog(
              title: 'Non-dismissible',
              description: 'Tapping the barrier will not close this.',
              actions: [
                DsButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
