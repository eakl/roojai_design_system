import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:naked_ui/naked_ui.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';

// The `resolveDsPopoverStyle` function consumed by `build()` below lives in
// popover_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsPopover while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'popover_2_style_resolver.dart';

/// An anchored, dismissible overlay for supplementary interactive content,
/// built directly on the `naked_ui` package's [NakedPopover].
///
/// Unlike every other `_2` component, this does **not** wrap a
/// `remix`-provided widget — `remix: ^1.0.0-beta.1` (the version currently
/// pinned by this repo) does not ship a `RemixPopover` yet. Its docs
/// (https://docs.page/btwld/remix/components/popover) describe one, and it
/// exists in the `remix` GitHub repo's unreleased `main` branch (as a thin
/// `Box`-styled wrapper around the very same `NakedPopover`), but has not
/// been published to pub.dev in any version — the newest published version
/// (`1.0.0-beta.1`) still has no `popover` component directory. Rather than
/// depend on unreleased/unpublished remix source, [DsPopover] wraps
/// `NakedPopover` directly and styles its overlay container with Mix's own
/// [Box]/[BoxStyler] — the same low-level primitives `RemixPopover` itself
/// uses internally. Once `remix` publishes a released version with
/// `RemixPopover`, this can be swapped to delegate to it the same way
/// `DsDialog` delegates to `RemixDialog`.
///
/// Because there's no `RemixPopoverStyler` to mirror, [style] is a plain
/// Mix [BoxStyler] (styling the overlay container only) rather than a
/// `Remix`-style class — there is only one style axis here (the container),
/// so introducing a dedicated `DsPopoverStyler` wrapper class would add
/// ceremony without benefit. The trigger ([child]) keeps its own visual
/// styling, same as `RemixPopover`'s `child`.
class DsPopover extends StatelessWidget {
  const DsPopover({
    super.key,
    required this.popoverChild,
    required this.child,
    this.positioning = const OverlayPositionConfig(
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
    ),
    this.consumeOutsideTaps = true,
    this.useRootOverlay = false,
    this.openOnTap = true,
    this.triggerFocusNode,
    this.onOpen,
    this.onClose,
    this.onOpenRequested,
    this.onCloseRequested,
    this.controller,
    this.semanticLabel,
    this.excludeSemantics = false,
    this.style = const BoxStyler.create(),
  });

  /// The content shown inside the overlay once open.
  final Widget popoverChild;

  /// The trigger surface. Normally visual content rather than another
  /// independently-interactive widget — [DsPopover] supplies its own tap,
  /// keyboard, focus, and button semantics on top of it (unless
  /// [openOnTap] is false, see below).
  final Widget child;

  /// Anchors one point on [child] to one point on the overlay, with an
  /// optional offset. Defaults to opening below [child], matching the
  /// `FortalPopover` example in the design's basic-usage docs.
  final OverlayPositionConfig positioning;

  /// Whether tapping outside the overlay is consumed (preventing it from
  /// reaching whatever is behind it) or passed through.
  final bool consumeOutsideTaps;

  /// Whether to render the overlay in the root [Overlay] instead of the
  /// nearest ancestor one.
  final bool useRootOverlay;

  /// Whether tapping [child] toggles the popover open/closed. Set to
  /// false when another event (e.g. a button's `onPressed`) owns the open
  /// state via [controller] — see the design docs' "Programmatic control"
  /// section.
  final bool openOnTap;

  /// Optional external focus node for the trigger, forwarded to
  /// [NakedPopover.triggerFocusNode].
  final FocusNode? triggerFocusNode;

  /// Called when the popover opens.
  final VoidCallback? onOpen;

  /// Called when the popover closes.
  final VoidCallback? onClose;

  /// Called when a request is made to open the popover. Allows delaying
  /// or animating the transition — must call the provided `showOverlay`
  /// callback to complete it.
  final RawMenuAnchorOpenRequestedCallback? onOpenRequested;

  /// Called when a request is made to close the popover. Allows delaying
  /// or animating the transition — must call the provided `hideOverlay`
  /// callback to complete it.
  final RawMenuAnchorCloseRequestedCallback? onCloseRequested;

  /// Optional external controller for programmatic open/close, e.g. from
  /// a trigger that isn't [child] itself (used together with
  /// `openOnTap: false`).
  final MenuController? controller;

  /// Overrides the semantic label read by screen readers when [child]'s
  /// own visual content doesn't provide a clear accessible name.
  final String? semanticLabel;

  /// Whether to exclude [child]'s semantics from the accessibility tree.
  final bool excludeSemantics;

  /// Escape hatch for callers that need to further customize the resolved
  /// overlay container style (merged on top of [resolveDsPopoverStyle]'s
  /// output).
  final BoxStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsPopoverStyle().merge(style);

    return NakedPopover(
      popoverBuilder: (context, info) =>
          Box(style: resolvedStyle, child: popoverChild),
      positioning: positioning,
      consumeOutsideTaps: consumeOutsideTaps,
      useRootOverlay: useRootOverlay,
      openOnTap: openOnTap,
      triggerFocusNode: triggerFocusNode,
      onOpen: onOpen,
      onClose: onClose,
      onOpenRequested: onOpenRequested,
      onCloseRequested: onCloseRequested,
      controller: controller,
      semanticLabel: semanticLabel,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }
}
