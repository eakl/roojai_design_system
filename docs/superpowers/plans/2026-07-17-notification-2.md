# Notification 2 (`DsNotification`) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a new `notification_2` component (`DsNotification`) supporting an optional leading widget (icon or icon-container), an optional title, mandatory body text, and an optional bottom-right-aligned action row — top-aligned leading/content — without touching the existing `callout_2`.

**Architecture:** A hand-rolled `StatelessWidget` built directly on Mix's `Box` + plain Flutter `Row`/`Column` (no Remix primitive fits: `RemixCalloutSpec` has no title/actions slots). Three resolver functions produce a container `BoxStyler`, a title `TextStyler`, and a body `TextStyler`; a fourth resolves a `double` gap via `.resolve(context)` for the plain-widget layout. Registered in the example app's component catalog like every other `_2` component.

**Tech Stack:** Flutter (`package:flutter/widgets.dart`), Mix (`package:mix/mix.dart`) for `Box`/`BoxStyler`/`TextStyler`/`StyledText`, this repo's semantic token set (`lib/src/tokens/semantic/`).

## Global Constraints

- `callout_2`/`DsCallout` is left completely untouched — no edits to any file under `lib/src/components/callout_2/`.
- `text` is mandatory (`String`, non-nullable) — no `child` escape hatch, unlike `DsDialog`.
- `leading` is `Widget?` (not `IconData?`) — callers pass a fully-built `Icon`/`IconContainer`.
- Variant set: `DsNotificationVariant { neutral, brand, positive, negative, warning }`. Size set: `DsNotificationSize { sm, md, lg }`.
- Border radius `$radius008()` on the container, matching every other `_2` component.
- No dismiss button, no auto-dismiss timer, no animation — static content only.
- Full spec: `docs/superpowers/specs/2026-07-17-notification-2-component-design.md`.

---

## File Structure

```
lib/src/components/notification_2/
  notification_2.dart                 — DsNotification widget
  notification_2_style_resolver.dart  — part of notification_2.dart; 4 resolver fns
  notification_2_variants.dart        — DsNotificationVariant, DsNotificationSize enums
lib/ui.dart                           — MODIFY: add 2 export lines
example/lib/catalog/specs/notification_2_showcase_spec.dart — new catalog spec
example/lib/catalog/component_registry.dart                 — MODIFY: import + register
```

---

### Task 1: `DsNotificationVariant` / `DsNotificationSize` enums

**Files:**
- Create: `lib/src/components/notification_2/notification_2_variants.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum DsNotificationVariant { neutral, brand, positive, negative, warning }`, `enum DsNotificationSize { sm, md, lg }` — consumed by Tasks 2 and 3.

There is no test framework in this package (`lib/` has no `test/` directory — verification for this component family is `flutter analyze` + the running catalog app, same as every existing `_2` component). This task's own verification is just that the file analyzes cleanly.

- [ ] **Step 1: Write the enums file**

```dart
enum DsNotificationVariant { neutral, brand, positive, negative, warning }

enum DsNotificationSize { sm, md, lg }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze lib/src/components/notification_2/notification_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/notification_2/notification_2_variants.dart
git commit -m "feat(notification_2): add DsNotificationVariant/DsNotificationSize enums"
```

---

### Task 2: Style resolver — container, title, text, gap

**Files:**
- Create: `lib/src/components/notification_2/notification_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsNotificationVariant`, `DsNotificationSize` from Task 1 (`notification_2_variants.dart`); semantic tokens `$radius008`, `$spacing008/012/016/020`, `$neutralSurface/$brandSurface/$positiveSurface/$negativeSurface/$warningSurface`, `$neutralText/$brandText/$positiveText/$negativeText/$warningText`, `$labelSm/$labelMd/$labelLg`, `$bodySm/$bodyMd/$bodyLg` from `lib/src/tokens/semantic/{radius,spacing,colors,typography}.dart`.
- Produces (consumed by Task 3's `build()`):
  - `BoxStyler resolveDsNotificationContainerStyle({required DsNotificationVariant variant, required DsNotificationSize size})`
  - `TextStyler resolveDsNotificationTitleStyle({required DsNotificationVariant variant, required DsNotificationSize size})`
  - `TextStyler resolveDsNotificationTextStyle({required DsNotificationVariant variant, required DsNotificationSize size})`
  - `double resolveDsNotificationGap(BuildContext context, DsNotificationSize size)`

This file is a `part of 'notification_2.dart'` (declared here; the `part 'notification_2_style_resolver.dart';` directive is added to `notification_2.dart` in Task 3, since a `part` file cannot be analyzed standalone without its library — Task 3 creates that library file). Write this file's content now; full analysis happens once Task 3 wires the `part`/`part of` pair together.

- [ ] **Step 1: Write the style resolver file**

```dart
part of 'notification_2.dart';

// Resolver functions for DsNotification. Split into container/title/text/gap
// (rather than one composite style, the way `resolveDsCalloutStyle` returns
// a single `RemixCalloutStyler`) because there is no composite Remix spec
// backing this hand-rolled component — see the class doc comment in
// notification_2.dart for why this isn't built on RemixCallout.

BoxStyler resolveDsNotificationContainerStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsNotificationSize.md =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsNotificationSize.lg =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  final variantStyle = switch (variant) {
    DsNotificationVariant.neutral => BoxStyler().color($neutralSurface()),
    DsNotificationVariant.brand => BoxStyler().color($brandSurface()),
    DsNotificationVariant.positive => BoxStyler().color($positiveSurface()),
    DsNotificationVariant.negative => BoxStyler().color($negativeSurface()),
    DsNotificationVariant.warning => BoxStyler().color($warningSurface()),
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(sizeStyle)
      .merge(variantStyle);
}

TextStyler resolveDsNotificationTitleStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $labelSm.mix()),
    DsNotificationSize.md => TextStyler(style: $labelMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $labelLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant));
}

TextStyler resolveDsNotificationTextStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $bodySm.mix()),
    DsNotificationSize.md => TextStyler(style: $bodyMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $bodyLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant));
}

/// Shared by [resolveDsNotificationTitleStyle] and
/// [resolveDsNotificationTextStyle] — both text slots use the same
/// variant-paired `*Text` foreground color, only their type size differs.
Color _resolveDsNotificationTextColor(DsNotificationVariant variant) {
  return switch (variant) {
    DsNotificationVariant.neutral => $neutralText(),
    DsNotificationVariant.brand => $brandText(),
    DsNotificationVariant.positive => $positiveText(),
    DsNotificationVariant.negative => $negativeText(),
    DsNotificationVariant.warning => $warningText(),
  };
}

/// Gap between leading/title/text/actions in the hand-rolled Row/Column
/// layout. Needs [context] (unlike the three resolvers above) because it
/// feeds a plain `SizedBox`/`Row.spacing`, not a `Styler`'s fluent chain —
/// same reasoning `toggle_group_2_style_resolver.dart`'s `_resolveGap`
/// documents.
double resolveDsNotificationGap(BuildContext context, DsNotificationSize size) {
  return switch (size) {
    DsNotificationSize.sm => $spacing008.resolve(context),
    DsNotificationSize.md => $spacing012.resolve(context),
    DsNotificationSize.lg => $spacing016.resolve(context),
  };
}
```

- [ ] **Step 2: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/notification_2/notification_2_style_resolver.dart
git commit -m "feat(notification_2): add style resolver functions"
```

(Analysis of this file happens in Task 3, Step 2, once the `part`/`part of` library pair exists.)

---

### Task 3: `DsNotification` widget

**Files:**
- Create: `lib/src/components/notification_2/notification_2.dart`

**Interfaces:**
- Consumes: `DsNotificationVariant`/`DsNotificationSize` (Task 1); `resolveDsNotificationContainerStyle`/`resolveDsNotificationTitleStyle`/`resolveDsNotificationTextStyle`/`resolveDsNotificationGap` (Task 2).
- Produces: `class DsNotification extends StatelessWidget` with constructor `DsNotification({Key? key, Widget? leading, String? title, required String text, List<Widget>? actions, DsNotificationVariant variant = DsNotificationVariant.neutral, DsNotificationSize size = DsNotificationSize.md, BoxStyler? style, TextStyler? titleStyle, TextStyler? textStyle})` — consumed by Task 4 (catalog spec) and Task 5 (`ui.dart` export).

- [ ] **Step 1: Write the widget file**

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'notification_2_variants.dart';

// The `resolveDsNotification*` functions consumed by `build()` below live
// in notification_2_style_resolver.dart, split out as `part of` this
// library (not a separate import) so they stay private to DsNotification
// while living in their own file — same split as `DsButton`'s
// `button_2_style_resolver.dart`.
part 'notification_2_style_resolver.dart';

/// A content block combining an optional leading visual, an optional
/// title, mandatory body text, and an optional trailing-aligned action
/// row — e.g. an inline alert or notification card.
///
/// Unlike [DsCallout] (built on `remix`'s `RemixCallout`, which only lays
/// out a flat `[icon, text]` row), [DsNotification] is hand-rolled on top
/// of Mix's [Box] plus plain [Row]/[Column]: `RemixCalloutSpec` has no
/// title or actions slot, so extending it would mean bypassing its
/// built-in icon/text rendering anyway. [DsCallout] itself is untouched —
/// this is a new, separate component, not a replacement.
///
/// No interaction states (hover/press/focus/disabled) to resolve — like
/// [DsCallout], this only varies along [variant] (semantic color
/// treatment) and [size]. No `child` escape hatch either: [text] is always
/// required and always rendered.
class DsNotification extends StatelessWidget {
  const DsNotification({
    super.key,
    this.leading,
    this.title,
    required this.text,
    this.actions,
    this.variant = DsNotificationVariant.neutral,
    this.size = DsNotificationSize.md,
    this.style,
    this.titleStyle,
    this.textStyle,
  });

  /// Leading visual, top-aligned with the title/text column. A caller-built
  /// widget (typically [Icon] or [IconContainer]) rather than an
  /// `IconData` — the caller decides whether it renders as a bare glyph or
  /// a background-square icon container.
  final Widget? leading;

  /// Optional heading, rendered above [text].
  final String? title;

  /// Body message. Always required and always rendered.
  final String text;

  /// Optional action widgets (typically [DsButton]s), rendered in a
  /// trailing-aligned row below [text].
  final List<Widget>? actions;

  /// Semantic color treatment — see [DsNotificationVariant].
  final DsNotificationVariant variant;

  /// Physical size — see [DsNotificationSize].
  final DsNotificationSize size;

  /// Escape hatch merged onto the resolved container style.
  final BoxStyler? style;

  /// Escape hatch merged onto the resolved title text style.
  final TextStyler? titleStyle;

  /// Escape hatch merged onto the resolved body text style.
  final TextStyler? textStyle;

  @override
  Widget build(BuildContext context) {
    final resolvedContainerStyle = resolveDsNotificationContainerStyle(
      variant: variant,
      size: size,
    ).merge(style);

    final resolvedTitleStyle = resolveDsNotificationTitleStyle(
      variant: variant,
      size: size,
    ).merge(titleStyle);

    final resolvedTextStyle = resolveDsNotificationTextStyle(
      variant: variant,
      size: size,
    ).merge(textStyle);

    final gap = resolveDsNotificationGap(context, size);
    final hasActions = actions != null && actions!.isNotEmpty;

    return Box(
      style: resolvedContainerStyle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: gap)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  StyledText(title!, style: resolvedTitleStyle),
                  SizedBox(height: gap),
                ],
                StyledText(text, style: resolvedTextStyle),
                if (hasActions) ...[
                  SizedBox(height: gap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: gap,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify the library analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze lib/src/components/notification_2/`
Expected: `No issues found!`

If it fails, the most likely causes are: a missing import (`package:mix/mix.dart` must export `Box`, `BoxStyler`, `TextStyler`, `StyledText` — confirmed already used this way in `icon_container_2/icon_container.dart` and `icon_2/icon.dart`), or a token accessor typo (compare against `lib/src/tokens/semantic/{colors,radius,spacing,typography}.dart`).

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/notification_2/notification_2.dart
git commit -m "feat(notification_2): add DsNotification widget"
```

---

### Task 4: Catalog showcase spec

**Files:**
- Create: `example/lib/catalog/specs/notification_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsNotification`, `DsNotificationVariant`, `DsNotificationSize` (Task 3, once exported — see Task 5; the catalog imports `package:ui/ui.dart`, not the `lib/src/...` path directly, matching every existing spec file); `Icon`, `IconContainer`, `DsButton` (existing components); `ComponentShowcaseSpec` (`example/lib/catalog/component_showcase_spec.dart`).
- Produces: `ComponentShowcaseSpec buildNotification2ShowcaseSpec()` — registered into `componentRegistry` in this same task.

This task must run *after* Task 5 (the `ui.dart` export), since the catalog imports `DsNotification` via `package:ui/ui.dart`. Reorder if executing out of plan order: do Task 5 before Task 4.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:flutter/widgets.dart';
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
```

- [ ] **Step 2: Register in the component registry**

In `example/lib/catalog/component_registry.dart`, add the import alphabetically among the existing `specs/*_showcase_spec.dart` imports:

```dart
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
import 'specs/notification_2_showcase_spec.dart';
import 'specs/popover_2_showcase_spec.dart';
```

And add the registry entry alphabetically in the `componentRegistry` map:

```dart
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
  'Notification 2': buildNotification2ShowcaseSpec,
  'Popover 2': buildPopover2ShowcaseSpec,
```

(Exact neighboring lines depend on the current file contents — insert alphabetically relative to whatever is actually there; the import list already confirmed to include `input_2` and `popover_2` entries adjacent to where `notification_2` sorts.)

- [ ] **Step 3: Verify the example app analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai/example && flutter analyze lib/catalog/`
Expected: `No issues found!`

- [ ] **Step 4: Run the catalog app and visually verify**

Run: `cd /Users/eakl/dev/projects/roojai/example && flutter run -d macos` (or any available desktop/simulator device)

In the running app, navigate to "Notification 2" and confirm:
- Leading icon and text/title column are top-aligned (not center-aligned).
- The "with an actions row" state shows two buttons bottom-right aligned below the text.
- All 5 variants render with distinct background/text colors matching their semantic meaning.
- All 3 sizes visibly scale padding/text/icon-gap.

Stop the app once confirmed (Ctrl+C in the terminal running it).

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/notification_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(notification_2): register catalog showcase spec"
```

---

### Task 5: Export from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart:34-37` (insert alphabetically after the `card_2` exports, before whatever currently follows — confirmed current content: `callout_2` at lines 34-35, `card_2` at lines 36-37)

**Interfaces:**
- Consumes: `notification_2/notification_2.dart`, `notification_2/notification_2_variants.dart` (Task 1 and Task 3).
- Produces: `DsNotification`, `DsNotificationVariant`, `DsNotificationSize` become part of `package:ui/ui.dart`'s public surface — consumed by Task 4's catalog spec.

**Run this task before Task 4** — Task 4's showcase spec imports `package:ui/ui.dart` and needs these exports to exist first.

- [ ] **Step 1: Add the export lines**

In `lib/ui.dart`, immediately after the existing `card_2` export lines:

```dart
export 'src/components/card_2/card_2.dart';
export 'src/components/card_2/card_2_variants.dart';
export 'src/components/notification_2/notification_2.dart';
export 'src/components/notification_2/notification_2_variants.dart';
```

- [ ] **Step 2: Verify the whole package analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/ui.dart
git commit -m "feat(notification_2): export DsNotification from ui.dart"
```

---

## Suggested Execution Order

Tasks 1 → 2 → 3 → 5 → 4 (Task 5 must precede Task 4 despite the numbering, since Task 4's catalog spec imports the `ui.dart` exports Task 5 adds).
