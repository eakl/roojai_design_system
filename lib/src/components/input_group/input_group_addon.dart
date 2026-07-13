import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';

/// A leading/trailing slot inside an [InputGroup] — an icon, a short text
/// label (e.g. `"\$"`, `"https://"`), or an [InputGroupButton]. Mirrors
/// shadcn/ui's `InputGroupAddon`.
///
/// [InputGroupAddon] has no `leading`/`trailing` flag of its own — its
/// position in [InputGroup.children] (first vs. last) is what determines
/// whether it reads as leading or trailing, so it only standardizes the
/// *content* placed inside it:
/// - A bare [Text] child is styled muted/medium-weight via
///   [DefaultTextStyle], matching shadcn/ui's addon typography, without
///   the caller having to style it manually every time.
/// - An icon or [InputGroupButton] child paints its own color and simply
///   ignores the [DefaultTextStyle] — [Text] is the only widget that
///   reads it.
class InputGroupAddon extends StatelessWidget {
  const InputGroupAddon({super.key, required this.child, this.onTap});

  /// Typically an icon, a short [Text] label, or an [InputGroupButton].
  final Widget child;

  /// Called when the addon itself (not [child] specifically, e.g. the
  /// padding around a small icon) is tapped.
  ///
  /// On the web, shadcn/ui's addon focuses the adjacent field on click via
  /// a `cursor-text` affordance. There's no implicit way to reach a
  /// sibling [InputGroupInput]'s `FocusNode` from here — [InputGroup]
  /// only receives a flat, unordered-by-role `List<Widget>` — so that
  /// behavior isn't automatic. Callers who want it wire this explicitly,
  /// e.g. `onTap: () => myFocusNode.requestFocus()`, sharing the same
  /// `FocusNode` passed to the field's own `focusNode` param. Left null
  /// (the default) for a plain icon or unit label, which should stay
  /// inert to taps.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Layout ---------------------------------------------------------
    return GestureDetector(
      onTap: onTap,
      // Makes the whole padded area tappable, not just wherever `child`
      // itself paints pixels (e.g. the empty space around a small icon).
      behavior: HitTestBehavior.opaque,
      child: DefaultTextStyle(
        style: typography.labelMd.copyWith(color: colors.content.secondary),
        child: child,
      ),
    );
  }
}
