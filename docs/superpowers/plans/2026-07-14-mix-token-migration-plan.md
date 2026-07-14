# Mix Token Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the hand-rolled `SemanticColors`/`SemanticTypography`/`AppTokens` token layer with Fluttermix's `MixToken`/`MixScope` system, per `docs/superpowers/specs/2026-07-14-mix-token-migration-design.md`.

**Architecture:** Primitives (`lib/src/tokens/primitives/*.dart`) stay untouched plain Dart constants. Six new semantic token files declare `$`-prefixed top-level `MixToken` variables (`ColorToken`, `TextStyleToken`, `SpaceToken`, `RadiusToken`, `DurationToken`, a new `CurveToken`). A new `app_theme_data.dart` maps every token to its default-light value. `AppTokensScope` is rewritten to build a `MixScope` from that map. `AppTokens` and the two old semantic files are deleted.

**Tech Stack:** Flutter 3.41.9 / Dart 3.11.5 via `fvm` (run all commands as `fvm dart ...` / `fvm flutter ...`), `mix: ^2.1.0` (already a pubspec dependency).

**Known accepted breakage:** After Task 10 (deleting old files), component files under `lib/src/components/**` that still reference `AppTokens`, `SemanticColors`, or `SemanticTypography` will fail to compile. This is expected per the spec — those files are migrated in a separate follow-up plan (Part 2). This plan verifies each new/changed file with `fvm dart analyze <file>` in isolation, and does a final whole-package analyze at the end to confirm the *only* errors remaining are in `lib/src/components/**` (pre-existing, out of scope) — no errors in `lib/src/tokens/**` or `lib/src/theme/**`.

---

### Task 1: Add `CurveToken`

**Files:**
- Create: `lib/src/theme/curve_token.dart`

- [ ] **Step 1: Write the file**

```dart
// lib/src/theme/curve_token.dart

import 'package:flutter/animation.dart';
import 'package:mix/mix.dart';

/// A [MixToken] for [Curve] values.
///
/// Mix ships no built-in curve token type because [Curve] isn't one of the
/// supported `MixToken.call()` reference types (see `getReferenceValue` in
/// the `mix` package). This token is therefore only usable via
/// [MixToken.resolve] — never via `call()` / inside a `Style` chain.
class CurveToken extends MixToken<Curve> {
  const CurveToken(super.name);
}
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/theme/curve_token.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/theme/curve_token.dart
git commit -m "feat: add CurveToken for Mix motion tokens"
```

---

### Task 2: Semantic color tokens

**Files:**
- Create: `lib/src/tokens/semantic/colors.dart`

- [ ] **Step 1: Write the file**

Every field mirrors `SemanticColors` (canvas, surface, content, border, and
the five status groups: positive, negative, warning, alert, info), same
nesting flattened into dotted token ids.

```dart
// lib/src/tokens/semantic/colors.dart

import 'package:mix/mix.dart';

// Canvas.
final $canvasBase = const ColorToken('color.canvas.base');
final $canvasAlternative = const ColorToken('color.canvas.alternative');

// Surface.
final $surfaceBase = const ColorToken('color.surface.base');
final $surfaceAlternative = const ColorToken('color.surface.alternative');
final $surfaceInverted = const ColorToken('color.surface.inverted');

// Content.
final $contentPrimary = const ColorToken('color.content.primary');
final $contentSecondary = const ColorToken('color.content.secondary');
final $contentMuted = const ColorToken('color.content.muted');
final $contentPlaceholder = const ColorToken('color.content.placeholder');
final $contentOnBrand = const ColorToken('color.content.onBrand');
final $contentOnBrandMuted = const ColorToken('color.content.onBrandMuted');

// Border.
final $borderBase = const ColorToken('color.border.base');
final $borderStrong = const ColorToken('color.border.strong');

// Positive.
final $positiveSurface = const ColorToken('color.positive.surface');
final $positiveSurfaceStrong = const ColorToken('color.positive.surfaceStrong');
final $positiveBorder = const ColorToken('color.positive.border');
final $positiveUi = const ColorToken('color.positive.ui');
final $positiveUiHover = const ColorToken('color.positive.uiHover');
final $positiveText = const ColorToken('color.positive.text');
final $positiveTextStrong = const ColorToken('color.positive.textStrong');

// Negative.
final $negativeSurface = const ColorToken('color.negative.surface');
final $negativeSurfaceStrong = const ColorToken('color.negative.surfaceStrong');
final $negativeBorder = const ColorToken('color.negative.border');
final $negativeUi = const ColorToken('color.negative.ui');
final $negativeUiHover = const ColorToken('color.negative.uiHover');
final $negativeText = const ColorToken('color.negative.text');
final $negativeTextStrong = const ColorToken('color.negative.textStrong');

// Warning.
final $warningSurface = const ColorToken('color.warning.surface');
final $warningSurfaceStrong = const ColorToken('color.warning.surfaceStrong');
final $warningBorder = const ColorToken('color.warning.border');
final $warningUi = const ColorToken('color.warning.ui');
final $warningUiHover = const ColorToken('color.warning.uiHover');
final $warningText = const ColorToken('color.warning.text');
final $warningTextStrong = const ColorToken('color.warning.textStrong');

// Alert.
final $alertSurface = const ColorToken('color.alert.surface');
final $alertSurfaceStrong = const ColorToken('color.alert.surfaceStrong');
final $alertBorder = const ColorToken('color.alert.border');
final $alertUi = const ColorToken('color.alert.ui');
final $alertUiHover = const ColorToken('color.alert.uiHover');
final $alertText = const ColorToken('color.alert.text');
final $alertTextStrong = const ColorToken('color.alert.textStrong');

// Info.
final $infoSurface = const ColorToken('color.info.surface');
final $infoSurfaceStrong = const ColorToken('color.info.surfaceStrong');
final $infoBorder = const ColorToken('color.info.border');
final $infoUi = const ColorToken('color.info.ui');
final $infoUiHover = const ColorToken('color.info.uiHover');
final $infoText = const ColorToken('color.info.text');
final $infoTextStrong = const ColorToken('color.info.textStrong');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/colors.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/colors.dart
git commit -m "feat: add semantic color Mix tokens"
```

---

### Task 3: Semantic typography tokens

**Files:**
- Create: `lib/src/tokens/semantic/typography.dart`

- [ ] **Step 1: Write the file**

One `TextStyleToken` per existing `SemanticTypography` field.

```dart
// lib/src/tokens/semantic/typography.dart

import 'package:mix/mix.dart';

final $displayMd = const TextStyleToken('typography.displayMd');
final $displaySm = const TextStyleToken('typography.displaySm');
final $h1 = const TextStyleToken('typography.h1');
final $h2 = const TextStyleToken('typography.h2');
final $h3 = const TextStyleToken('typography.h3');
final $h4 = const TextStyleToken('typography.h4');
final $bodyLg = const TextStyleToken('typography.bodyLg');
final $bodyMd = const TextStyleToken('typography.bodyMd');
final $bodySm = const TextStyleToken('typography.bodySm');
final $labelLg = const TextStyleToken('typography.labelLg');
final $labelMd = const TextStyleToken('typography.labelMd');
final $labelSm = const TextStyleToken('typography.labelSm');
final $captionMd = const TextStyleToken('typography.captionMd');
final $captionSm = const TextStyleToken('typography.captionSm');
final $overline = const TextStyleToken('typography.overline');
final $small = const TextStyleToken('typography.small');
final $footnote = const TextStyleToken('typography.footnote');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/typography.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/typography.dart
git commit -m "feat: add semantic typography Mix tokens"
```

---

### Task 4: Semantic spacing tokens

**Files:**
- Create: `lib/src/tokens/semantic/spacing.dart`

- [ ] **Step 1: Write the file**

One `SpaceToken` per existing `AppSpacing` primitive value (1:1 mirror, no
value dropped).

```dart
// lib/src/tokens/semantic/spacing.dart

import 'package:mix/mix.dart';

final $spacing0 = const SpaceToken('spacing.0');
final $spacing2 = const SpaceToken('spacing.2');
final $spacing4 = const SpaceToken('spacing.4');
final $spacing6 = const SpaceToken('spacing.6');
final $spacing8 = const SpaceToken('spacing.8');
final $spacing12 = const SpaceToken('spacing.12');
final $spacing16 = const SpaceToken('spacing.16');
final $spacing20 = const SpaceToken('spacing.20');
final $spacing24 = const SpaceToken('spacing.24');
final $spacing32 = const SpaceToken('spacing.32');
final $spacing40 = const SpaceToken('spacing.40');
final $spacing48 = const SpaceToken('spacing.48');
final $spacing64 = const SpaceToken('spacing.64');
final $spacing80 = const SpaceToken('spacing.80');
final $spacing96 = const SpaceToken('spacing.96');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/spacing.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/spacing.dart
git commit -m "feat: add semantic spacing Mix tokens"
```

---

### Task 5: Semantic radius tokens

**Files:**
- Create: `lib/src/tokens/semantic/radius.dart`

- [ ] **Step 1: Write the file**

Named t-shirt scale (5 primitive values total — clean fit).

```dart
// lib/src/tokens/semantic/radius.dart

import 'package:mix/mix.dart';

final $radiusSm = const RadiusToken('radius.sm');
final $radiusMd = const RadiusToken('radius.md');
final $radiusLg = const RadiusToken('radius.lg');
final $radiusXl = const RadiusToken('radius.xl');
final $radiusFull = const RadiusToken('radius.full');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/radius.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/radius.dart
git commit -m "feat: add semantic radius Mix tokens"
```

---

### Task 6: Semantic motion tokens

**Files:**
- Create: `lib/src/tokens/semantic/motion.dart`

- [ ] **Step 1: Write the file**

Three `DurationToken`s (1:1 mirror of `AppMotion` durations) plus two
`CurveToken`s (1:1 mirror of `AppMotion` curves), using the `CurveToken`
from Task 1.

```dart
// lib/src/tokens/semantic/motion.dart

import 'package:mix/mix.dart';

import '../../theme/curve_token.dart';

final $motionDurationFast = const DurationToken('motion.duration.fast');
final $motionDurationNormal = const DurationToken('motion.duration.normal');
final $motionDurationSlow = const DurationToken('motion.duration.slow');

final $motionCurveStandard = const CurveToken('motion.curve.standard');
final $motionCurveEmphasized = const CurveToken('motion.curve.emphasized');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/motion.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/motion.dart
git commit -m "feat: add semantic motion Mix tokens"
```

---

### Task 7: Semantic elevation tokens

**Files:**
- Create: `lib/src/tokens/semantic/elevation.dart`

- [ ] **Step 1: Write the file**

One `BoxShadowToken` per existing `AppElevation` level (1:1 mirror).

```dart
// lib/src/tokens/semantic/elevation.dart

import 'package:mix/mix.dart';

final $elevationLevel0 = const BoxShadowToken('elevation.level0');
final $elevationLevel1 = const BoxShadowToken('elevation.level1');
final $elevationLevel2 = const BoxShadowToken('elevation.level2');
final $elevationLevel3 = const BoxShadowToken('elevation.level3');
final $elevationLevel4 = const BoxShadowToken('elevation.level4');
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/tokens/semantic/elevation.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/tokens/semantic/elevation.dart
git commit -m "feat: add semantic elevation Mix tokens"
```

---

### Task 8: Default-light theme data

**Files:**
- Create: `lib/src/theme/app_theme_data.dart`

- [ ] **Step 1: Write the file**

Maps every semantic token from Tasks 2–7 to its current default-light
primitive value, porting every value from
`SemanticColors.defaultLight` / `SemanticTypography.defaultScale` verbatim
(same primitives, same font/weight/line-height/letter-spacing composition),
plus new 1:1 entries for spacing/radius/motion/elevation.

```dart
// lib/src/theme/app_theme_data.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../tokens/primitives/app_colors.dart';
import '../tokens/primitives/app_elevation.dart';
import '../tokens/primitives/app_motion.dart';
import '../tokens/primitives/app_radius.dart';
import '../tokens/primitives/app_spacing.dart';
import '../tokens/primitives/app_typography.dart';
import '../tokens/semantic/colors.dart';
import '../tokens/semantic/elevation.dart';
import '../tokens/semantic/motion.dart';
import '../tokens/semantic/radius.dart';
import '../tokens/semantic/spacing.dart';
import '../tokens/semantic/typography.dart';

/// The package's built-in default light theme, mapping every semantic
/// token declared under `lib/src/tokens/semantic/` to its concrete value.
///
/// Passed to `MixScope` by `AppTokensScope`. A consuming app may override
/// any subset of these entries to retheme without touching component code.
final Map<MixToken, Object> defaultLightTokens = <MixToken, Object>{
  // Colors — canvas.
  $canvasBase: AppColors.white,
  $canvasAlternative: AppColors.gray50,

  // Colors — surface.
  $surfaceBase: AppColors.white,
  $surfaceAlternative: AppColors.gray100,
  $surfaceInverted: AppColors.gray900,

  // Colors — content.
  $contentPrimary: AppColors.gray900,
  $contentSecondary: AppColors.gray600,
  $contentMuted: AppColors.gray500,
  $contentPlaceholder: AppColors.gray400,
  $contentOnBrand: AppColors.white,
  $contentOnBrandMuted: AppColors.gray300,

  // Colors — border.
  $borderBase: AppColors.gray200,
  $borderStrong: AppColors.gray400,

  // Colors — positive.
  $positiveSurface: AppColors.green50,
  $positiveSurfaceStrong: AppColors.green500,
  $positiveBorder: AppColors.green500,
  $positiveUi: AppColors.green600,
  $positiveUiHover: AppColors.green700,
  $positiveText: AppColors.green600,
  $positiveTextStrong: AppColors.green700,

  // Colors — negative.
  $negativeSurface: AppColors.red50,
  $negativeSurfaceStrong: AppColors.red500,
  $negativeBorder: AppColors.red500,
  $negativeUi: AppColors.red600,
  $negativeUiHover: AppColors.red700,
  $negativeText: AppColors.red600,
  $negativeTextStrong: AppColors.red700,

  // Colors — warning.
  $warningSurface: AppColors.amber50,
  $warningSurfaceStrong: AppColors.amber500,
  $warningBorder: AppColors.amber500,
  $warningUi: AppColors.amber600,
  $warningUiHover: AppColors.amber700,
  $warningText: AppColors.amber600,
  $warningTextStrong: AppColors.amber700,

  // Colors — alert.
  $alertSurface: AppColors.orange50,
  $alertSurfaceStrong: AppColors.orange500,
  $alertBorder: AppColors.orange500,
  $alertUi: AppColors.orange600,
  $alertUiHover: AppColors.orange700,
  $alertText: AppColors.orange600,
  $alertTextStrong: AppColors.orange700,

  // Colors — info.
  $infoSurface: AppColors.sky50,
  $infoSurfaceStrong: AppColors.sky500,
  $infoBorder: AppColors.sky500,
  $infoUi: AppColors.sky600,
  $infoUiHover: AppColors.sky700,
  $infoText: AppColors.sky600,
  $infoTextStrong: AppColors.sky700,

  // Typography.
  $displayMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size48,
    fontWeight: AppTypeScale.bold,
    height: AppTypeScale.lineHeightTight,
  ),
  $displaySm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size40,
    fontWeight: AppTypeScale.bold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h1: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size32,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h2: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size28,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightTight,
  ),
  $h3: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size24,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
  ),
  $h4: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size20,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodyLg: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size18,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodyMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size16,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $bodySm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size14,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelLg: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size16,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size14,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $labelSm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.medium,
    height: AppTypeScale.lineHeightNormal,
  ),
  $captionMd: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $captionSm: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $overline: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.semibold,
    height: AppTypeScale.lineHeightNormal,
    letterSpacing: 1.2,
  ),
  $small: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size13,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightNormal,
  ),
  $footnote: const TextStyle(
    fontFamily: AppTypeScale.fontFamily,
    fontSize: AppTypeScale.size12,
    fontWeight: AppTypeScale.regular,
    height: AppTypeScale.lineHeightRelaxed,
  ),

  // Spacing.
  $spacing0: AppSpacing.spacing0,
  $spacing2: AppSpacing.spacing2,
  $spacing4: AppSpacing.spacing4,
  $spacing6: AppSpacing.spacing6,
  $spacing8: AppSpacing.spacing8,
  $spacing12: AppSpacing.spacing12,
  $spacing16: AppSpacing.spacing16,
  $spacing20: AppSpacing.spacing20,
  $spacing24: AppSpacing.spacing24,
  $spacing32: AppSpacing.spacing32,
  $spacing40: AppSpacing.spacing40,
  $spacing48: AppSpacing.spacing48,
  $spacing64: AppSpacing.spacing64,
  $spacing80: AppSpacing.spacing80,
  $spacing96: AppSpacing.spacing96,

  // Radius.
  $radiusSm: Radius.circular(AppRadius.radius4),
  $radiusMd: Radius.circular(AppRadius.radius8),
  $radiusLg: Radius.circular(AppRadius.radius12),
  $radiusXl: Radius.circular(AppRadius.radius16),
  $radiusFull: Radius.circular(AppRadius.radiusFull),

  // Motion — duration.
  $motionDurationFast: AppMotion.durationFast,
  $motionDurationNormal: AppMotion.durationNormal,
  $motionDurationSlow: AppMotion.durationSlow,

  // Motion — curve.
  $motionCurveStandard: AppMotion.curveStandard,
  $motionCurveEmphasized: AppMotion.curveEmphasized,

  // Elevation.
  $elevationLevel0: AppElevation.level0,
  $elevationLevel1: AppElevation.level1,
  $elevationLevel2: AppElevation.level2,
  $elevationLevel3: AppElevation.level3,
  $elevationLevel4: AppElevation.level4,
};
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/theme/app_theme_data.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/theme/app_theme_data.dart
git commit -m "feat: add default-light Mix theme data"
```

---

### Task 9: Rewrite `AppTokensScope` to build a `MixScope`

**Files:**
- Modify: `lib/src/theme/app_tokens_scope.dart`

- [ ] **Step 1: Replace the file contents**

Same public shape (a widget installed at the app root, defaulting to the
package's built-in theme, overridable), now backed by `MixScope` instead of
the custom `AppTokens` `InheritedWidget`.

```dart
// lib/src/theme/app_tokens_scope.dart

import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import 'app_theme_data.dart';

/// Installs the design system's Mix tokens at the app root via [MixScope].
///
/// Defaults to the package's built-in [defaultLightTokens]; a consuming
/// app may pass typed override maps (mirroring [MixScope]'s own
/// constructor params) to retheme every component without touching
/// component code. Overrides are merged on top of the defaults, so a
/// partial override map only replaces the tokens it specifies.
class AppTokensScope extends StatelessWidget {
  const AppTokensScope({
    super.key,
    this.colors = const <ColorToken, Color>{},
    this.textStyles = const <TextStyleToken, TextStyle>{},
    this.spaces = const <SpaceToken, double>{},
    this.radii = const <RadiusToken, Radius>{},
    this.boxShadows = const <BoxShadowToken, List<BoxShadow>>{},
    this.tokens = const <MixToken, Object>{},
    required this.child,
  });

  final Map<ColorToken, Color> colors;
  final Map<TextStyleToken, TextStyle> textStyles;
  final Map<SpaceToken, double> spaces;
  final Map<RadiusToken, Radius> radii;
  final Map<BoxShadowToken, List<BoxShadow>> boxShadows;

  /// Overrides for token types without a dedicated typed param above
  /// (e.g. [DurationToken], [CurveToken]).
  final Map<MixToken, Object> tokens;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // `.cast<MixToken, Object>()` mirrors how `mix`'s own `MixScope` factory
    // combines its typed override maps internally (see
    // `mix_theme.dart`'s `MixScope` factory constructor) — required because
    // a `Map<ColorToken, Color>` spread directly into a
    // `Map<MixToken, Object>` literal is not automatically widened.
    return MixScope(
      tokens: <MixToken, Object>{
        ...defaultLightTokens,
        ...colors.cast<MixToken, Object>(),
        ...textStyles.cast<MixToken, Object>(),
        ...spaces.cast<MixToken, Object>(),
        ...radii.cast<MixToken, Object>(),
        ...boxShadows.cast<MixToken, Object>(),
        ...tokens,
      },
      child: child,
    );
  }
}
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `fvm dart analyze lib/src/theme/app_tokens_scope.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/theme/app_tokens_scope.dart
git commit -m "refactor: rebuild AppTokensScope on Mix's MixScope"
```

---

### Task 10: Delete the old token/theme files

**Files:**
- Delete: `lib/src/theme/app_tokens.dart`
- Delete: `lib/src/tokens/semantic/semantic_colors.dart`
- Delete: `lib/src/tokens/semantic/semantic_typography.dart`

- [ ] **Step 1: Delete the files**

```bash
git rm lib/src/theme/app_tokens.dart
git rm lib/src/tokens/semantic/semantic_colors.dart
git rm lib/src/tokens/semantic/semantic_typography.dart
```

- [ ] **Step 2: Commit**

```bash
git commit -m "refactor: delete superseded AppTokens/SemanticColors/SemanticTypography"
```

---

### Task 11: Update the public barrel (`lib/ui.dart`)

**Files:**
- Modify: `lib/ui.dart:1-13`

- [ ] **Step 1: Replace the token/theme export block**

Current lines 3–13:

```dart
// Semantic tokens (public — consuming apps may construct custom token sets).
export 'src/tokens/semantic/semantic_colors.dart';
export 'src/tokens/semantic/semantic_typography.dart';

// Primitive scales referenced directly by consuming apps for spacing/radius.
export 'src/tokens/primitives/app_spacing.dart';
export 'src/tokens/primitives/app_radius.dart';

// Theme.
export 'src/theme/app_tokens.dart';
export 'src/theme/app_tokens_scope.dart';
```

Replace with:

```dart
// Semantic tokens (public — consuming apps may reference/override these
// when passing overrides to AppTokensScope).
export 'src/tokens/semantic/colors.dart';
export 'src/tokens/semantic/typography.dart';
export 'src/tokens/semantic/spacing.dart';
export 'src/tokens/semantic/radius.dart';
export 'src/tokens/semantic/motion.dart';
export 'src/tokens/semantic/elevation.dart';

// Primitive scales referenced directly by consuming apps for spacing/radius.
export 'src/tokens/primitives/app_spacing.dart';
export 'src/tokens/primitives/app_radius.dart';

// Theme.
export 'src/theme/curve_token.dart';
export 'src/theme/app_theme_data.dart';
export 'src/theme/app_tokens_scope.dart';
```

- [ ] **Step 2: Verify the barrel file itself has no broken exports**

Run: `fvm dart analyze lib/ui.dart`
Expected: Errors only about component files that still reference the
deleted `AppTokens`/`SemanticColors`/`SemanticTypography` APIs (e.g.
`button_style_resolvers.dart`, `badge_style_resolvers.dart`, etc.) — this
is the accepted breakage described at the top of this plan. There must be
**no** errors pointing at `lib/src/tokens/**` or `lib/src/theme/**` files
themselves, and no "target of URI doesn't exist" errors for any of the
export paths in `lib/ui.dart`.

- [ ] **Step 3: Commit**

```bash
git add lib/ui.dart
git commit -m "refactor: update public barrel exports for Mix token migration"
```

---

### Task 12: Final isolated verification

**Files:** none (verification only)

- [ ] **Step 1: Analyze every new/changed token and theme file together**

Run:
```bash
fvm dart analyze lib/src/tokens/primitives lib/src/tokens/semantic lib/src/theme
```
Expected: `No issues found!` — every file under these three directories
(primitives untouched, semantic rewritten, theme rewritten) is internally
consistent and self-contained.

- [ ] **Step 2: Confirm no stray references to deleted APIs remain outside components**

Run:
```bash
git grep -n "AppTokens\.\|SemanticColors\|SemanticTypography" -- lib/src/tokens lib/src/theme lib/ui.dart
```
Expected: no output (empty). If any match appears, it means a file outside
`lib/src/components/**` still references a deleted API — fix it before
proceeding, since that would indicate a leftover this plan was supposed to
remove (as opposed to the accepted, in-scope component breakage).

- [ ] **Step 3: Record the expected remaining breakage for the Part 2 plan**

Run:
```bash
fvm dart analyze lib 2>&1 | Select-String "error"
```
Expected: every reported error's file path is under
`lib/src/components/`. This confirms the migration is complete and
correctly scoped — the only compile errors left are the ones Part 2 (the
resolver-migration plan) is responsible for fixing.

No commit for this task — it's verification only.
