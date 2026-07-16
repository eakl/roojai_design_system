import 'package:flutter/widgets.dart' hide Icon;
import 'package:naked_ui/naked_ui.dart' show NakedTabController;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'tabs_2_variants.dart';

// The `resolveDsTabBarStyle`/`resolveDsTabStyle`/`resolveDsTabViewStyle`
// functions consumed by `build()` below live in tabs_2_style_resolver.dart,
// split out as `part of` this library (not a separate import) so they stay
// private to this file's widgets while living in their own file — same
// split as `DsButton`'s `button_2_style_resolver.dart`.
part 'tabs_2_style_resolver.dart';

/// Tab-switching container built on top of the `remix` package's
/// [RemixTabs]/[RemixTabBar]/[RemixTab]/[RemixTabView] family, styled
/// through the design system's Mix semantic tokens.
///
/// Unlike most other `_2` components, tabs is a composite Remix wraps as
/// four cooperating widgets rather than one — [DsTabs] (this class) only
/// manages selection state, and callers assemble [DsTabBar]/[DsTab]/
/// [DsTabView] underneath it exactly as they would with the raw
/// [RemixTabs] family. See
/// `docs/superpowers/specs/2026-07-15-tabs-2-component-design.md` for the
/// full design rationale.
///
/// ## Example
///
/// ```dart
/// DsTabs(
///   selectedTabId: selectedTabId,
///   onChanged: (id) => setState(() => selectedTabId = id),
///   child: Column(
///     children: [
///       DsTabBar(
///         child: Row(
///           children: [
///             DsTab(tabId: 'tab1', label: 'Tab 1'),
///             DsTab(tabId: 'tab2', label: 'Tab 2'),
///           ],
///         ),
///       ),
///       DsTabView(tabId: 'tab1', child: Text('Content 1')),
///       DsTabView(tabId: 'tab2', child: Text('Content 2')),
///     ],
///   ),
/// )
/// ```
class DsTabs extends StatelessWidget {
  const DsTabs({
    super.key,
    required this.child,
    this.controller,
    this.selectedTabId,
    this.onChanged,
    this.orientation = Axis.horizontal,
    this.enabled = true,
    this.onEscapePressed,
  }) : assert(
         controller != null || selectedTabId != null,
         'Either controller or selectedTabId must be provided',
       );

  /// The tabs content — typically a [DsTabBar] followed by one [DsTabView]
  /// per tab.
  final Widget child;

  /// Optional controller for managing tab state, forwarded to
  /// [RemixTabs.controller].
  final NakedTabController? controller;

  /// The identifier of the currently selected tab. This widget holds no
  /// selection state of its own — it always reflects this value, same
  /// fully-controlled convention as [DsSelect]'s `selectedValue`.
  final String? selectedTabId;

  /// Called when the selected tab changes.
  final ValueChanged<String>? onChanged;

  /// Whether the tabs are enabled.
  final bool enabled;

  /// The tab list orientation. [resolveDsTabStyle]'s underline indicator is
  /// only tuned for the default horizontal layout — see the design spec's
  /// "Out of scope" section.
  final Axis orientation;

  /// Called when Escape is pressed while a tab has focus.
  final VoidCallback? onEscapePressed;

  @override
  Widget build(BuildContext context) {
    return RemixTabs(
      controller: controller,
      selectedTabId: selectedTabId,
      onChanged: onChanged,
      orientation: orientation,
      enabled: enabled,
      onEscapePressed: onEscapePressed,
      child: child,
    );
  }
}

/// A container widget for [DsTab] buttons within a [DsTabs].
class DsTabBar extends StatelessWidget {
  const DsTabBar({
    super.key,
    required this.child,
    this.variant = DsTabsVariant.underline,
    this.style = const RemixTabBarStyler.create(),
  });

  /// The tab buttons — typically a [Row] of [DsTab]s.
  final Widget child;

  /// Visual treatment — see [DsTabsVariant]. Callers composing a
  /// [DsTabBar] with multiple [DsTab]s should pass the same [variant] to
  /// each, same convention as [DsTab.size].
  final DsTabsVariant variant;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsTabBarStyle]'s output).
  final RemixTabBarStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsTabBarStyle(variant).merge(style);

    return RemixTabBar(style: resolvedStyle, child: child);
  }
}

/// An individual tab button within a [DsTabBar].
class DsTab extends StatelessWidget {
  const DsTab({
    super.key,
    required this.tabId,
    this.label,
    this.icon,
    this.child,
    this.variant = DsTabsVariant.underline,
    this.size = DsTabsSize.md,
    this.enabled = true,
    this.mouseCursor = SystemMouseCursors.click,
    this.enableFeedback = true,
    this.focusNode,
    this.autofocus = false,
    this.onFocusChange,
    this.onHoverChange,
    this.onPressChange,
    this.semanticLabel,
    this.style = const RemixTabStyler.create(),
  }) : assert(
         child != null || label != null,
         'Either child or label must be provided',
       );

  /// The unique identifier for this tab, matched against a [DsTabView]'s
  /// `tabId` and [DsTabs.selectedTabId].
  final String tabId;

  /// Display text for this tab. Ignored when [child] is set.
  final String? label;

  /// Optional icon shown alongside [label].
  final IconData? icon;

  /// Full override for this tab's content, bypassing [label]/[icon]
  /// entirely.
  final Widget? child;

  /// Visual treatment — see [DsTabsVariant]. Applied per-tab for the same
  /// reason as [size] — callers composing a [DsTabBar] should pass the
  /// same [variant] to it and to every [DsTab] within it.
  final DsTabsVariant variant;

  /// Physical size — see [DsTabsSize]. Applied per-tab since each [DsTab]
  /// is an independent sibling, not a list Remix sizes centrally — callers
  /// composing multiple tabs should pass the same [size] to each for a
  /// consistent tab bar.
  final DsTabsSize size;

  /// Public state: renders muted and suppresses taps/focus when false.
  /// Never inferred — always driven by this constructor param.
  final bool enabled;

  /// Cursor shown while hovering.
  final MouseCursor mouseCursor;

  /// Whether to provide platform feedback (e.g. haptics) on tap.
  final bool enableFeedback;

  /// Optional external focus node, forwarded to the underlying
  /// [RemixTab]/`NakedTab`.
  final FocusNode? focusNode;

  /// Whether this tab should request focus when first built.
  final bool autofocus;

  /// Called when focus changes.
  final ValueChanged<bool>? onFocusChange;

  /// Called when hover changes.
  final ValueChanged<bool>? onHoverChange;

  /// Called when press state changes.
  final ValueChanged<bool>? onPressChange;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [label] when null (same fallback [RemixTab] applies).
  final String? semanticLabel;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsTabStyle]'s output).
  final RemixTabStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsTabStyle(
      variant: variant,
      size: size,
      disabled: !enabled,
    ).merge(style);

    return RemixTab(
      tabId: tabId,
      label: child == null ? label : null,
      icon: child == null ? icon : null,
      enabled: enabled,
      mouseCursor: mouseCursor,
      enableFeedback: enableFeedback,
      focusNode: focusNode,
      autofocus: autofocus,
      onFocusChange: onFocusChange,
      onHoverChange: onHoverChange,
      onPressChange: onPressChange,
      semanticLabel: semanticLabel,
      style: resolvedStyle,
      child: child,
    );
  }
}

/// A content panel shown when its matching [DsTab] is selected.
class DsTabView extends StatelessWidget {
  const DsTabView({
    super.key,
    required this.tabId,
    required this.child,
    this.style = const RemixTabViewStyler.create(),
  });

  /// The identifier that matches a [DsTab.tabId].
  final String tabId;

  /// The content to show when this tab is selected.
  final Widget child;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsTabViewStyle]'s output).
  final RemixTabViewStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsTabViewStyle().merge(style);

    return RemixTabView(tabId: tabId, style: resolvedStyle, child: child);
  }
}
