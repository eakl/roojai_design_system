# Icon Component Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a design-system `Icon` widget wrapping Phosphor glyphs, with a t-shirt `IconSize` and a semantic `IconVariant` resolved through the project's Mix token layer.

**Architecture:** `Icon` is a thin `StatelessWidget` that resolves `(size, variant)` to an `IconStyler` (a Mix `Style<IconSpec>`) via a pure resolver function, then hands that style to Mix's `StyledIcon` primitive — the same one `RemixButton` uses internally for its own icons. No manual `Color`/token resolution happens in plain Dart; `StyledIcon` resolves any token refs against the ambient `MixScope` itself, exactly like `DsButton`/`button_2` does today.

**Tech Stack:** Flutter, `mix` (`StyledIcon`, `IconStyler`, `ColorToken`), `phosphor_flutter` (`IconData` glyphs) — both already `pubspec.yaml` dependencies.

## Global Constraints

- Follow the working Mix-token pattern (`button_2`), not the legacy `AppTokens.of(context)` pattern — `AppTokens`/`SemanticColors` were deleted and every component still calling them currently fails to compile (see `docs/superpowers/specs/2026-07-14-mix-token-migration-design.md`).
- `IconSize` → px: `sm=16` (`$spacing016`), `md=20` (`$spacing020`), `lg=24` (`$spacing024`), `xl=32` (`$spacing032`).
- `IconVariant` → color token: `neutral=$iconNeutral` (new), `brand=$brandText`, `positive=$positiveText`, `negative=$negativeText`, `warning=$warningText`.
- No new `lib/ui.dart` export, no catalog `componentRegistry` entry — `button_2`, the pattern this follows, isn't wired into either yet.
- This package has no automated test suite and the example app currently cannot build (legacy components reference deleted APIs) — verification is `flutter analyze`, not `flutter test`/`flutter run`. The only local Flutter SDK (fvm 3.19.0 / Dart 3.3.0) is too old to run `pub get` for this repo's `mix`/`remix` versions, so analysis must be run with whatever SDK actually satisfies `pubspec.yaml`'s constraints — confirm a working SDK is available before Task 2's verification step; if none is, note that explicitly instead of claiming a passing analyze run.

---

## File Structure

```
lib/src/components/icon/
  icon.dart                 # Icon widget + `part` declarations
  icon_size.dart             # enum IconSize
  icon_variant.dart          # enum IconVariant
  icon_style_resolver.dart   # part of 'icon.dart' — _resolveIconSize/_resolveIconColor
```

Modified:

```
lib/src/tokens/semantic/colors.dart   # add $iconNeutral
lib/src/theme/light/colors.dart       # map $iconNeutral -> AppColors.neutral600
```

---

### Task 1: Add the `$iconNeutral` semantic color token

**Files:**
- Modify: `lib/src/tokens/semantic/colors.dart`
- Modify: `lib/src/theme/light/colors.dart`

**Interfaces:**
- Produces: `const $iconNeutral = ColorToken('color.icon.neutral');`, importable from `lib/src/tokens/semantic/colors.dart`, resolving (via `lightColors`) to `AppColors.neutral600` (`Color(0xFF969696)`).

- [ ] **Step 1: Add the token declaration**

In `lib/src/tokens/semantic/colors.dart`, the file ends with the `// Info.` block (`$infoTextStrong`). Append a new section after it:

```dart

// Icon.
const $iconNeutral = ColorToken('color.icon.neutral');
```

- [ ] **Step 2: Map the token to its default-light value**

In `lib/src/theme/light/colors.dart`, the `lightColors` map ends with:

```dart
  $infoText: AppColors.blue700,
  $infoTextStrong: AppColors.blue800,
};
```

Change it to add the new entry before the closing `};`:

```dart
  $infoText: AppColors.blue700,
  $infoTextStrong: AppColors.blue800,

  // Icon.
  $iconNeutral: AppColors.neutral600,
};
```

- [ ] **Step 3: Verify the file is well-formed**

Run: `grep -n "iconNeutral" lib/src/tokens/semantic/colors.dart lib/src/theme/light/colors.dart`
Expected: one match per file, showing the new lines added in Steps 1 and 2.

- [ ] **Step 4: Commit**

```bash
git add lib/src/tokens/semantic/colors.dart lib/src/theme/light/colors.dart
git commit -m "$(cat <<'EOF'
feat(tokens): add $iconNeutral semantic color token

Neutral-variant icon color for the upcoming Icon component — no
existing semantic token resolves to AppColors.neutral600.
EOF
)"
```

---

### Task 2: Add `IconSize` and `IconVariant` enums

**Files:**
- Create: `lib/src/components/icon/icon_size.dart`
- Create: `lib/src/components/icon/icon_variant.dart`

**Interfaces:**
- Produces: `enum IconSize { sm, md, lg, xl }` and `enum IconVariant { neutral, brand, positive, negative, warning }`, both consumed by Task 3.

- [ ] **Step 1: Create the size enum**

Create `lib/src/components/icon/icon_size.dart`:

```dart
/// Physical size of an [Icon]. Drives the rendered glyph extent — see
/// `_resolveIconSize(size)` in `icon_style_resolver.dart`.
enum IconSize { sm, md, lg, xl }
```

- [ ] **Step 2: Create the variant enum**

Create `lib/src/components/icon/icon_variant.dart`:

```dart
/// Semantic color treatment of an [Icon]. Each variant maps to a color
/// token in `_resolveIconColor(variant)` in `icon_style_resolver.dart`.
enum IconVariant {
  /// Default — muted gray, no semantic meaning attached.
  neutral,

  /// Brand-colored, for icons tied to primary/brand actions or emphasis.
  brand,

  /// Communicates success/positive status (checkmarks, confirmations).
  positive,

  /// Communicates an error/destructive status.
  negative,

  /// Communicates a caution/warning status.
  warning,
}
```

- [ ] **Step 3: Verify both files parse as valid Dart**

Run: `grep -c "enum" lib/src/components/icon/icon_size.dart lib/src/components/icon/icon_variant.dart`
Expected: `1` for each file.

- [ ] **Step 4: Commit**

```bash
git add lib/src/components/icon/icon_size.dart lib/src/components/icon/icon_variant.dart
git commit -m "feat(icon): add IconSize and IconVariant enums"
```

---

### Task 3: Add the style resolver

**Files:**
- Create: `lib/src/components/icon/icon_style_resolver.dart`

**Interfaces:**
- Consumes: `IconSize` and `IconVariant` from Task 2; `$spacing016`/`$spacing020`/`$spacing024`/`$spacing032` from `lib/src/tokens/semantic/spacing.dart`; `$iconNeutral`/`$brandText`/`$positiveText`/`$negativeText`/`$warningText` from `lib/src/tokens/semantic/colors.dart`.
- Produces: `IconStyler resolveIconStyle({required IconSize size, required IconVariant variant})`, consumed by Task 4's `icon.dart`.

- [ ] **Step 1: Write the resolver file**

Create `lib/src/components/icon/icon_style_resolver.dart`:

```dart
part of 'icon.dart';

// Style resolver for Icon.
//
// One pure function per resolved property (size, color), same
// one-resolver-per-property split as every other component in this
// package (see `button_2_style_resolver.dart`, `badge_style_resolvers.dart`).

/// Resolves the full `IconStyler` for an [Icon], given its [size] and
/// [variant].
IconStyler resolveIconStyle({
  required IconSize size,
  required IconVariant variant,
}) {
  return IconStyler()
      .size(_resolveIconSize(size))
      .color(_resolveIconColor(variant));
}

double _resolveIconSize(IconSize size) {
  switch (size) {
    case IconSize.sm:
      return $spacing016();
    case IconSize.md:
      return $spacing020();
    case IconSize.lg:
      return $spacing024();
    case IconSize.xl:
      return $spacing032();
  }
}

Color _resolveIconColor(IconVariant variant) {
  switch (variant) {
    case IconVariant.neutral:
      return $iconNeutral();
    case IconVariant.brand:
      return $brandText();
    case IconVariant.positive:
      return $positiveText();
    case IconVariant.negative:
      return $negativeText();
    case IconVariant.warning:
      return $warningText();
  }
}
```

Note: `$spacing016()` / `$brandText()` etc. are Mix's token-ref call syntax — calling a `SpaceToken`/`ColorToken` returns a lazy reference (`double`-typed for `SpaceToken`, `Color`-typed for `ColorToken` via `ColorRef`) that `IconStyler`'s `.size()`/`.color()` accept directly and Mix resolves against the ambient `MixScope` at build time. This mirrors `button_2_style_resolver.dart`'s `.iconSize(20)` / `.color($surfaceInverted())` usage exactly.

This file cannot be verified in isolation — it's a `part of 'icon.dart'`, which doesn't exist until Task 4. Verification happens in Task 4.

- [ ] **Step 2: Commit alongside Task 4**

Do not commit yet — this file has an unresolved `part of` directive until Task 4 creates `icon.dart`. Proceed directly to Task 4; both are committed together there.

---

### Task 4: Add the `Icon` widget

**Files:**
- Create: `lib/src/components/icon/icon.dart`

**Interfaces:**
- Consumes: `resolveIconStyle` from Task 3; `IconSize`/`IconVariant` from Task 2; `IconStyler`/`StyledIcon` from `package:mix/mix.dart`; `IconData` from `package:flutter/widgets.dart` (Phosphor glyphs like `PhosphorIcons.check()` are `IconData` subtypes).
- Produces: `class Icon extends StatelessWidget`, constructor `Icon(IconData glyph, {Key? key, IconSize size = IconSize.md, IconVariant variant = IconVariant.neutral, IconStyler? style})`.

- [ ] **Step 1: Write the widget**

Create `lib/src/components/icon/icon.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/spacing.dart';
import 'icon_size.dart';
import 'icon_variant.dart';

// The `resolveIconStyle` function consumed by `build()` below lives in
// icon_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to Icon while living in its own
// file — same split as Badge/DsButton.
part 'icon_style_resolver.dart';

/// Renders a Phosphor glyph at a design-system [IconSize], colored by
/// [IconVariant].
///
/// Built on Mix's [StyledIcon] — the same primitive [RemixButton] uses
/// internally to render its own `leadingIcon`/`trailingIcon` — so size and
/// color are resolved from the ambient `MixScope` without this widget ever
/// touching a raw [Color] in plain Dart.
class Icon extends StatelessWidget {
  const Icon(
    this.glyph, {
    super.key,
    this.size = IconSize.md,
    this.variant = IconVariant.neutral,
    this.style,
  });

  /// The glyph to render, e.g. `PhosphorIcons.check()`. Any Phosphor style
  /// variant (regular/bold/duotone/fill/thin/light) is selected by the
  /// caller via which glyph accessor they call — [Icon] only controls
  /// size/color, never the glyph's own style.
  final IconData glyph;

  /// Physical size — see [IconSize].
  final IconSize size;

  /// Semantic color treatment — see [IconVariant].
  final IconVariant variant;

  /// Escape hatch merged on top of the resolved style (e.g. a one-off
  /// color/opacity override), same shape as `DsButton.style`. When null,
  /// the style resolved from [size]/[variant] is used as-is.
  final IconStyler? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        resolveIconStyle(size: size, variant: variant).merge(style);

    return StyledIcon(icon: glyph, style: resolvedStyle);
  }
}
```

- [ ] **Step 2: Verify both files with `flutter analyze`**

Run: `flutter analyze lib/src/components/icon`

If the only Flutter SDK on this machine is too old to satisfy this repo's `pubspec.yaml` (`remix`/`mix` require Dart >=3.6.0; check with `flutter --version`), this command will fail at `pub get`/dependency resolution before it even reaches analysis — that is an environment limitation, not a defect in these two files. In that case:

- Do not claim the analyze run passed.
- Manually re-read `icon.dart` and `icon_style_resolver.dart` side by side and confirm: every symbol referenced (`IconStyler`, `StyledIcon`, `$spacing0xx`, `$brandText` etc., `IconSize`/`IconVariant` cases) is spelled exactly as declared in Tasks 1–3, all switch statements are exhaustive (one `case` per enum value, no `default`), and both files' brace/paren nesting is balanced.
- State plainly in your task summary that verification was manual review only, and why.

If a working SDK is available and `flutter analyze` passes with no issues in these two files, that satisfies this step.

- [ ] **Step 3: Commit Tasks 3 and 4 together**

```bash
git add lib/src/components/icon/icon.dart lib/src/components/icon/icon_style_resolver.dart
git commit -m "feat(icon): add Icon widget on Mix's StyledIcon"
```

---

## Self-Review Notes

- Spec coverage: file layout ✓ (Task 1 tokens, Tasks 2–4 component files), sizes ✓ (Task 3), colors incl. new `$iconNeutral` ✓ (Task 1, Task 3), widget API shape incl. `style` escape hatch ✓ (Task 4), non-goals (no `ui.dart` export, no catalog spec, no automated tests) ✓ reflected in Global Constraints and by omission.
- No placeholders — every step has complete, exact code.
- Type consistency checked: `resolveIconStyle({required IconSize size, required IconVariant variant})` signature matches its Task 4 call site exactly; enum case names match between `icon_size.dart`/`icon_variant.dart` (Task 2) and the switches in `icon_style_resolver.dart` (Task 3).
