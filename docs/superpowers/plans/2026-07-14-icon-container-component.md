# IconContainer Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix a broken uncommitted token edit that `icon_2` already depends on, then add a design-system `IconContainer` widget — a rounded-square background chip rendering an `icon_2` `Icon` centered inside it, with background and glyph color both keyed off one `DsIconVariant`.

**Architecture:** `IconContainer` is a thin `StatelessWidget` that resolves `(size, variant)` to a `BoxStyler` (background color + fixed border radius + square dimensions) via a pure resolver function, wraps it around a `Center`-ed `icon_2` `Icon`, and renders through Mix's `Box` primitive — the same `Box`/`BoxStyler` primitive documented in `package:mix`, mirroring `icon_2`'s `Icon`-on-`StyledIcon` split and `button_2`'s style-resolver-as-`part`-file convention.

**Tech Stack:** Flutter, `mix` (`Box`, `BoxStyler`, `ColorToken`, `RadiusToken`), the existing `lib/src/components/icon_2` `Icon` widget and `DsIconVariant`/`DsIconSize` enums.

## Global Constraints

- Follow the working Mix-token pattern (`button_2`, `icon_2`), not the legacy `AppTokens.of(context)` pattern.
- `DsIconContainerSize` → (outer square dimension, inner `DsIconSize`): `sm=24/sm(16)`, `md=32/md(20)`, `lg=40/lg(24)`, `xl=56/xl(32)`. Outer dimensions are literal doubles, not spacing tokens — same precedent as `button_2_style_resolver.dart`'s `height(36/44/56)`.
- `DsIconVariant` → background color token: `neutral=$neutralSurface`, `brand=$brandSurface`, `positive=$positiveSurface`, `negative=$negativeSurface`, `warning=$warningSurface`. The glyph color is resolved by `icon_2`'s own existing resolver (unchanged) — `IconContainer` only supplies the background.
- Corner radius is a constant `$radius008` regardless of `size` — same precedent as `button_2` using one constant radius across all button sizes.
- No new `lib/ui.dart` export, no catalog `componentRegistry` entry — same as `icon_2`/`button_2`, neither of which is wired into either yet.
- This package has no automated test suite and the example app currently cannot build (legacy components reference deleted APIs) — verification is `flutter analyze`, not `flutter test`/`flutter run`. If the only local Flutter SDK is too old to satisfy this repo's `pubspec.yaml` constraints (`mix`/`remix` require Dart >=3.6.0; check with `flutter --version`), state that explicitly and fall back to manual side-by-side review instead of claiming a passing analyze run.

## File Structure

```
lib/src/components/icon_container/
  icon_container.dart                  # IconContainer widget + `part` declaration
  icon_container_size.dart             # enum DsIconContainerSize
  icon_container_style_resolver.dart   # part of 'icon_container.dart'
```

Modified:

```
lib/src/tokens/semantic/colors.dart    # fix broken Neutral token block
lib/src/theme/light/colors.dart        # fix broken Neutral token block
lib/src/components/icon_2/icon.dart    # drop dead `icon_size.dart` import
```

---

### Task 1: Fix the broken Neutral token block and `icon_2`'s dead import

**Files:**
- Modify: `lib/src/tokens/semantic/colors.dart:95-102`
- Modify: `lib/src/theme/light/colors.dart:94-101`
- Modify: `lib/src/components/icon_2/icon.dart:6`

**Interfaces:**
- Produces: `const $neutralSurface`, `$neutralSurfaceStrong`, `$neutralBorder`, `$neutralUi`, `$neutralUiHover`, `$neutralText`, `$neutralTextStrong` (all `ColorToken`s), importable from `lib/src/tokens/semantic/colors.dart`, resolving via `lightColors` to `AppColors.neutral050/neutral200/neutral500/neutral600/neutral700/neutral800` respectively (no `$neutralBorder` mapping, matching every sibling category's existing gap). Consumed by Task 3.

- [ ] **Step 1: Fix the token declarations**

In `lib/src/tokens/semantic/colors.dart`, the file currently ends with this broken block (lines 95-102, duplicate `$info*` names under a `// Neutral.` comment):

```dart
// Neutral.
const $infoSurface = ColorToken('color.neutral.surface');
const $infoSurfaceStrong = ColorToken('color.neutral.surfaceStrong');
const $infoBorder = ColorToken('color.neutral.border');
const $infoUi = ColorToken('color.neutral.ui');
const $infoUiHover = ColorToken('color.neutral.uiHover');
const $infoText = ColorToken('color.neutral.text');
const $infoTextStrong = ColorToken('color.neutral.textStrong');
```

Replace it with:

```dart
// Neutral.
const $neutralSurface = ColorToken('color.neutral.surface');
const $neutralSurfaceStrong = ColorToken('color.neutral.surfaceStrong');
const $neutralBorder = ColorToken('color.neutral.border');
const $neutralUi = ColorToken('color.neutral.ui');
const $neutralUiHover = ColorToken('color.neutral.uiHover');
const $neutralText = ColorToken('color.neutral.text');
const $neutralTextStrong = ColorToken('color.neutral.textStrong');
```

- [ ] **Step 2: Fix the light-theme mapping**

In `lib/src/theme/light/colors.dart`, the file currently ends with this broken block (lines 94-101, invalid `const` statements inside a `Map` literal):

```dart
  // Neutral
  const $neutralSurface = AppColors.neutral050;
  const $neutralSurfaceStrong = AppColors.neutral200;
  const $neutralUi = AppColors.neutral500;
  const $neutralUiHover = AppColors.neutral600;
  const $neutralText = AppColors.neutral700;
  const $neutralTextStrong = AppColors.neutral800;
};
```

Replace it with:

```dart
  // Neutral.
  $neutralSurface: AppColors.neutral050,
  $neutralSurfaceStrong: AppColors.neutral200,
  $neutralUi: AppColors.neutral500,
  $neutralUiHover: AppColors.neutral600,
  $neutralText: AppColors.neutral700,
  $neutralTextStrong: AppColors.neutral800,
};
```

- [ ] **Step 3: Drop `icon_2/icon.dart`'s dead import**

In `lib/src/components/icon_2/icon.dart`, remove this line (the file it references, `icon_size.dart`, doesn't exist — `DsIconSize` is already declared in `icon_variant.dart`, imported on the next line):

```dart
import 'icon_size.dart';
```

- [ ] **Step 4: Verify the fixes**

Run: `grep -c "neutralSurface\|neutralText" lib/src/tokens/semantic/colors.dart lib/src/theme/light/colors.dart`
Expected: at least one match per file, and zero remaining occurrences of `$infoSurface`/`$infoText`/etc. appearing twice (run `grep -c "const \$infoSurface" lib/src/tokens/semantic/colors.dart` — expected `1`, not `2`).

Run: `grep -n "icon_size.dart" lib/src/components/icon_2/icon.dart`
Expected: no output (no matches).

- [ ] **Step 5: Commit**

```bash
git add lib/src/tokens/semantic/colors.dart lib/src/theme/light/colors.dart lib/src/components/icon_2/icon.dart
git commit -m "$(cat <<'EOF'
fix(tokens): correct broken Neutral color token block

The Neutral section duplicated $info* token names instead of using
$neutral*, and the light-theme map had invalid `const` statements
inside a Map literal. icon_2's Icon already depends on $neutralText
for its neutral variant. Also drops icon.dart's dead import of a
nonexistent icon_size.dart (DsIconSize now lives in icon_variant.dart).
EOF
)"
```

---

### Task 2: Add the `DsIconContainerSize` enum

**Files:**
- Create: `lib/src/components/icon_container/icon_container_size.dart`

**Interfaces:**
- Produces: `enum DsIconContainerSize { sm, md, lg, xl }`, consumed by Task 3 and Task 4.

- [ ] **Step 1: Create the size enum**

Create `lib/src/components/icon_container/icon_container_size.dart`:

```dart
/// Physical size of an [IconContainer]'s square. Drives both the
/// container's outer dimension and its inner glyph's [DsIconSize] — see
/// `_resolveIconContainerSize(size)` in `icon_container_style_resolver.dart`.
enum DsIconContainerSize { sm, md, lg, xl }
```

- [ ] **Step 2: Verify the file parses as valid Dart**

Run: `grep -c "enum" lib/src/components/icon_container/icon_container_size.dart`
Expected: `1`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/icon_container/icon_container_size.dart
git commit -m "feat(icon-container): add DsIconContainerSize enum"
```

---

### Task 3: Add the style resolver

**Files:**
- Create: `lib/src/components/icon_container/icon_container_style_resolver.dart`

**Interfaces:**
- Consumes: `DsIconContainerSize` from Task 2; `DsIconVariant`/`DsIconSize` from `lib/src/components/icon_2/icon_variant.dart`; `$neutralSurface`/`$brandSurface`/`$positiveSurface`/`$negativeSurface`/`$warningSurface` and `$radius008` from `lib/src/tokens/semantic/colors.dart` / `lib/src/tokens/semantic/radius.dart`.
- Produces: `(double, DsIconSize) _resolveIconContainerSize(DsIconContainerSize size)` and `Color _resolveIconContainerBackground(DsIconVariant variant)`, both consumed by Task 4's `icon_container.dart`.

- [ ] **Step 1: Write the resolver file**

Create `lib/src/components/icon_container/icon_container_style_resolver.dart`:

```dart
part of 'icon_container.dart';

// Style resolvers for IconContainer.
//
// One pure function per resolved property (outer size + inner icon size,
// background color), same one-resolver-per-property split as every other
// component in this package (see `icon_style_resolver.dart`,
// `badge_style_resolvers.dart`).

/// Resolves an [IconContainer]'s outer square dimension and its inner
/// glyph's [DsIconSize], given its [size].
(double, DsIconSize) _resolveIconContainerSize(DsIconContainerSize size) {
  switch (size) {
    case DsIconContainerSize.sm:
      return (24, DsIconSize.sm);
    case DsIconContainerSize.md:
      return (32, DsIconSize.md);
    case DsIconContainerSize.lg:
      return (40, DsIconSize.lg);
    case DsIconContainerSize.xl:
      return (56, DsIconSize.xl);
  }
}

/// Resolves an [IconContainer]'s square background color, given its
/// [variant]. The glyph color itself is resolved separately by `Icon`'s
/// own `resolveDsIconStyle` — this function only supplies the background.
Color _resolveIconContainerBackground(DsIconVariant variant) {
  switch (variant) {
    case DsIconVariant.neutral:
      return $neutralSurface();
    case DsIconVariant.brand:
      return $brandSurface();
    case DsIconVariant.positive:
      return $positiveSurface();
    case DsIconVariant.negative:
      return $negativeSurface();
    case DsIconVariant.warning:
      return $warningSurface();
  }
}
```

Note: this file cannot be verified in isolation — it's a `part of 'icon_container.dart'`, which doesn't exist until Task 4. Verification happens in Task 4.

- [ ] **Step 2: Commit alongside Task 4**

Do not commit yet — this file has an unresolved `part of` directive until Task 4 creates `icon_container.dart`. Proceed directly to Task 4; both are committed together there.

---

### Task 4: Add the `IconContainer` widget

**Files:**
- Create: `lib/src/components/icon_container/icon_container.dart`

**Interfaces:**
- Consumes: `_resolveIconContainerSize`/`_resolveIconContainerBackground` from Task 3; `DsIconContainerSize` from Task 2; `DsIconVariant` and `Icon` from `lib/src/components/icon_2/icon_variant.dart` and `lib/src/components/icon_2/icon.dart`; `Box`/`BoxStyler` from `package:mix/mix.dart`; `IconData` from `package:flutter/widgets.dart`.
- Produces: `class IconContainer extends StatelessWidget`, constructor `IconContainer(IconData glyph, {Key? key, DsIconVariant variant = DsIconVariant.neutral, DsIconContainerSize size = DsIconContainerSize.md, BoxStyler? style})`.

- [ ] **Step 1: Write the widget**

Create `lib/src/components/icon_container/icon_container.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variant.dart';
import 'icon_container_size.dart';

// The `_resolveIconContainerSize`/`_resolveIconContainerBackground`
// functions consumed by `build()` below live in
// icon_container_style_resolver.dart, split out as `part of` this library
// (not a separate import) so they stay private to IconContainer while
// living in their own file — same split as Icon/DsButton.
part 'icon_container_style_resolver.dart';

/// Renders a Phosphor glyph (via [Icon]) centered inside a rounded-square
/// background, sized by [size] and colored as one coherent unit by
/// [variant] — the square's background and the glyph's color both key off
/// the same [DsIconVariant].
///
/// Built on Mix's [Box] — the same `BoxStyler`-driven primitive used
/// throughout this package — so the background color and corner radius
/// are resolved from the ambient `MixScope` without this widget ever
/// touching a raw [Color] in plain Dart.
class IconContainer extends StatelessWidget {
  const IconContainer(
    this.glyph, {
    super.key,
    this.variant = DsIconVariant.neutral,
    this.size = DsIconContainerSize.md,
    this.style,
  });

  /// The glyph to render, forwarded to the inner [Icon] unchanged.
  final IconData glyph;

  /// Semantic color treatment, shared between the square's background and
  /// the glyph's color — see [DsIconVariant].
  final DsIconVariant variant;

  /// Physical size — see [DsIconContainerSize].
  final DsIconContainerSize size;

  /// Escape hatch merged on top of the resolved style (e.g. a one-off
  /// background/radius override), same shape as `Icon.style`.
  final BoxStyler? style;

  @override
  Widget build(BuildContext context) {
    final (dimension, iconSize) = _resolveIconContainerSize(size);

    final resolvedStyle = BoxStyler()
        .size(dimension, dimension)
        .color(_resolveIconContainerBackground(variant))
        .borderRadiusAll($radius008())
        .merge(style);

    return Box(
      style: resolvedStyle,
      child: Center(child: Icon(glyph, size: iconSize, variant: variant)),
    );
  }
}
```

- [ ] **Step 2: Verify both files with `flutter analyze`**

Run: `flutter analyze lib/src/components/icon_container`

If the only Flutter SDK on this machine is too old to satisfy this repo's `pubspec.yaml` (`remix`/`mix` require Dart >=3.6.0; check with `flutter --version`), this command will fail at `pub get`/dependency resolution before it even reaches analysis — that is an environment limitation, not a defect in these two files. In that case:

- Do not claim the analyze run passed.
- Manually re-read `icon_container.dart` and `icon_container_style_resolver.dart` side by side and confirm: every symbol referenced (`Box`, `BoxStyler`, `$radius008`, `$neutralSurface`/`$brandSurface`/etc., `Icon`, `DsIconVariant`/`DsIconContainerSize` cases) is spelled exactly as declared in Tasks 1–3, both switch statements are exhaustive (one `case` per enum value, no `default`), and both files' brace/paren nesting is balanced.
- State plainly in your task summary that verification was manual review only, and why.

If a working SDK is available and `flutter analyze` passes with no issues in these two files, that satisfies this step.

- [ ] **Step 3: Commit Tasks 3 and 4 together**

```bash
git add lib/src/components/icon_container/icon_container.dart lib/src/components/icon_container/icon_container_style_resolver.dart
git commit -m "feat(icon-container): add IconContainer widget on Mix's Box"
```

---

## Self-Review Notes

- Spec coverage: token/import fix ✓ (Task 1), file layout ✓ (Task 2 size enum, Tasks 3-4 component files), size resolution table ✓ (Task 3), variant→background resolution table ✓ (Task 3), constant radius ✓ (Task 4), widget API shape incl. `style` escape hatch ✓ (Task 4), non-goals (no `ui.dart` export, no catalog spec, no automated tests) ✓ reflected in Global Constraints and by omission.
- No placeholders — every step has complete, exact code.
- Type consistency checked: `_resolveIconContainerSize`'s `(double, DsIconSize)` record return matches its Task 4 destructuring (`final (dimension, iconSize) = ...`) exactly; `_resolveIconContainerBackground(DsIconVariant)` signature matches its call site; enum case names in Task 3's switches match `DsIconContainerSize`/`DsIconVariant` declarations exactly (`icon_container_size.dart` and the existing `icon_2/icon_variant.dart`).
