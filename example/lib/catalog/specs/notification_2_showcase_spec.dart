import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildNotification2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Notification 2',
    variantsBuilder: () => DsNotificationVariant.values
        .map(
          (variant) => DsNotification(
            text: variant.name,
            leading: Icon(PhosphorIcons.info()),
            variant: variant,
          ),
        )
        .toList(),
    sizesBuilder: () => DsNotificationSize.values
        .map(
          (size) => DsNotification(
            text: size.name,
            leading: Icon(PhosphorIcons.info()),
            size: size,
          ),
        )
        .toList(),
    statesBuilder: () => [
      const DsNotification(text: 'text only, no leading/title/actions'),
      const DsNotification(
        title: 'Title',
        text: 'with a title above the body text',
      ),
      DsNotification(
        text: 'with a bare Icon as leading',
        leading: Icon(PhosphorIcons.warning()),
        variant: DsNotificationVariant.warning,
      ),
      DsNotification(
        text: 'with an IconContainer as leading',
        leading: IconContainer(
          PhosphorIcons.checkCircle(),
          variant: DsIconContainerVariant.positive,
        ),
        variant: DsNotificationVariant.positive,
      ),
      DsNotification(
        title: 'Update available',
        text: 'with an actions row, bottom-right aligned',
        leading: Icon(PhosphorIcons.info()),
        actions: [
          DsButton(label: 'Dismiss', variant: DsButtonVariant.ghost, onPressed: () {}),
          DsButton(label: 'Update', onPressed: () {}),
        ],
      ),
    ],
  );
}
