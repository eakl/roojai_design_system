# list_2 (`DsList`/`DsListItem`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsList` (a container with optional border, optional header row, and body padding/gap/separator controls) and `DsListItem` (a leading/title/subtitle/trailing row, optionally pressable) to the design system, per `docs/superpowers/specs/2026-07-19-list-2-component-design.md`.

**Architecture:** One new `lib/src/components/list_2/` directory with three files (`list_2_variants.dart`, `list_2.dart`, `list_2_style_resolver.dart`), following the exact file split `card_2`/`label_2`/`tabs_2` already use. `DsListItem` is a hand-rolled `StatelessWidget` (no Remix widget to wrap — none exists for lists), using Mix's `Box`/`PressableBox`/`StyledText` primitives directly, the same approach `label_2`/`icon_2` use. `DsList` composes `DsListItem`s and `separator_2`'s `DsSeparator` inside a plain `Column`.

**Tech Stack:** Dart, Flutter (SDK floor `>=3.19.0`, so no `Column(spacing:)` — that's a 3.27+ API), `mix` (`Box`, `PressableBox`, `BoxStyler`, `StyledText`, `TextStyler`), `remix`'s `separator_2` (`DsSeparator`).

## Global Constraints

- No test suite exists in this repo (`ui` package or `example` app) beyond one ad hoc regression test (`example/test/card_2_mouse_tracker_repro_test.dart`) — verification is via `dart analyze`/`flutter analyze` after each change, plus a final manual check that the catalog app builds and the new List 2 showcase page renders every variant/size/state combination correctly. This mirrors the precedent already established in `docs/superpowers/plans/2026-07-18-card-2-variant-trim.md`.
- **Token-resolution trap:** `SpaceToken`/`ColorToken`/etc.'s bare `call()` (e.g. `$spacing008()`) returns a sentinel value meant to be captured inside a Mix `Prop`/`Styler` pipeline (`.padding(EdgeInsetsGeometryMix.all($spacing008()))`, `.color($neutralUiHover())`) — it is **not** a real pixel/color value. Any token used directly in a plain Flutter widget outside a `Styler` (e.g. a raw `SizedBox(height: ...)` in a `Column`) **must** call `.resolve(context)` instead (e.g. `$spacing008.resolve(context)`), the same pattern `card_2.dart`'s `_resolveDsCardForegroundColor` already uses for `$contentOnBrand.resolve(context)`. Every step below that builds a bare `SizedBox` spacer follows this rule — do not "simplify" it back to a bare token call.
- Follow existing code-comment conventions (explain *why*, not *what*) — see `card_2_style_resolver.dart` for tone.
- No `style`/`styleSpec` escape hatches on `DsList`/`DsListItem` — neither wraps a Remix widget with its own `Styler` type, same reasoning `label_2` documents for omitting them.

---

### Task 1: `DsListSize` enum

**Files:**
- Create: `/Users/eakl/dev/projects/roojai/lib/src/components/list_2/list_2_variants.dart`

**Interfaces:**
- Produces: `enum DsListSize { sm, md, lg }`, consumed by Task 2 (`DsListItem`) and Task 3 (`DsList`).

- [ ] **Step 1: Create the file**

```dart
enum DsListSize { sm, md, lg }
```

- [ ] **Step 2: Verify it's syntactically valid**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/list_2/list_2_variants.dart`
Expected: No errors (this file has no dependents yet).

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/list_2/list_2_variants.dart
git commit -m "list_2: add DsListSize enum"
```

---

### Task 2: `DsListItem` widget + its style resolver

**Files:**
- Create: `/Users/eakl/dev/projects/roojai/lib/src/components/list_2/list_2.dart`
- Create: `/Users/eakl/dev/projects/roojai/lib/src/components/list_2/list_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsListSize` (Task 1); design-system tokens `$spacing008/012/016/020` (`theme/light/spacing.dart`), `$radius008` (`theme/light/radius.dart`), `$contentPrimary`/`$contentSecondary`/`$contentPlaceholder`/`$neutralUiHover`/`$borderStrong` (`theme/light/colors.dart`), `$bodySm/Md/Lg`/`$captionSm/Md` (`theme/light/typography.dart`); Mix's `Box`, `PressableBox`, `BoxStyler`, `StyledText`, `TextStyler`, `EdgeInsetsGeometryMix` (`package:mix/mix.dart`).
- Produces: `class DsListItem extends StatelessWidget` (fields: `title`, `subtitle`, `leading`, `trailing`, `size`, `enabled`, `onTap`) and `resolveDsListItemStyle({required DsListSize size, required bool disabled, required bool interactive})` returning `({BoxStyler container, TextStyler title, TextStyler subtitle})` — both consumed by Task 3 (`DsList` renders a `List<DsListItem>` and an optional `DsListItem? header`) and Task 5 (catalog showcase).

- [ ] **Step 1: Write `list_2.dart`**

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import 'list_2_variants.dart';

// The `resolveDsListItemStyle`/`resolveDsListStyle` functions consumed by
// `build()` below live in list_2_style_resolver.dart, split out as `part
// of` this library so they stay private to this file's widgets while
// living in their own file — same split as `card_2`'s
// `card_2_style_resolver.dart`. Dart requires a `part of` file's imports to
// be declared in the library file itself, which is why `colors.dart`/
// `spacing.dart`/`typography.dart` are imported here even though only the
// (not-yet-written) style resolver uses them directly.
part 'list_2_style_resolver.dart';

/// A single row within a [DsList] — an optional leading widget, a title,
/// an optional subtitle, and an optional trailing widget.
///
/// Unlike `card_2`/`label_2`, there is no Remix widget to wrap (no
/// `RemixListItem` exists), so [DsListItem] is a plain `StatelessWidget`
/// built directly on Mix's `Box`/`PressableBox`/`StyledText` primitives —
/// the same approach `label_2` uses for `StyledText`/`TextStyler`.
///
/// [onTap] being non-null (and [enabled] being true) is what makes a row
/// interactive — same "presence of the callback decides interactivity"
/// convention `DsIconButton.onPressed`/`RemixButton.onPressed` already
/// use. A non-interactive row renders as a plain `Box` with no
/// hover/press styling and no button semantics, since it has no tap
/// affordance to show.
class DsListItem extends StatelessWidget {
  const DsListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.size = DsListSize.md,
    this.enabled = true,
    this.onTap,
  });

  /// Primary text, always shown.
  final String title;

  /// Optional secondary text shown below [title].
  final String? subtitle;

  /// Optional leading slot — icon, `DsAvatar`, or any other widget.
  final Widget? leading;

  /// Optional trailing slot — icon, badge, switch, or any other widget.
  final Widget? trailing;

  /// Physical size — see [DsListSize]. Controls row padding and
  /// title/subtitle text scale. Applied per-item since each [DsListItem]
  /// is an independent sibling — callers composing a [DsList] should pass
  /// the same [size] to each item and to the list itself, same convention
  /// as `DsTabsSize`/`DsTab.size`.
  final DsListSize size;

  /// Public state: renders muted and suppresses [onTap] when false. Never
  /// inferred — always driven by this constructor param, same convention
  /// as [DsIconButton.enabled].
  final bool enabled;

  /// Called on tap. When null, the row renders as a static (non-pressable)
  /// row. Ignored while [enabled] is false.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onTap != null;
    final resolved = resolveDsListItemStyle(
      size: size,
      disabled: !enabled,
      interactive: interactive,
    );

    // A per-size, fixed gap between leading/title-block/trailing — not a
    // separately requested axis, so it isn't its own field, just derived
    // from `size` alongside the row's own padding.
    final iconGap = switch (size) {
      DsListSize.sm => $spacing008.resolve(context),
      DsListSize.md => $spacing008.resolve(context),
      DsListSize.lg => $spacing012.resolve(context),
    };

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, SizedBox(width: iconGap)],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(title, style: resolved.title),
              if (subtitle != null)
                StyledText(subtitle!, style: resolved.subtitle),
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: iconGap), trailing!],
      ],
    );

    if (!interactive) {
      return Box(style: resolved.container, child: content);
    }

    return PressableBox(
      style: resolved.container,
      onPress: onTap,
      enabled: enabled,
      child: content,
    );
  }
}
```

- [ ] **Step 2: Write `list_2_style_resolver.dart`**

```dart
part of 'list_2.dart';

/// Resolves the row style for a [DsListItem].
///
/// `container` carries padding (by [size]) plus, when [interactive],
/// `.onHovered()`/`.onPressed()` background variants — the exact
/// declarative state-styling idiom `button_2_style_resolver.dart` already
/// uses for `RemixButtonStyler`, applied here to a plain `BoxStyler`
/// instead (Mix's `WidgetStateVariantMixin` is available on any
/// `MixStyler`, not just Remix-generated ones). `title`/`subtitle` are
/// `TextStyler`s dimmed to `$contentPlaceholder()` when [disabled], same
/// treatment `label_2_style_resolver.dart` applies for its own `disabled`
/// state.
({BoxStyler container, TextStyler title, TextStyler subtitle})
resolveDsListItemStyle({
  required DsListSize size,
  required bool disabled,
  required bool interactive,
}) {
  final paddingStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing012(),
        vertical: $spacing008(),
      ),
    ),
    DsListSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing016(),
        vertical: $spacing012(),
      ),
    ),
    DsListSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.symmetric(
        horizontal: $spacing020(),
        vertical: $spacing016(),
      ),
    ),
  };

  final interactiveStyle = interactive
      ? BoxStyler()
            .onHovered(BoxStyler().backgroundColor($neutralUiHover()))
            .onPressed(BoxStyler().backgroundColor($neutralUiHover()))
      : BoxStyler();

  final titleToken = switch (size) {
    DsListSize.sm => $bodySm.mix(),
    DsListSize.md => $bodyMd.mix(),
    DsListSize.lg => $bodyLg.mix(),
  };
  final subtitleToken = switch (size) {
    DsListSize.sm => $captionSm.mix(),
    DsListSize.md => $captionMd.mix(),
    // No $captionLg token exists — cap subtitle scale at $captionMd.
    DsListSize.lg => $captionMd.mix(),
  };

  final titleColor = disabled ? $contentPlaceholder() : $contentPrimary();
  final subtitleColor = disabled
      ? $contentPlaceholder()
      : $contentSecondary();

  return (
    container: paddingStyle.merge(interactiveStyle),
    title: TextStyler().style(titleToken).color(titleColor),
    subtitle: TextStyler().style(subtitleToken).color(subtitleColor),
  );
}
```

- [ ] **Step 3: Verify it compiles**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/list_2/`
Expected: No errors. (Warnings about `DsList`/`resolveDsListStyle` not existing yet are NOT expected here — `list_2.dart` at this point only defines `DsListItem`, nothing references a `DsList` type yet.)

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/list_2/list_2.dart lib/src/components/list_2/list_2_style_resolver.dart
git commit -m "list_2: add DsListItem widget and its style resolver"
```

---

### Task 3: `DsList` container widget + its style resolver

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/list_2/list_2.dart`
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/list_2/list_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsListItem` (Task 2), `DsListSize` (Task 1), `separator_2`'s `DsSeparator` (`../separator_2/separator_2.dart`, constructor `const DsSeparator({orientation, length, style, styleSpec})`, all optional — `const DsSeparator()` renders a full-width horizontal line), `$radius008` (`theme/light/radius.dart`), `$borderStrong` (`theme/light/colors.dart`).
- Produces: `class DsList extends StatelessWidget` (fields: `children`, `header`, `bordered`, `separated`, `size`) and `resolveDsListStyle({required bool bordered, required DsListSize size})` returning `BoxStyler` — consumed by Task 5 (catalog showcase).

- [ ] **Step 1: Add the `DsSeparator` and `$radius008` imports to `list_2.dart`**

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
import '../separator_2/separator_2.dart';
import 'list_2_variants.dart';

part 'list_2_style_resolver.dart';
```

- [ ] **Step 2: Append `DsList` to `list_2.dart`** (after the `DsListItem` class)

```dart
/// A vertical list container — an optional bordered outline, an optional
/// header [DsListItem] set apart by an unconditional separator, and a
/// body of [children] with size-driven padding/gap and an optional
/// [DsSeparator] between consecutive rows.
///
/// Single widget, not split into a separate "list body" type — the outer
/// container concerns ([bordered], [header]) and the body concerns
/// (padding, gap, [separated]) are all just configuration of the one
/// container, matching `card_2`'s single-widget shape.
class DsList extends StatelessWidget {
  const DsList({
    super.key,
    required this.children,
    this.header,
    this.bordered = false,
    this.separated = false,
    this.size = DsListSize.md,
  });

  /// The rows shown in the list body, in order.
  final List<DsListItem> children;

  /// Optional row shown above the body, visually set apart by an
  /// unconditional separator — independent of [separated].
  final DsListItem? header;

  /// Outer border treatment. `true` draws a `$radius008`/`$borderStrong`
  /// border around the whole container (background stays transparent),
  /// same tokens `card_2`'s `bordered` variant uses. `false` draws
  /// neither — the list sits flush in its parent's surface.
  final bool bordered;

  /// Whether consecutive body rows are separated by a `DsSeparator`
  /// (`separator_2`). Does not affect the header/body divider, which is
  /// always drawn when [header] is set.
  final bool separated;

  /// Physical size — see [DsListSize]. Controls the body's outer padding
  /// and the gap between rows.
  final DsListSize size;

  @override
  Widget build(BuildContext context) {
    final containerStyle = resolveDsListStyle(bordered: bordered, size: size);
    final gap = switch (size) {
      DsListSize.sm => $spacing008.resolve(context),
      DsListSize.md => $spacing012.resolve(context),
      DsListSize.lg => $spacing016.resolve(context),
    };

    final rows = <Widget>[];
    if (header != null) {
      rows.add(header!);
      rows.add(const DsSeparator());
    }
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        if (separated) {
          rows.add(SizedBox(height: gap / 2));
          rows.add(const DsSeparator());
          rows.add(SizedBox(height: gap / 2));
        } else {
          rows.add(SizedBox(height: gap));
        }
      }
      rows.add(children[i]);
    }

    return Box(
      style: containerStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
```

- [ ] **Step 3: Append `resolveDsListStyle` to `list_2_style_resolver.dart`**

```dart
/// Resolves the outer container style for a [DsList].
///
/// `bordered: true` reuses `card_2`'s `bordered`-variant tokens
/// (`$radius008`/`$borderStrong`, transparent background) so a bordered
/// list reads consistently with a bordered card. `bordered: false` adds
/// no border/radius/background at all — the list sits flush in its
/// parent's surface.
BoxStyler resolveDsListStyle({
  required bool bordered,
  required DsListSize size,
}) {
  final sizeStyle = switch (size) {
    DsListSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing012()),
    ),
    DsListSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing016()),
    ),
    DsListSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing020()),
    ),
  };

  final borderedStyle = bordered
      ? BoxStyler()
            .borderRadiusAll($radius008())
            .borderAll(color: $borderStrong(), width: 1)
      : BoxStyler();

  return sizeStyle.merge(borderedStyle);
}
```

- [ ] **Step 4: Verify it compiles**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/list_2/`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/list_2/list_2.dart lib/src/components/list_2/list_2_style_resolver.dart
git commit -m "list_2: add DsList container widget and its style resolver"
```

---

### Task 4: Export from `lib/ui.dart`

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/ui.dart:62`

**Interfaces:**
- Consumes: `list_2/list_2.dart`, `list_2/list_2_variants.dart` (Tasks 1–3).
- Produces: public `package:ui/ui.dart` exports for `DsList`, `DsListItem`, `DsListSize`, consumed by Task 5 (catalog) and any external caller.

- [ ] **Step 1: Insert two export lines after the `label_2` exports**

In `lib/ui.dart`, change:
```dart
export 'src/components/label_2/label_2.dart';
export 'src/components/label_2/label_2_variants.dart';
```
to:
```dart
export 'src/components/label_2/label_2.dart';
export 'src/components/label_2/label_2_variants.dart';
export 'src/components/list_2/list_2.dart';
export 'src/components/list_2/list_2_variants.dart';
```

- [ ] **Step 2: Verify the package still analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/ui.dart
git commit -m "list_2: export DsList/DsListItem/DsListSize"
```

---

### Task 5: Catalog showcase spec + registry

**Files:**
- Create: `/Users/eakl/dev/projects/roojai/example/lib/catalog/specs/list_2_showcase_spec.dart`
- Modify: `/Users/eakl/dev/projects/roojai/example/lib/catalog/component_registry.dart` (both the spec-builder import list and the `componentRegistry` map live here — `component_showcase_spec.dart` only defines the `ComponentShowcaseSpec` class itself, nothing to register)

**Interfaces:**
- Consumes: `DsList`, `DsListItem`, `DsListSize` (Task 4), `Icon`/`Icons` (`package:ui/ui.dart` + `package:flutter/material.dart show Icons`, same pattern `icon_2_showcase_spec.dart` uses), `ComponentShowcaseSpec` (`../component_showcase_spec.dart`).
- Produces: `ComponentShowcaseSpec buildList2ShowcaseSpec()`, registered under key `'List 2'`.

- [ ] **Step 1: Create `list_2_showcase_spec.dart`**

```dart
import 'package:flutter/material.dart' show Icons;
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildList2ShowcaseSpec() {
  List<DsListItem> sampleItems() => const [
    DsListItem(title: 'Notifications', subtitle: 'Push and email alerts'),
    DsListItem(title: 'Privacy', subtitle: 'Control who can see your data'),
    DsListItem(title: 'Security', subtitle: 'Two-factor authentication'),
  ];

  return ComponentShowcaseSpec(
    title: 'List 2',
    sizesBuilder: () => DsListSize.values
        .map((size) => DsList(size: size, bordered: true, children: sampleItems()))
        .toList(),
    variantsBuilder: () => [
      DsList(bordered: false, children: sampleItems()),
      DsList(bordered: true, children: sampleItems()),
    ],
    statesBuilder: () => [
      DsList(bordered: true, separated: true, children: sampleItems()),
      DsList(
        bordered: true,
        header: const DsListItem(title: 'Settings'),
        children: sampleItems(),
      ),
      DsList(
        bordered: true,
        children: [
          DsListItem(
            title: 'Home',
            leading: const Icon(Icons.home),
            trailing: const Icon(Icons.chevron_right),
          ),
          DsListItem(
            title: 'Profile',
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      DsList(
        bordered: true,
        children: [
          const DsListItem(
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
```

- [ ] **Step 2: Read `component_registry.dart` to confirm the exact import/map format before editing**

Run: `cd /Users/eakl/dev/projects/roojai && sed -n '1,60p' example/lib/catalog/component_registry.dart`
Expected: An import list (one `import 'specs/..._showcase_spec.dart';` line per component, alphabetical) followed by `final Map<String, ComponentShowcaseSpec Function()> componentRegistry = { ... }` with one `'Display Name': buildXShowcaseSpec,` entry per line, also alphabetical.

- [ ] **Step 3: Add the import, alphabetically after `label_2`**

Change:
```dart
import 'specs/label_2_showcase_spec.dart';
import 'specs/notification_2_showcase_spec.dart';
```
to:
```dart
import 'specs/label_2_showcase_spec.dart';
import 'specs/list_2_showcase_spec.dart';
import 'specs/notification_2_showcase_spec.dart';
```

- [ ] **Step 4: Add the registry entry, alphabetically after `'Label 2'`**

Change:
```dart
  'Label 2': buildLabel2ShowcaseSpec,
```
to:
```dart
  'Label 2': buildLabel2ShowcaseSpec,
  'List 2': buildList2ShowcaseSpec,
```
(keep whatever entry currently follows `'Label 2'` immediately after this new line, unchanged).

- [ ] **Step 5: Verify the example app analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai/example && flutter analyze`
Expected: No errors.

- [ ] **Step 6: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/list_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "list_2: add catalog showcase and register List 2"
```

---

### Task 6: Manual verification

**Files:** none (verification only).

- [ ] **Step 1: Run the full analyzer one more time from repo root**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/ && cd example && flutter analyze`
Expected: No errors in either.

- [ ] **Step 2: Launch the catalog app**

Run: `cd /Users/eakl/dev/projects/roojai/example && flutter run -d macos` (or whichever device/desktop target this repo normally uses to preview the catalog — check `example/README.md` or recent terminal history if unsure of the usual target).

- [ ] **Step 3: Open the "List 2" showcase page and manually confirm:**
  - `sizesBuilder`: three bordered lists (`sm`/`md`/`lg`) with visibly different padding/text scale.
  - `variantsBuilder`: an unbordered list next to a bordered one — visibly different outline.
  - `separated: true` list shows a divider line between each pair of rows, none above/below the whole list.
  - `header` list shows the header row set apart from the body by a line, even without `separated`.
  - The leading/trailing icon list shows icons aligned left/right of each title.
  - The disabled item renders dimmed and does not respond to tap/hover.
  - The "Tap me" item shows a hover/press background change and its `onTap` fires (add a temporary `debugPrint` if needed to confirm, then remove it — don't commit debug scaffolding).

- [ ] **Step 4: Stop the app; no commit for this task (verification only)**
