import 'package:flutter/material.dart' show Icons;
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

List<DsListItem> _sampleItems() => const [
  DsListItem(title: 'Notifications', subtitle: 'Push and email alerts'),
  DsListItem(title: 'Privacy', subtitle: 'Control who can see your data'),
  DsListItem(title: 'Security', subtitle: 'Two-factor authentication'),
];

ComponentShowcaseSpec buildList2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'List 2',
    sizesBuilder: () => DsListSize.values
        .map(
          (size) =>
              DsList(size: size, bordered: true, children: _sampleItems()),
        )
        .toList(),
    variantsBuilder: () => [
      DsList(bordered: false, children: _sampleItems()),
      DsList(bordered: true, children: _sampleItems()),
    ],
    statesBuilder: () => [
      DsList(bordered: true, separated: true, children: _sampleItems()),
      DsList(
        bordered: true,
        header: const DsListItem(title: 'Settings'),
        children: _sampleItems(),
      ),
      const DsList(
        bordered: true,
        children: [
          DsListItem(
            title: 'Home',
            leading: Icon(Icons.home),
            trailing: Icon(Icons.chevron_right),
          ),
          DsListItem(
            title: 'Profile',
            leading: Icon(Icons.person),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
      const DsList(
        bordered: true,
        children: [
          DsListItem(
            title: 'Disabled item',
            subtitle: 'Cannot be interacted with',
            enabled: false,
          ),
        ],
      ),
      DsList(
        bordered: true,
        children: [
          DsListItem(
            title: 'Tap me',
            subtitle: 'This row has onTap wired up',
            onTap: () {},
          ),
        ],
      ),
    ],
  );
}
