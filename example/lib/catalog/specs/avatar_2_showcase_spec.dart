import 'package:flutter/material.dart' show NetworkImage;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildAvatar2ShowcaseSpec() {
  const brokenImageUrl = 'https://example.invalid/broken-avatar.png';
  const photoUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop';

  return ComponentShowcaseSpec(
    title: 'Avatar 2',
    variantsBuilder: () => DsAvatarVariant.values
        .map(
          (variant) => DsAvatar(
            label: variant.name.substring(0, 2),
            variant: variant,
          ),
        )
        .toList(),
    sizesBuilder: () => DsAvatarSize.values
        .map(
          (size) => DsAvatar(
            label: size.name,
            size: size,
          ),
        )
        .toList(),
    statesBuilder: () => [
      const DsAvatar(
        image: NetworkImage(photoUrl),
        label: 'JD',
      ),
      const DsAvatar(
        image: NetworkImage(brokenImageUrl),
        label: 'JD',
      ),
      const DsAvatar(label: 'AB'),
      DsAvatar(icon: PhosphorIcons.user()),
      const DsAvatar(label: 'SQ', shape: DsAvatarShape.square),
    ],
  );
}
