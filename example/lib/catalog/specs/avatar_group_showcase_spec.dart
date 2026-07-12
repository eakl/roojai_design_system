import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

// Public placeholder photo service, indexed so each generated avatar gets
// a distinct picture — good enough for a showcase without bundling asset
// images into the example app.
String _photoUrl(int index) => 'https://i.pravatar.cc/150?img=$index';

List<Avatar> _sampleAvatars(int count) => List.generate(
      count,
      (i) => Avatar(
        fallback: String.fromCharCode(65 + i % 26) * 2,
        image: NetworkImage(_photoUrl(i + 1)),
      ),
    );

/// "Add member"-style button used as a [AvatarGroup.trailing] example in
/// the showcase only. Sized to match the group's own (default `md`)
/// avatar diameter so it sits flush against the stack.
class _AddAvatarButton extends StatelessWidget {
  const _AddAvatarButton();

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final diameter = avatarDiameterForSize(AvatarSize.md);

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.border.strong),
      ),
      child: Center(
        child: Text(
          '+',
          style: typography.labelLg.copyWith(color: colors.content.secondary),
        ),
      ),
    );
  }
}

ComponentShowcaseSpec buildAvatarGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Avatar Group',
    variantsBuilder: () => [
      // Exactly fills the default maxVisible: 3, no overflow circle.
      AvatarGroup(avatars: _sampleAvatars(3)),
      // Exceeds the default maxVisible: 3 -> trailing "+3" circle.
      AvatarGroup(avatars: _sampleAvatars(6)),
      // Custom maxVisible: shows 4 avatars, "+2" for the remainder.
      AvatarGroup(avatars: _sampleAvatars(6), maxVisible: 4),
      // `trailing` is independent of overflow — shown alongside a group
      // that doesn't overflow at all.
      AvatarGroup(avatars: _sampleAvatars(3), trailing: const _AddAvatarButton()),
    ],
  );
}
