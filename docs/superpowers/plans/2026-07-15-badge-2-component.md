# badge_2 Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsBadge`, a thin wrapper around the `remix` package's `RemixBadge`, styled through this design system's Mix semantic tokens, replacing the legacy hand-rolled `Badge` in the `_2` migration.

**Architecture:** `DsBadge` is a `StatelessWidget` that resolves `(variant, size)` to a `RemixBadgeStyle` via a pure resolver function (`resolveDsBadgeStyle`, in a `part` file) and forwards it to `RemixBadge`, supplying a custom `labelBuilder` only when `leading`/`trailing` icon slots are used — same shape as `button_2`'s `DsButton`-on-`RemixButton` wrapper.

**Tech Stack:** Flutter, `mix` (`BoxStyler`, `BorderRadiusGeometryMix`, `ColorToken`, `RadiusToken`, `SpaceToken`, `TextStyleToken`), `remix` (`RemixBadge`, `RemixBadgeStyle`, `RemixBadgeSpec`, `TextSpec`).

## Global Constraints

- Follow `docs/superpowers/specs/2026-07-15-badge-2-component-design.md` exactly — file structure, enum values, style resolver mapping, and widget API are all specified there.
- `DsBadgeSize` = `sm, md, lg`. `DsBadgeVariant` = `primary, secondary, outline, ghost, positive, negative, warning, info, neutral` (9 values — legacy `destructive` is not ported; it maps onto `negative`).
- Border radius is `$radius004()` for every size (not a pill shape, not varied per size).
- No `disabled`/state axis, no `.animate(...)` — Badge stays non-interactive.
- No dedicated `backgroundColor`/`foregroundColor` params — use the `style` escape hatch instead (`RemixBadgeStyle().backgroundColor(...)`/`.foregroundColor(...)`).
- This package has no automated test suite — verification is `flutter analyze` (Flutter 3.41.9 / Dart 3.11.5 confirmed available in this environment) plus a manual read-through, not `flutter test`.

## File Structure

```
lib/src/components/badge_2/
  badge_2_variants.dart        # enum DsBadgeSize, enum DsBadgeVariant
  badge_2_style_resolver.dart  # part of 'badge_2.dart'; resolveDsBadgeStyle()
  badge_2.dart                 # DsBadge widget + `part` declaration
```

Modified:

```
lib/ui.dart                                            # uncomment/replace badge exports
example/lib/catalog/specs/badge_2_showcase_spec.dart    # new catalog showcase
example/lib/catalog/component_registry.dart             # register 'Badge 2'
```

---

### Task 1: Add the `DsBadgeSize`/`DsBadgeVariant` enums

**Files:**
- Create: `lib/src/components/badge_2/badge_2_variants.dart`

**Interfaces:**
- Produces: `enum DsBadgeSize { sm, md, lg }`, `enum DsBadgeVariant { primary, secondary, outline, ghost, positive, negative, warning, info, neutral }`, consumed by Task 2 and Task 3.

- [ ] **Step 1: Write the enums**

Create `lib/src/components/badge_2/badge_2_variants.dart`:

```dart
/// Physical size of a [DsBadge]. Drives padding, text style, and icon
/// gap/extent — see the `_resolve*`/`resolveDsBadgeStyle` functions in
/// `badge_2_style_resolver.dart` and `badge_2.dart`.
enum DsBadgeSize { sm, md, lg }

/// Visual treatment of a [DsBadge]. Each variant maps to its own
/// background/foreground color pair in `resolveDsBadgeStyle` — see
/// `badge_2_style_resolver.dart`.
///
/// Merges legacy `BadgeVariant`'s structural variants (`primary`,
/// `secondary`, `outline`, `ghost`) with the semantic status palette
/// available in `colors.dart` (`positive`, `negative`, `warning`, `info`,
/// `neutral`). Legacy `BadgeVariant.destructive` is not ported as its own
/// case — it resolved to the same tokens `negative` now uses.
enum DsBadgeVariant {
  /// Strongest visual weight — filled with the inverted surface.
  primary,

  /// Secondary emphasis — filled alternative surface.
  secondary,

  /// Outlined, transparent background — tertiary emphasis.
  outline,

  /// Transparent background, no border — lowest emphasis.
  ghost,

  /// Communicates a positive/success status.
  positive,

  /// Communicates a negative/error status (also covers legacy
  /// `destructive`'s use case).
  negative,

  /// Communicates a caution/warning status.
  warning,

  /// Communicates an informational status.
  info,

  /// Communicates a neutral/muted status.
  neutral,
}
```

- [ ] **Step 2: Verify the file parses as valid Dart**

Run: `grep -c "^enum" lib/src/components/badge_2/badge_2_variants.dart`
Expected: `2`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/badge_2/badge_2_variants.dart
git commit -m "feat(badge_2): add DsBadgeSize and DsBadgeVariant enums"
```

---

### Task 2: Add the style resolver

**Files:**
- Create: `lib/src/components/badge_2/badge_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsBadgeSize`/`DsBadgeVariant` from Task 1; `$radius004` from `lib/src/tokens/semantic/radius.dart`; `$spacing002`/`$spacing004`/`$spacing006`/`$spacing008`/`$spacing012`/`$spacing016` from `lib/src/tokens/semantic/spacing.dart`; `$captionSm`/`$captionMd`/`$labelSm` from `lib/src/tokens/semantic/typography.dart`; `$surfaceInverted`/`$surfaceAlternative`/`$contentOnBrand`/`$contentPrimary`/`$borderStrong`/`$positiveSurface`/`$positiveTextStrong`/`$negativeSurface`/`$negativeTextStrong`/`$warningSurface`/`$warningTextStrong`/`$infoSurface`/`$infoTextStrong`/`$neutralSurface`/`$neutralTextStrong` from `lib/src/tokens/semantic/colors.dart`.
- Produces: `RemixBadgeStyle resolveDsBadgeStyle({required DsBadgeVariant variant, required DsBadgeSize size})`, consumed by Task 3's `badge_2.dart`.

This file has an unresolved `part of 'badge_2.dart'` directive until Task 3 creates that file, so it cannot be analyzed in isolation — write it now, verify and commit alongside Task 3.

- [ ] **Step 1: Write the resolver file**

Create `lib/src/components/badge_2/badge_2_style_resolver.dart`:

```dart
part of 'badge_2.dart';

// Style resolver for DsBadge.
//
// Single entry point `resolveDsBadgeStyle` builds one `RemixBadgeStyle` by
// merging fragments — base, then size, then variant — mirroring the
// base/size/variant composition in `button_2_style_resolver.dart` (minus
// the state fragment: DsBadge has no `disabled`/interactive axis, same
// decision the legacy `Badge`'s doc comment already establishes — "always
// non-interactive").

/// Resolves the full `RemixBadgeStyle` for a [DsBadge], given its
/// [variant] and [size].
RemixBadgeStyle resolveDsBadgeStyle({
  required DsBadgeVariant variant,
  required DsBadgeSize size,
}) {
  final baseStyle = RemixBadgeStyle().borderRadius(
    BorderRadiusGeometryMix.circular($radius004()),
  );

  final sizeStyle = switch (size) {
    DsBadgeSize.sm => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing008())
            .paddingY($spacing002()),
        text: $captionSm.mix(),
      ),
    DsBadgeSize.md => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing012())
            .paddingY($spacing004()),
        text: $captionMd.mix(),
      ),
    DsBadgeSize.lg => RemixBadgeStyle(
        container: BoxStyler()
            .paddingX($spacing016())
            .paddingY($spacing006()),
        text: $labelSm.mix(),
      ),
  };

  const transparent = Color(0x00000000);

  final variantStyle = switch (variant) {
    DsBadgeVariant.primary => RemixBadgeStyle()
        .backgroundColor($surfaceInverted())
        .foregroundColor($contentOnBrand()),
    DsBadgeVariant.secondary => RemixBadgeStyle()
        .backgroundColor($surfaceAlternative())
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.outline => RemixBadgeStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary())
        .merge(
          RemixBadgeStyle(
            container: BoxStyler().borderAll(color: $borderStrong(), width: 1),
          ),
        ),
    DsBadgeVariant.ghost => RemixBadgeStyle()
        .backgroundColor(transparent)
        .foregroundColor($contentPrimary()),
    DsBadgeVariant.positive => RemixBadgeStyle()
        .backgroundColor($positiveSurface())
        .foregroundColor($positiveTextStrong()),
    DsBadgeVariant.negative => RemixBadgeStyle()
        .backgroundColor($negativeSurface())
        .foregroundColor($negativeTextStrong()),
    DsBadgeVariant.warning => RemixBadgeStyle()
        .backgroundColor($warningSurface())
        .foregroundColor($warningTextStrong()),
    DsBadgeVariant.info => RemixBadgeStyle()
        .backgroundColor($infoSurface())
        .foregroundColor($infoTextStrong()),
    DsBadgeVariant.neutral => RemixBadgeStyle()
        .backgroundColor($neutralSurface())
        .foregroundColor($neutralTextStrong()),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

- [ ] **Step 2: Proceed directly to Task 3**

Do not commit yet — this file's `part of` directive is unresolved until Task 3 creates `badge_2.dart`. Both are committed together there.

---

### Task 3: Add the `DsBadge` widget

**Files:**
- Create: `lib/src/components/badge_2/badge_2.dart`

**Interfaces:**
- Consumes: `resolveDsBadgeStyle` from Task 2; `DsBadgeSize`/`DsBadgeVariant` from Task 1; `RemixBadge`/`RemixBadgeStyle`/`RemixBadgeSpec` from `package:remix/remix.dart`; `TextSpec`, `BoxStyler`, `BorderRadiusGeometryMix` from `package:mix/mix.dart`.
- Produces: `class DsBadge extends StatelessWidget`, constructor `DsBadge({Key? key, required String label, Widget? leading, Widget? trailing, DsBadgeVariant variant = DsBadgeVariant.primary, DsBadgeSize size = DsBadgeSize.md, RemixBadgeStyle style = const RemixBadgeStyle.create(), RemixBadgeSpec? styleSpec})`. Consumed by Task 4's showcase spec and Task 5's `ui.dart` export.

- [ ] **Step 1: Write the widget**

Create `lib/src/components/badge_2/badge_2.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'badge_2_variants.dart';

// The `resolveDsBadgeStyle` function consumed by `build()` below lives in
// badge_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsBadge while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsSwitch`'s `switch_2_style_resolver.dart`.
part 'badge_2_style_resolver.dart';

/// A small status/label pill built on top of the `remix` package's
/// [RemixBadge], styled through the design system's Mix semantic tokens.
///
/// Unlike [DsBadge]'s closest sibling, [DsButton], this widget is always
/// non-interactive — it has no `onPressed` and derives no pressed/hover/
/// focus state. It exists purely to label or annotate other content
/// (status pills, counts, tags), matching how legacy `Badge` was a plain
/// `Container`/`Row` rather than a button. See
/// `docs/superpowers/specs/2026-07-15-badge-2-component-design.md`.
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.variant = DsBadgeVariant.primary,
    this.size = DsBadgeSize.md,
    this.style = const RemixBadgeStyle.create(),
    this.styleSpec,
  });

  /// The badge's text content. Always shown.
  final String label;

  /// Widget shown before [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent.
  final Widget? leading;

  /// Widget shown after [label] (typically an `Icon`), sized to
  /// [DsBadgeSize]'s icon extent.
  final Widget? trailing;

  /// Visual treatment — see [DsBadgeVariant].
  final DsBadgeVariant variant;

  /// Physical size — see [DsBadgeSize].
  final DsBadgeSize size;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsBadgeStyle]'s output). Replaces
  /// legacy `Badge`'s dedicated `backgroundColor`/`foregroundColor`
  /// params — same convention as [DsButton.style]/[DsSwitch.style]
  /// (`RemixBadgeStyle().backgroundColor(...)`/`.foregroundColor(...)`
  /// cover the same cases).
  final RemixBadgeStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixBadgeSpec] directly, bypassing style resolution entirely.
  final RemixBadgeSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsBadgeStyle(
      variant: variant,
      size: size,
    ).merge(style);

    return RemixBadge(
      label: label,
      style: resolvedStyle,
      styleSpec: styleSpec,
      labelBuilder: (leading == null && trailing == null)
          ? null
          : (context, spec, resolvedLabel) => _buildLabelWithIcons(
                spec: spec,
                label: resolvedLabel,
                leading: leading,
                trailing: trailing,
                size: size,
              ),
    );
  }
}

/// Builds [DsBadge]'s label content flanked by [leading]/[trailing] icon
/// slots, using the resolved [TextSpec]'s [TextSpec.style] for the text
/// run so the label matches [resolveDsBadgeStyle]'s size/variant text
/// styling exactly. Only invoked by [DsBadge.build] when at least one of
/// [leading]/[trailing] is non-null — ports legacy `Badge`'s icon-flanked
/// `Row` build.
Widget _buildLabelWithIcons({
  required TextSpec spec,
  required String label,
  required Widget? leading,
  required Widget? trailing,
  required DsBadgeSize size,
}) {
  final iconExtent = _iconExtentFor(size);
  final iconGap = _iconGapFor(size);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (leading != null) ...[
        SizedBox(width: iconExtent, height: iconExtent, child: leading),
        SizedBox(width: iconGap),
      ],
      Text(label, style: spec.style),
      if (trailing != null) ...[
        SizedBox(width: iconGap),
        SizedBox(width: iconExtent, height: iconExtent, child: trailing),
      ],
    ],
  );
}

/// Icon slot extent per [DsBadgeSize] — kept as plain `double` literals
/// (not Mix tokens) since icon sizing isn't part of [RemixBadgeStyle]'s
/// schema (`container`/`text` only), same reasoning legacy `Badge`'s
/// `_resolveIconExtent` already establishes.
double _iconExtentFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 10,
      DsBadgeSize.md => 12,
      DsBadgeSize.lg => 14,
    };

/// Icon-to-label gap per [DsBadgeSize] — ports legacy `Badge`'s
/// `_resolveIconGap` values.
double _iconGapFor(DsBadgeSize size) => switch (size) {
      DsBadgeSize.sm => 4,
      DsBadgeSize.md => 4,
      DsBadgeSize.lg => 6,
    };
```

- [ ] **Step 2: Verify both files with `flutter analyze`**

Run: `flutter analyze lib/src/components/badge_2`
Expected: `No issues found!`

If `flutter analyze` fails at dependency resolution (not at analysis of these files) because the local SDK doesn't satisfy `pubspec.yaml`'s constraints, do not claim the run passed. Instead, manually re-read `badge_2.dart` and `badge_2_style_resolver.dart` side by side and confirm: every symbol referenced (`RemixBadge`, `RemixBadgeStyle`, `RemixBadgeSpec`, `TextSpec`, `BoxStyler`, `BorderRadiusGeometryMix`, every `$token`, every `DsBadgeSize`/`DsBadgeVariant` case) is spelled exactly as declared in Task 1/Task 2, both switch statements in the resolver are exhaustive (one `case` per enum value, no `default`), and brace/paren nesting is balanced. State plainly that verification was manual review only, and why.

- [ ] **Step 3: Commit Tasks 2 and 3 together**

```bash
git add lib/src/components/badge_2/badge_2.dart lib/src/components/badge_2/badge_2_style_resolver.dart
git commit -m "feat(badge_2): add DsBadge widget on RemixBadge"
```

---

### Task 4: Add the catalog showcase spec and register it

**Files:**
- Create: `example/lib/catalog/specs/badge_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `DsBadge`, `DsBadgeVariant`, `DsBadgeSize`, `Icon` (from `package:ui/ui.dart`, once Task 5 exports them), `ComponentShowcaseSpec` (from `../component_showcase_spec.dart`), `PhosphorIcons` (from `package:phosphor_flutter/phosphor_flutter.dart`).
- Produces: `ComponentShowcaseSpec buildBadge2ShowcaseSpec()`, registered in `componentRegistry` under key `'Badge 2'`.

This task depends on Task 5's `ui.dart` export existing for `DsBadge`/`DsBadgeVariant`/`DsBadgeSize`/`Icon` to resolve — write and commit Task 5 first, or do Task 5 immediately before verifying this task. The plan lists exports last only because the showcase spec is what exercises them end-to-end; do Task 5 before running this task's verification step.

- [ ] **Step 1: Write the showcase spec**

Create `example/lib/catalog/specs/badge_2_showcase_spec.dart`:

```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildBadge2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Badge 2',
    variantsBuilder: () => DsBadgeVariant.values
        .map((variant) => DsBadge(label: variant.name, variant: variant))
        .toList(),
    sizesBuilder: () => DsBadgeSize.values
        .map((size) => DsBadge(label: size.name, size: size))
        .toList(),
    statesBuilder: () => [
      const DsBadge(label: 'plain'),
      DsBadge(
        label: 'with leading',
        leading: Icon(PhosphorIcons.circle()),
      ),
      DsBadge(
        label: 'with trailing',
        trailing: Icon(PhosphorIcons.circle()),
      ),
    ],
  );
}
```

- [ ] **Step 2: Register it in the component registry**

In `example/lib/catalog/component_registry.dart`, add the import in alphabetical order with the other spec imports:

```dart
import 'specs/badge_2_showcase_spec.dart';
```

(this goes before `import 'specs/button_2_showcase_spec.dart';`)

And add the map entry in alphabetical order:

```dart
  'Badge 2': buildBadge2ShowcaseSpec,
```

(this goes before `'Button 2': buildButton2ShowcaseSpec,`)

- [ ] **Step 3: Verify with `flutter analyze`**

Run (from `example/`): `flutter analyze lib/catalog`
Expected: `No issues found!`

If the SDK constraint issue from Task 3 applies here too, fall back to manual review: confirm `DsBadge`/`DsBadgeVariant`/`DsBadgeSize`/`Icon` are spelled exactly as declared/exported, the import ordering matches the file's existing alphabetical convention, and the map entry syntax matches its neighbors.

- [ ] **Step 4: Commit**

```bash
git add example/lib/catalog/specs/badge_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(badge_2): add catalog showcase and register it"
```

---

### Task 5: Export `badge_2` from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart:25-27`

**Interfaces:**
- Consumes: `lib/src/components/badge_2/badge_2.dart`, `lib/src/components/badge_2/badge_2_variants.dart` from Task 1/Task 3.
- Produces: public exports of `DsBadge`, `DsBadgeVariant`, `DsBadgeSize`, consumed by Task 4's showcase spec and any external caller of `package:ui/ui.dart`.

- [ ] **Step 1: Replace the commented-out legacy badge exports**

In `lib/ui.dart`, the file currently has (lines 25-27):

```dart
// export 'src/components/badge/badge.dart';
// export 'src/components/badge/badge_size.dart';
// export 'src/components/badge/badge_variant.dart';
```

Replace it with:

```dart
export 'src/components/badge_2/badge_2.dart';
export 'src/components/badge_2/badge_2_variants.dart';
```

- [ ] **Step 2: Verify**

Run: `grep -n "badge" lib/ui.dart`
Expected: two uncommented lines, `export 'src/components/badge_2/badge_2.dart';` and `export 'src/components/badge_2/badge_2_variants.dart';`, no remaining `// export .../badge/...` lines.

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "feat(badge_2): export DsBadge from ui.dart"
```

- [ ] **Step 4: Go back and finish Task 4's verification**

Task 4's `flutter analyze lib/catalog` step depends on this export existing — run it now if it wasn't already run after this commit.

---

## Self-Review Notes

- Spec coverage: file structure ✓ (Tasks 1/2/3), `DsBadgeSize`/`DsBadgeVariant` values incl. `destructive`→`negative` merge ✓ (Task 1), widget API (`label`/`leading`/`trailing`/`variant`/`size`/`style`/`styleSpec`, no `backgroundColor`/`foregroundColor` params) ✓ (Task 3), `labelBuilder`/icon-flanked `Row` behavior ✓ (Task 3), style resolver base/size/variant composition incl. fixed `$radius004` and `outline`-only border ✓ (Task 2), catalog registration (3-axis: variants/sizes/states) ✓ (Task 4), `ui.dart` export replacing commented-out legacy exports ✓ (Task 5).
- No placeholders — every step has complete, exact code; no "add appropriate X" phrasing.
- Type consistency checked: `resolveDsBadgeStyle({required DsBadgeVariant variant, required DsBadgeSize size})` signature in Task 2 matches its call site in Task 3's `build()` exactly; `_buildLabelWithIcons`'s named-parameter signature matches its call site; `_iconExtentFor`/`_iconGapFor` signatures match their call sites; `DsBadge` constructor field names/types in Task 3 match Task 4's showcase-spec usage (`label`, `variant`, `size`, `leading`, `trailing`) exactly; every `DsBadgeVariant`/`DsBadgeSize` enum case used in Task 2's switches matches Task 1's declared enum values one-to-one with no gaps.
