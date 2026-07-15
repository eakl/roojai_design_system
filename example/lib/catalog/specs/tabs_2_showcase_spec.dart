import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildTabs2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Tabs 2',
    variantsBuilder: () => DsTabsVariant.values
        .map((variant) => _InteractiveTabs(variant: variant))
        .toList(),
    sizesBuilder: () => DsTabsSize.values
        .map((size) => _InteractiveTabs(size: size))
        .toList(),
    // DsTabs.selectedTabId is fully controlled — see its doc comment — so
    // every entry below needs a real tab tree wrapped in _InteractiveTabs
    // (a minimal StatefulWidget that owns local selection state and
    // demonstrates the controlled-widget contract, same pattern
    // select_2_showcase_spec.dart's _InteractiveSelect uses) to
    // demonstrate real switching. Hover/pressed/focus remain transient
    // and Naked-driven, verified interactively in the running app.
    statesBuilder: () => [
      const _InteractiveTabs(),
      const _InteractiveTabs(withIcons: true),
      const _InteractiveTabs(disabledTabId: 'tab2'),
      const _InteractiveTabs(variant: DsTabsVariant.segmented),
      const _InteractiveTabs(
        variant: DsTabsVariant.segmented,
        disabledTabId: 'tab2',
      ),
    ],
  );
}

/// Owns local tab-selection state for a single showcased [DsTabs], so the
/// catalog page can demonstrate real switching. [DsTabs] itself holds no
/// internal state — see [DsTabs.selectedTabId]'s doc comment — so any
/// caller wanting live interaction (this showcase included) must do the
/// same: track `selectedTabId` externally and update it from
/// [DsTabs.onChanged].
class _InteractiveTabs extends StatefulWidget {
  const _InteractiveTabs({
    this.variant = DsTabsVariant.underline,
    this.size = DsTabsSize.md,
    this.withIcons = false,
    this.disabledTabId,
  });

  final DsTabsVariant variant;
  final DsTabsSize size;
  final bool withIcons;
  final String? disabledTabId;

  @override
  State<_InteractiveTabs> createState() => _InteractiveTabsState();
}

class _InteractiveTabsState extends State<_InteractiveTabs> {
  String _selectedTabId = 'tab1';

  @override
  Widget build(BuildContext context) {
    return DsTabs(
      selectedTabId: _selectedTabId,
      onChanged: (id) => setState(() => _selectedTabId = id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsTabBar(
            variant: widget.variant,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DsTab(
                  tabId: 'tab1',
                  label: 'Overview',
                  icon: widget.withIcons ? PhosphorIcons.house() : null,
                  variant: widget.variant,
                  size: widget.size,
                  enabled: widget.disabledTabId != 'tab1',
                ),
                DsTab(
                  tabId: 'tab2',
                  label: 'Activity',
                  icon: widget.withIcons ? PhosphorIcons.clock() : null,
                  variant: widget.variant,
                  size: widget.size,
                  enabled: widget.disabledTabId != 'tab2',
                ),
                DsTab(
                  tabId: 'tab3',
                  label: 'Settings',
                  icon: widget.withIcons ? PhosphorIcons.gear() : null,
                  variant: widget.variant,
                  size: widget.size,
                  enabled: widget.disabledTabId != 'tab3',
                ),
              ],
            ),
          ),
          const DsTabView(tabId: 'tab1', child: Text('Overview content')),
          const DsTabView(tabId: 'tab2', child: Text('Activity content')),
          const DsTabView(tabId: 'tab3', child: Text('Settings content')),
        ],
      ),
    );
  }
}
