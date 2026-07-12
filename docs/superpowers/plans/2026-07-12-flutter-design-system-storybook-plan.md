# Flutter Design System + Storybook App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `ui` Flutter design-system package plus the `ui_storybook` example app, with all 33 components built on primitive/semantic tokens and showcased in a runnable catalog.

**Architecture:** A single Flutter package (`ui`) exposes tokens (primitives → semantic → `AppTokens` InheritedWidget) and components built from low-level primitives (no Material widget wrapping). A nested `example/` app (`ui_storybook`) consumes `ui` as a path dependency and renders a flat catalog of components, each with a generic showcase page driven by a per-component `ComponentShowcaseSpec`.

**Tech Stack:** Flutter 3.19.0 (pinned via `.fvmrc`/fvm — use `fvm flutter ...` for all commands), Dart, no external state-management or testing packages (no automated tests per spec non-goals).

## Global Constraints

- No automated tests (widget/golden) — verification is **visual**, by running `ui_storybook` on an iOS or Android emulator/simulator after each task.
- No wrapping of Flutter Material widgets — components are built from low-level primitives (`GestureDetector`, `MouseRegion`, `Focus`, `CustomPaint`, `Container`, `AnimatedContainer`, etc.) for full visual control. The example app's `main.dart`/routing may use `MaterialApp`/`Navigator` for app-shell navigation only — that is app-shell plumbing, not a design-system component, and is exempt from this constraint.
- No dark mode / multi-theme switching this iteration; `AppTokens` shape must not preclude adding it later.
- No Storybook-style interactive controls/knobs — showcase sections are static matrices of pre-selected variant/size/state combinations.
- Components never hardcode colors/spacing/type — always read via `AppTokens.of(context)` (colors/typography) or `AppSpacing`/`AppRadius` primitives directly (spacing/radius have no semantic re-aliasing layer, per spec).
- Every component file: token block at top of `build()`, named private pure resolver functions (one per resolved property), live-state derivation via real gesture/focus/hover signals for interactive components, then layout — in that order. Disabled/loading are explicit constructor params, never inferred.
- Package name: `ui`. Example app: `ui_storybook`, bundle id `com.roojai.ui_storybook`.
- **Design-token assumption (not in spec, made here):** the spec's `SemanticColors` has no dedicated "brand/primary" color group — only `canvas`, `surface` (`base`/`alternative`/`inverted`), `content`, `border`, and the five `StatusColors` groups (`positive`/`negative`/`warning`/`alert`/`info`). Any component needing a strong "primary/brand" surface (e.g. `Button.primary`) uses `colors.surface.inverted` as background paired with `colors.content.onBrand`/`onBrandMuted` as foreground — this is the only surface/content pairing in the given token set designed for content-on-brand contrast. This mapping is used consistently everywhere a "primary" treatment is needed. If the user has an actual brand color spec, revisit this in a follow-up token change rather than during component build-out.

---

## Phase 1 — Foundation

### Task 1: Package scaffold (`ui`) and example app scaffold (`ui_storybook`)

**Files:**
- Create: `pubspec.yaml` (root, package `ui`)
- Create: `lib/ui.dart`
- Create: `analysis_options.yaml`
- Create: `example/pubspec.yaml` (app `ui_storybook`, path dependency on `../`)
- Create: `example/lib/main.dart` (placeholder `MaterialApp` + empty `Scaffold`)
- Create: `example/android/...`, `example/ios/...` (via `flutter create`)

**Interfaces:**
- Produces: the `ui` package importable as `package:ui/ui.dart` from `example/`.

- [ ] **Step 1: Create the package root**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter create --template=package --org com.roojai --project-name ui .
```

This generates `pubspec.yaml`, `lib/ui.dart`, `analysis_options.yaml`, and `test/` at the repo root. Since this repo has no automated tests per spec non-goals, delete the generated test scaffold:

```bash
rm -rf test
```

- [ ] **Step 2: Verify `pubspec.yaml` package name**

Open `pubspec.yaml` and confirm:

```yaml
name: ui
description: Roojai Flutter design system.
publish_to: 'none'
version: 0.1.0

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: '>=3.19.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_lints: ^3.0.0
```

- [ ] **Step 3: Create the nested example app**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter create --org com.roojai --project-name ui_storybook example
```

- [ ] **Step 4: Wire the example app's dependency on `ui` via path**

Edit `example/pubspec.yaml`, in the `dependencies:` block add:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ui:
    path: ../
```

- [ ] **Step 5: Set the bundle id**

For iOS, edit `example/ios/Runner.xcodeproj/project.pbxproj`: replace all `PRODUCT_BUNDLE_IDENTIFIER = com.roojai.ui;` (or whatever `flutter create` generated) occurrences with `PRODUCT_BUNDLE_IDENTIFIER = com.roojai.ui_storybook;`.

For Android, edit `example/android/app/build.gradle`: set `applicationId "com.roojai.ui_storybook"`.

- [ ] **Step 6: Replace `example/lib/main.dart` with a minimal placeholder**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ui_storybook',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(child: Text('ui_storybook')),
      ),
    );
  }
}
```

- [ ] **Step 7: Run on an emulator to verify the scaffold boots**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: app launches on the selected emulator/simulator showing centered "ui_storybook" text, no build errors.

- [ ] **Step 8: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add pubspec.yaml lib/ui.dart analysis_options.yaml example .gitignore
git commit -m "Scaffold ui package and ui_storybook example app"
```

---

### Task 2: Primitive tokens — colors, spacing, radius, typography, elevation, motion

**Files:**
- Create: `lib/src/tokens/primitives/app_colors.dart`
- Create: `lib/src/tokens/primitives/app_spacing.dart`
- Create: `lib/src/tokens/primitives/app_radius.dart`
- Create: `lib/src/tokens/primitives/app_typography.dart`
- Create: `lib/src/tokens/primitives/app_elevation.dart`
- Create: `lib/src/tokens/primitives/app_motion.dart`
- Modify: `lib/ui.dart` (export primitives are internal — not exported publicly; only semantic tokens and components are exported, see Task 4)

**Interfaces:**
- Produces: `AppColors`, `AppSpacing`, `AppRadius`, `AppTypeScale`, `AppElevation`, `AppMotion` static-const classes consumed by Task 3 (semantic tokens).

- [ ] **Step 1: Create `AppSpacing` and `AppRadius` (verbatim from spec)**

```dart
// lib/src/tokens/primitives/app_spacing.dart

/// Fixed, value-named spacing scale. The name *is* the pixel value —
/// components reference these directly, there is no semantic re-aliasing
/// layer for spacing.
class AppSpacing {
  AppSpacing._();

  static const double spacing0 = 0;
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing64 = 64;
  static const double spacing80 = 80;
  static const double spacing96 = 96;
}
```

```dart
// lib/src/tokens/primitives/app_radius.dart

/// Fixed, value-named radius scale. Same rationale as [AppSpacing].
class AppRadius {
  AppRadius._();

  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radiusFull = 9999;
}
```

- [ ] **Step 2: Create `AppColors` primitive swatches**

```dart
// lib/src/tokens/primitives/app_colors.dart

import 'package:flutter/widgets.dart';

/// Raw color swatches with no semantic meaning. Only the semantic token
/// layer (`lib/src/tokens/semantic/`) may reference these directly —
/// components must never import this file.
class AppColors {
  AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);
  static const Color gray950 = Color(0xFF09090B);

  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);

  static const Color green50 = Color(0xFFF0FDF4);
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red500 = Color(0xFFEF4444);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);

  static const Color orange50 = Color(0xFFFFF7ED);
  static const Color orange500 = Color(0xFFF97316);
  static const Color orange600 = Color(0xFFEA580C);
  static const Color orange700 = Color(0xFFC2410C);

  static const Color sky50 = Color(0xFFF0F9FF);
  static const Color sky500 = Color(0xFF0EA5E9);
  static const Color sky600 = Color(0xFF0284C7);
  static const Color sky700 = Color(0xFF0369A1);
}
```

- [ ] **Step 3: Create `AppTypeScale` primitive type ramp**

```dart
// lib/src/tokens/primitives/app_typography.dart

import 'package:flutter/widgets.dart';

/// Raw font-size/weight/line-height/letter-spacing values. Semantic
/// typography (`SemanticTypography`) composes these into named `TextStyle`s.
class AppTypeScale {
  AppTypeScale._();

  static const String fontFamily = 'Roboto';

  static const double size12 = 12;
  static const double size13 = 13;
  static const double size14 = 14;
  static const double size16 = 16;
  static const double size18 = 18;
  static const double size20 = 20;
  static const double size24 = 24;
  static const double size28 = 28;
  static const double size32 = 32;
  static const double size40 = 40;
  static const double size48 = 48;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.4;
  static const double lineHeightRelaxed = 1.6;
}
```

- [ ] **Step 4: Create `AppElevation` and `AppMotion` primitives**

```dart
// lib/src/tokens/primitives/app_elevation.dart

import 'package:flutter/widgets.dart';

/// Raw shadow definitions, keyed by elevation level.
class AppElevation {
  AppElevation._();

  static const List<BoxShadow> level0 = [];

  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x14000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}
```

```dart
// lib/src/tokens/primitives/app_motion.dart

import 'package:flutter/widgets.dart';

/// Raw animation durations and curves.
class AppMotion {
  AppMotion._();

  static const Duration durationFast = Duration(milliseconds: 100);
  static const Duration durationNormal = Duration(milliseconds: 200);
  static const Duration durationSlow = Duration(milliseconds: 300);

  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasized = Curves.easeOutCubic;
}
```

- [ ] **Step 5: Verify the package still analyzes clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!` (these files are not yet imported anywhere, which is fine — no dead-code warnings for unused public classes in a library).

- [ ] **Step 6: Commit**

```bash
git add lib/src/tokens/primitives
git commit -m "Add primitive design tokens: colors, spacing, radius, typography, elevation, motion"
```

### Task 3: Semantic tokens — colors and typography

**Files:**
- Create: `lib/src/tokens/semantic/semantic_colors.dart`
- Create: `lib/src/tokens/semantic/semantic_typography.dart`

**Interfaces:**
- Consumes: `AppColors` (Task 2), `AppTypeScale` (Task 2).
- Produces: `SemanticColors`, `CanvasColors`, `SurfaceColors`, `ContentColors`, `BorderColors`, `StatusColors`, `SemanticTypography` — the types every component's token block reads from `AppTokens.of(context)` (Task 4).

- [ ] **Step 1: Create the semantic color group classes (verbatim shape from spec)**

```dart
// lib/src/tokens/semantic/semantic_colors.dart

import 'package:flutter/widgets.dart';

import '../primitives/app_colors.dart';

class CanvasColors {
  const CanvasColors({required this.base, required this.alternative});

  // Canvas / Default — named `base` because `default` is a reserved word.
  final Color base;
  final Color alternative;
}

class SurfaceColors {
  const SurfaceColors({
    required this.base,
    required this.alternative,
    required this.inverted,
  });

  final Color base; // Surface / Default
  final Color alternative;
  final Color inverted;
}

class ContentColors {
  const ContentColors({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.placeholder,
    required this.onBrand,
    required this.onBrandMuted,
  });

  final Color primary;
  final Color secondary;
  final Color muted;
  final Color placeholder;
  final Color onBrand;
  final Color onBrandMuted;
}

class BorderColors {
  const BorderColors({required this.base, required this.strong});

  final Color base; // Border / Default
  final Color strong;
}

/// Shared shape for Positive / Negative / Warning / Alert / Info.
class StatusColors {
  const StatusColors({
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.ui,
    required this.uiHover,
    required this.text,
    required this.textStrong,
  });

  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color ui;
  final Color uiHover;
  final Color text;
  final Color textStrong;
}

class SemanticColors {
  const SemanticColors({
    required this.canvas,
    required this.surface,
    required this.content,
    required this.border,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.alert,
    required this.info,
  });

  final CanvasColors canvas;
  final SurfaceColors surface;
  final ContentColors content;
  final BorderColors border;
  final StatusColors positive;
  final StatusColors negative;
  final StatusColors warning;
  final StatusColors alert;
  final StatusColors info;

  /// The package's built-in default light theme values.
  static const SemanticColors defaultLight = SemanticColors(
    canvas: CanvasColors(
      base: AppColors.white,
      alternative: AppColors.gray50,
    ),
    surface: SurfaceColors(
      base: AppColors.white,
      alternative: AppColors.gray100,
      inverted: AppColors.gray900,
    ),
    content: ContentColors(
      primary: AppColors.gray900,
      secondary: AppColors.gray600,
      muted: AppColors.gray500,
      placeholder: AppColors.gray400,
      onBrand: AppColors.white,
      onBrandMuted: AppColors.gray300,
    ),
    border: BorderColors(
      base: AppColors.gray200,
      strong: AppColors.gray400,
    ),
    positive: StatusColors(
      surface: AppColors.green50,
      surfaceStrong: AppColors.green500,
      border: AppColors.green500,
      ui: AppColors.green600,
      uiHover: AppColors.green700,
      text: AppColors.green600,
      textStrong: AppColors.green700,
    ),
    negative: StatusColors(
      surface: AppColors.red50,
      surfaceStrong: AppColors.red500,
      border: AppColors.red500,
      ui: AppColors.red600,
      uiHover: AppColors.red700,
      text: AppColors.red600,
      textStrong: AppColors.red700,
    ),
    warning: StatusColors(
      surface: AppColors.amber50,
      surfaceStrong: AppColors.amber500,
      border: AppColors.amber500,
      ui: AppColors.amber600,
      uiHover: AppColors.amber700,
      text: AppColors.amber600,
      textStrong: AppColors.amber700,
    ),
    alert: StatusColors(
      surface: AppColors.orange50,
      surfaceStrong: AppColors.orange500,
      border: AppColors.orange500,
      ui: AppColors.orange600,
      uiHover: AppColors.orange700,
      text: AppColors.orange600,
      textStrong: AppColors.orange700,
    ),
    info: StatusColors(
      surface: AppColors.sky50,
      surfaceStrong: AppColors.sky500,
      border: AppColors.sky500,
      ui: AppColors.sky600,
      uiHover: AppColors.sky700,
      text: AppColors.sky600,
      textStrong: AppColors.sky700,
    ),
  );
}
```

- [ ] **Step 2: Create `SemanticTypography` (verbatim shape from spec)**

```dart
// lib/src/tokens/semantic/semantic_typography.dart

import 'package:flutter/widgets.dart';

import '../primitives/app_typography.dart';

class SemanticTypography {
  const SemanticTypography({
    required this.displayMd,
    required this.displaySm,
    required this.h1,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.bodyLg,
    required this.bodyMd,
    required this.bodySm,
    required this.labelLg,
    required this.labelMd,
    required this.labelSm,
    required this.captionMd,
    required this.captionSm,
    required this.overline,
    required this.small,
    required this.footnote,
  });

  final TextStyle displayMd;
  final TextStyle displaySm;
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle bodyLg;
  final TextStyle bodyMd;
  final TextStyle bodySm;
  final TextStyle labelLg;
  final TextStyle labelMd;
  final TextStyle labelSm;
  final TextStyle captionMd;
  final TextStyle captionSm;
  final TextStyle overline;
  final TextStyle small;
  final TextStyle footnote;

  static const SemanticTypography defaultScale = SemanticTypography(
    displayMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size48,
      fontWeight: AppTypeScale.bold,
      height: AppTypeScale.lineHeightTight,
    ),
    displaySm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size40,
      fontWeight: AppTypeScale.bold,
      height: AppTypeScale.lineHeightTight,
    ),
    h1: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size32,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightTight,
    ),
    h2: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size28,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightTight,
    ),
    h3: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size24,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
    ),
    h4: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size20,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodyLg: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size18,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodyMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size16,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    bodySm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size14,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelLg: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size16,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size14,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    labelSm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.medium,
      height: AppTypeScale.lineHeightNormal,
    ),
    captionMd: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    captionSm: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    overline: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.semibold,
      height: AppTypeScale.lineHeightNormal,
      letterSpacing: 1.2,
    ),
    small: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size13,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightNormal,
    ),
    footnote: TextStyle(
      fontFamily: AppTypeScale.fontFamily,
      fontSize: AppTypeScale.size12,
      fontWeight: AppTypeScale.regular,
      height: AppTypeScale.lineHeightRelaxed,
    ),
  );
}
```

- [ ] **Step 3: Verify analysis is clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/src/tokens/semantic
git commit -m "Add semantic color and typography tokens"
```

---

### Task 4: `AppTokens` InheritedWidget + `AppTokensScope` + public exports

**Files:**
- Create: `lib/src/theme/app_tokens.dart`
- Create: `lib/src/theme/app_tokens_scope.dart`
- Modify: `lib/ui.dart`

**Interfaces:**
- Consumes: `SemanticColors`, `SemanticTypography` (Task 3).
- Produces: `AppTokens.of(BuildContext) -> AppTokens` with `.colors` (`SemanticColors`) and `.typography` (`SemanticTypography`) — every component (Task 6 onward) calls this at the top of `build()`. `AppTokensScope` widget installed once at the app root.

- [ ] **Step 1: Create `AppTokens`**

```dart
// lib/src/theme/app_tokens.dart

import 'package:flutter/widgets.dart';

import '../tokens/semantic/semantic_colors.dart';
import '../tokens/semantic/semantic_typography.dart';

/// Exposes the active semantic token set to the widget tree. Components
/// read tokens exclusively through `AppTokens.of(context)` — never by
/// hardcoding values or importing primitives directly.
class AppTokens extends InheritedWidget {
  const AppTokens({
    super.key,
    required this.colors,
    required this.typography,
    required super.child,
  });

  final SemanticColors colors;
  final SemanticTypography typography;

  static AppTokens of(BuildContext context) {
    final tokens = context.dependOnInheritedWidgetOfExactType<AppTokens>();
    assert(
      tokens != null,
      'AppTokens.of() called with a context that has no AppTokensScope '
      'ancestor. Wrap the app root in AppTokensScope.',
    );
    return tokens!;
  }

  @override
  bool updateShouldNotify(AppTokens oldWidget) {
    return colors != oldWidget.colors || typography != oldWidget.typography;
  }
}
```

- [ ] **Step 2: Create `AppTokensScope`**

```dart
// lib/src/theme/app_tokens_scope.dart

import 'package:flutter/widgets.dart';

import '../tokens/semantic/semantic_colors.dart';
import '../tokens/semantic/semantic_typography.dart';
import 'app_tokens.dart';

/// Installs [AppTokens] at the app root. Defaults to the package's built-in
/// token values; a consuming app may pass its own brand tokens to retheme
/// every component without touching component code.
class AppTokensScope extends StatelessWidget {
  const AppTokensScope({
    super.key,
    this.colors = SemanticColors.defaultLight,
    this.typography = SemanticTypography.defaultScale,
    required this.child,
  });

  final SemanticColors colors;
  final SemanticTypography typography;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppTokens(
      colors: colors,
      typography: typography,
      child: child,
    );
  }
}
```

- [ ] **Step 3: Wire public exports in `lib/ui.dart`**

```dart
// lib/ui.dart

library ui;

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

(Component exports are added incrementally in Task 6 onward, one `export` line per component as it's built.)

- [ ] **Step 4: Verify analysis is clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/src/theme lib/ui.dart
git commit -m "Add AppTokens InheritedWidget and AppTokensScope"
```

---

### Task 5: Empty catalog shell — `CatalogHomePage` wired into `main.dart`

**Files:**
- Create: `example/lib/catalog/catalog_home_page.dart`
- Modify: `example/lib/main.dart`

**Interfaces:**
- Consumes: `AppTokensScope` (Task 4).
- Produces: `CatalogHomePage` widget — a `StatelessWidget` rendering a `List<String>` of component names (empty for now; Task 9 onward appends to it).

- [ ] **Step 1: Create `CatalogHomePage`**

```dart
// example/lib/catalog/catalog_home_page.dart

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

/// Flat, alphabetically sorted list of every design-system component.
/// Component entries are appended here as each is built (Task 9 onward).
class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  static const List<String> componentNames = <String>[];

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Scaffold(
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text('Components', style: typography.h3),
      ),
      body: componentNames.isEmpty
          ? Center(
              child: Text(
                'No components yet',
                style: typography.bodyMd.copyWith(color: colors.content.muted),
              ),
            )
          : ListView.separated(
              itemCount: componentNames.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border.base,
              ),
              itemBuilder: (context, index) {
                final name = componentNames[index];
                return ListTile(
                  title: Text(name, style: typography.bodyMd),
                  onTap: () {
                    // Navigation to ComponentShowcasePage wired in Task 8.
                  },
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 2: Wire `AppTokensScope` and `CatalogHomePage` into `main.dart`**

```dart
// example/lib/main.dart

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'catalog/catalog_home_page.dart';

void main() {
  runApp(const StorybookApp());
}

class StorybookApp extends StatelessWidget {
  const StorybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTokensScope(
      child: MaterialApp(
        title: 'ui_storybook',
        debugShowCheckedModeBanner: false,
        home: const CatalogHomePage(),
      ),
    );
  }
}
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: app launches showing an app bar titled "Components" and the body text "No components yet" (styled per `typography.bodyMd`/`colors.content.muted`), no build errors, no red error screens.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib
git commit -m "Add empty CatalogHomePage shell wired to AppTokensScope"
```

---

## Phase 2 — Reference component: Button

### Task 6: Button enums — variant, size, state

**Files:**
- Create: `lib/src/components/button/button_variant.dart`
- Create: `lib/src/components/button/button_size.dart`
- Create: `lib/src/components/button/button_state.dart`

**Interfaces:**
- Produces: `ButtonVariant { primary, secondary, outline, ghost, destructive }`, `ButtonSize { sm, md, lg }`, `ButtonState { enabled, hovered, pressed, focused, disabled, loading }` — consumed by Task 7 (`Button` widget) and Task 11 (`ButtonShowcaseSpec`).

- [ ] **Step 1: Create the enums**

```dart
// lib/src/components/button/button_variant.dart

enum ButtonVariant { primary, secondary, outline, ghost, destructive }
```

```dart
// lib/src/components/button/button_size.dart

enum ButtonSize { sm, md, lg }
```

```dart
// lib/src/components/button/button_state.dart

/// Shared vocabulary for Button's visual states. Interactive builds derive
/// this at runtime from real gesture/focus signals; the static showcase
/// (Task 11) renders one Button per value directly.
enum ButtonState { enabled, hovered, pressed, focused, disabled, loading }
```

- [ ] **Step 2: Verify analysis is clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/src/components/button/button_variant.dart lib/src/components/button/button_size.dart lib/src/components/button/button_state.dart
git commit -m "Add Button variant/size/state enums"
```

---

### Task 7: `Button` widget — tokens, resolvers, live state, layout

**Files:**
- Create: `lib/src/components/button/button.dart`
- Modify: `lib/ui.dart`

**Interfaces:**
- Consumes: `ButtonVariant`, `ButtonSize`, `ButtonState` (Task 6); `AppTokens.of(context)` (Task 4); `AppSpacing`, `AppRadius` (Task 2).
- Produces: `Button` widget with constructor `Button({required String label, required VoidCallback? onPressed, ButtonVariant variant = ButtonVariant.primary, ButtonSize size = ButtonSize.md, bool disabled = false, bool loading = false})` — consumed by Task 11 (`ButtonShowcaseSpec`) and every later component that composes a button (e.g. Dialog actions, Empty's action slot).

- [ ] **Step 1: Create the `Button` widget**

```dart
// lib/src/components/button/button.dart

import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'button_size.dart';
import 'button_state.dart';
import 'button_variant.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.disabled = false,
    this.loading = false,
    this.showcaseState,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final bool loading;

  /// Showcase-only override: forces the widget to render as if it were in
  /// this state, used only for states that are inherently transient and
  /// cannot be held via real gesture signals in a static screenshot (e.g.
  /// "pressed", "hovered", "focused"). Null in normal app usage — real
  /// interaction drives state instead. See Task 11.
  final ButtonState? showcaseState;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  ButtonState get _liveState {
    if (widget.showcaseState != null) return widget.showcaseState!;
    if (widget.disabled) return ButtonState.disabled;
    if (widget.loading) return ButtonState.loading;
    if (_isPressed) return ButtonState.pressed;
    if (_isFocused) return ButtonState.focused;
    if (_isHovered) return ButtonState.hovered;
    return ButtonState.enabled;
  }

  bool get _interactive =>
      !widget.disabled && !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    // Semantic tokens used by Button — change these bindings to restyle
    // the component without touching layout/behavior code below.
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final state = _liveState;
    final backgroundColor =
        _resolveBackgroundColor(colors, widget.variant, state);
    final foregroundColor =
        _resolveForegroundColor(colors, widget.variant, state);
    final borderColor = _resolveBorderColor(colors, widget.variant, state);
    final textStyle = _resolveTextStyle(typography, widget.size);
    final padding = _resolvePadding(widget.size);
    final gap = _resolveIconGap(widget.size);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state == ButtonState.loading) ...[
          SizedBox(
            width: textStyle.fontSize,
            height: textStyle.fontSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          SizedBox(width: gap),
        ],
        Text(widget.label, style: textStyle.copyWith(color: foregroundColor)),
      ],
    );

    content = MouseRegion(
      cursor: _interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        focusNode: _focusNode,
        canRequestFocus: _interactive,
        child: GestureDetector(
          onTapDown: _interactive ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: _interactive ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: _interactive ? () => setState(() => _isPressed = false) : null,
          onTap: _interactive ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.radius8),
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );

    return content;
  }
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonState state,
) {
  if (state == ButtonState.disabled) return colors.surface.alternative;
  switch (variant) {
    case ButtonVariant.primary:
      return state == ButtonState.hovered || state == ButtonState.pressed
          ? colors.content.primary
          : colors.surface.inverted;
    case ButtonVariant.secondary:
      return state == ButtonState.hovered || state == ButtonState.pressed
          ? colors.surface.alternative
          : colors.surface.base;
    case ButtonVariant.outline:
    case ButtonVariant.ghost:
      return state == ButtonState.hovered || state == ButtonState.pressed
          ? colors.surface.alternative
          : const Color(0x00000000);
    case ButtonVariant.destructive:
      return state == ButtonState.hovered || state == ButtonState.pressed
          ? colors.negative.uiHover
          : colors.negative.ui;
  }
}

Color _resolveForegroundColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonState state,
) {
  if (state == ButtonState.disabled) return colors.content.placeholder;
  switch (variant) {
    case ButtonVariant.primary:
      return colors.content.onBrand;
    case ButtonVariant.secondary:
    case ButtonVariant.outline:
    case ButtonVariant.ghost:
      return colors.content.primary;
    case ButtonVariant.destructive:
      return colors.content.onBrand;
  }
}

Color? _resolveBorderColor(
  SemanticColors colors,
  ButtonVariant variant,
  ButtonState state,
) {
  if (variant != ButtonVariant.outline) return null;
  return state == ButtonState.disabled ? colors.border.base : colors.border.strong;
}

TextStyle _resolveTextStyle(SemanticTypography typography, ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return typography.labelSm;
    case ButtonSize.md:
      return typography.labelMd;
    case ButtonSize.lg:
      return typography.labelLg;
  }
}

EdgeInsets _resolvePadding(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      );
    case ButtonSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing8,
      );
    case ButtonSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing20,
        vertical: AppSpacing.spacing12,
      );
  }
}

double _resolveIconGap(ButtonSize size) {
  switch (size) {
    case ButtonSize.sm:
      return AppSpacing.spacing4;
    case ButtonSize.md:
    case ButtonSize.lg:
      return AppSpacing.spacing8;
  }
}
```

- [ ] **Step 2: Export `Button` and its enums from `lib/ui.dart`**

```dart
// lib/ui.dart — add under a new "// Components." section at the bottom

// Components.
export 'src/components/button/button.dart';
export 'src/components/button/button_variant.dart';
export 'src/components/button/button_size.dart';
export 'src/components/button/button_state.dart';
```

- [ ] **Step 3: Verify analysis is clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/src/components/button/button.dart lib/ui.dart
git commit -m "Add Button widget: tokens, resolvers, live state, layout"
```

---

### Task 8: `ComponentShowcaseSpec` data model + generic `ComponentShowcasePage`

**Files:**
- Create: `example/lib/catalog/component_showcase_spec.dart`
- Create: `example/lib/catalog/component_showcase_page.dart`

**Interfaces:**
- Produces: `ComponentShowcaseSpec` (`{ String title, List<Widget> Function()? variantsBuilder, List<Widget> Function()? sizesBuilder, List<Widget> Function()? statesBuilder }`) and `ComponentShowcasePage extends StatelessWidget` (`{ required ComponentShowcaseSpec spec }`) — consumed by every per-component spec file from Task 11 onward, and by catalog navigation (Task 9).

- [ ] **Step 1: Create the `ComponentShowcaseSpec` data model**

```dart
// example/lib/catalog/component_showcase_spec.dart

import 'package:flutter/widgets.dart';

/// Declares how a single design-system component is showcased. Each
/// builder returns one widget per showcased value; a null builder means
/// that axis doesn't apply to this component and its section is omitted.
class ComponentShowcaseSpec {
  const ComponentShowcaseSpec({
    required this.title,
    this.variantsBuilder,
    this.sizesBuilder,
    this.statesBuilder,
  });

  final String title;
  final List<Widget> Function()? variantsBuilder;
  final List<Widget> Function()? sizesBuilder;
  final List<Widget> Function()? statesBuilder;
}
```

- [ ] **Step 2: Create the generic `ComponentShowcasePage`**

```dart
// example/lib/catalog/component_showcase_page.dart

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'component_showcase_spec.dart';

/// Single reusable detail page. Renders each non-null builder on [spec] as
/// a labeled section with its widgets laid out in a wrapped row. Written
/// once, reused for all 33 components.
class ComponentShowcasePage extends StatelessWidget {
  const ComponentShowcasePage({super.key, required this.spec});

  final ComponentShowcaseSpec spec;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    final sections = <Widget>[];
    if (spec.variantsBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'Variants',
        widgets: spec.variantsBuilder!(),
      ));
    }
    if (spec.sizesBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'Sizes',
        widgets: spec.sizesBuilder!(),
      ));
    }
    if (spec.statesBuilder != null) {
      sections.add(_ShowcaseSection(
        label: 'States',
        widgets: spec.statesBuilder!(),
      ));
    }

    return Scaffold(
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text(spec.title, style: typography.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        children: sections,
      ),
    );
  }
}

class _ShowcaseSection extends StatelessWidget {
  const _ShowcaseSection({required this.label, required this.widgets});

  final String label;
  final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.overline.copyWith(color: colors.content.muted),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          Wrap(
            spacing: AppSpacing.spacing12,
            runSpacing: AppSpacing.spacing12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: widgets,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Verify analysis is clean**

```bash
cd /Users/eakl/dev/projects/roojai
fvm flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/component_showcase_spec.dart example/lib/catalog/component_showcase_page.dart
git commit -m "Add generic ComponentShowcaseSpec model and ComponentShowcasePage"
```

---

### Task 9: `CatalogHomePage` navigation — spec registry + routing to `ComponentShowcasePage`

**Files:**
- Create: `example/lib/catalog/component_registry.dart`
- Modify: `example/lib/catalog/catalog_home_page.dart`

**Interfaces:**
- Consumes: `ComponentShowcaseSpec`, `ComponentShowcasePage` (Task 8).
- Produces: `componentRegistry -> Map<String, ComponentShowcaseSpec Function()>` — a lazily-built, alphabetically-iterated registry. Every subsequent component task (Task 11 onward) adds exactly one entry to this map and one import line; nothing else in `catalog_home_page.dart` changes again.

- [ ] **Step 1: Create the empty registry**

```dart
// example/lib/catalog/component_registry.dart

import 'component_showcase_spec.dart';

/// Maps a component's display name to a function building its
/// ComponentShowcaseSpec. Kept as a function (not a pre-built spec) so
/// specs are only constructed when their showcase page is opened.
/// New components are registered here, one line per component, keyed
/// alphabetically for readability (iteration order in CatalogHomePage
/// sorts explicitly, so registration order here does not matter).
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  // Entries added starting Task 11 (ButtonShowcaseSpec).
};
```

- [ ] **Step 2: Rewrite `CatalogHomePage` to read from the registry and navigate**

```dart
// example/lib/catalog/catalog_home_page.dart

import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

import 'component_registry.dart';
import 'component_showcase_page.dart';

class CatalogHomePage extends StatelessWidget {
  const CatalogHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final names = componentRegistry.keys.toList()..sort();

    return Scaffold(
      backgroundColor: colors.canvas.base,
      appBar: AppBar(
        backgroundColor: colors.canvas.base,
        elevation: 0,
        title: Text('Components', style: typography.h3),
      ),
      body: names.isEmpty
          ? Center(
              child: Text(
                'No components yet',
                style: typography.bodyMd.copyWith(color: colors.content.muted),
              ),
            )
          : ListView.separated(
              itemCount: names.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colors.border.base,
              ),
              itemBuilder: (context, index) {
                final name = names[index];
                return ListTile(
                  title: Text(name, style: typography.bodyMd),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ComponentShowcasePage(
                          spec: componentRegistry[name]!(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: same empty-state screen as Task 5 (registry is still empty), no build errors.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog
git commit -m "Wire CatalogHomePage to a component registry with navigation"
```

---

### Task 10: `ButtonShowcaseSpec` — register Button in the catalog

**Files:**
- Create: `example/lib/catalog/specs/button_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Button`, `ButtonVariant`, `ButtonSize`, `ButtonState` (Task 7, Task 6); `ComponentShowcaseSpec` (Task 8).
- Produces: `buildButtonShowcaseSpec() -> ComponentShowcaseSpec`, registered under key `"Button"`.

- [ ] **Step 1: Create `button_showcase_spec.dart`**

```dart
// example/lib/catalog/specs/button_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildButtonShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Button',
    variantsBuilder: () => ButtonVariant.values
        .map((variant) => Button(
              label: variant.name,
              variant: variant,
              onPressed: () {},
            ))
        .toList(),
    sizesBuilder: () => ButtonSize.values
        .map((size) => Button(
              label: size.name,
              size: size,
              onPressed: () {},
            ))
        .toList(),
    // Real constructor flags drive disabled/loading; hovered/pressed/
    // focused are display-only overrides via showcaseState since they are
    // inherently transient and cannot be held in a static screenshot.
    statesBuilder: () => [
      const Button(label: 'enabled', onPressed: _noop),
      const Button(
        label: 'hovered',
        onPressed: _noop,
        showcaseState: ButtonState.hovered,
      ),
      const Button(
        label: 'pressed',
        onPressed: _noop,
        showcaseState: ButtonState.pressed,
      ),
      const Button(
        label: 'focused',
        onPressed: _noop,
        showcaseState: ButtonState.focused,
      ),
      const Button(label: 'disabled', onPressed: null, disabled: true),
      const Button(label: 'loading', onPressed: _noop, loading: true),
    ],
  );
}

void _noop() {}
```

- [ ] **Step 2: Register Button in `component_registry.dart`**

```dart
// example/lib/catalog/component_registry.dart

import 'component_showcase_spec.dart';
import 'specs/button_showcase_spec.dart';

final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Button': buildButtonShowcaseSpec,
};
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Button" appears in the catalog list; tapping it opens a detail page with three sections — "Variants" (5 buttons: primary, secondary, outline, ghost, destructive), "Sizes" (3 buttons: sm, md, lg), "States" (6 buttons: enabled, hovered, pressed, focused, disabled, loading). Manually tap/hold/focus (via keyboard tab, on desktop/web run) the "enabled" button in a fresh run of the app (not the showcase page) to confirm real hover/press/focus signals visually change its appearance the same way the static "hovered"/"pressed"/"focused" showcase entries look.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog
git commit -m "Add ButtonShowcaseSpec and register Button in the catalog"
```

---

## Phase 3 — Remaining components

Every task in this phase follows the exact shape established by Button
(Tasks 6–10): enum file(s) → widget file (token block → resolvers → live
state if interactive → layout) → showcase spec → registry entry → emulator
verify → commit. Steps below show the concrete code for each component
rather than repeating that narrative.

---

### Task 11: Avatar

**Files:**
- Create: `lib/src/components/avatar/avatar_size.dart`
- Create: `lib/src/components/avatar/avatar.dart`
- Create: `example/lib/catalog/specs/avatar_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `AvatarSize { xs, sm, md, lg, xl }`, `Avatar({String? imageUrl, required String initials, AvatarSize size = AvatarSize.md})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/avatar/avatar_size.dart

enum AvatarSize { xs, sm, md, lg, xl }
```

```dart
// lib/src/components/avatar/avatar.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'avatar_size.dart';

/// Circular avatar showing an image, falling back to initials on a tinted
/// background when no image is provided or the image fails to load.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = AvatarSize.md,
  });

  final String? imageUrl;
  final String initials;
  final AvatarSize size;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final diameter = _resolveDiameter(size);
    final textStyle = _resolveTextStyle(typography, size);

    return ClipOval(
      child: Container(
        width: diameter,
        height: diameter,
        color: colors.surface.alternative,
        alignment: Alignment.center,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(
                  initials: initials,
                  textStyle: textStyle,
                  color: colors.content.secondary,
                ),
              )
            : _Initials(
                initials: initials,
                textStyle: textStyle,
                color: colors.content.secondary,
              ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.initials,
    required this.textStyle,
    required this.color,
  });

  final String initials;
  final TextStyle textStyle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(initials, style: textStyle.copyWith(color: color));
  }
}

double _resolveDiameter(AvatarSize size) {
  switch (size) {
    case AvatarSize.xs:
      return 24;
    case AvatarSize.sm:
      return 32;
    case AvatarSize.md:
      return 40;
    case AvatarSize.lg:
      return 56;
    case AvatarSize.xl:
      return 80;
  }
}

TextStyle _resolveTextStyle(SemanticTypography typography, AvatarSize size) {
  switch (size) {
    case AvatarSize.xs:
    case AvatarSize.sm:
      return typography.captionSm;
    case AvatarSize.md:
      return typography.labelSm;
    case AvatarSize.lg:
      return typography.labelLg;
    case AvatarSize.xl:
      return typography.h4;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/avatar_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildAvatarShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Avatar',
    sizesBuilder: () => AvatarSize.values
        .map((size) => Avatar(initials: 'AB', size: size))
        .toList(),
    statesBuilder: () => const [
      Avatar(initials: 'CD'),
      Avatar(
        initials: 'EF',
        imageUrl: 'https://example.com/does-not-exist.png',
      ),
    ],
  );
}
```

Add to `lib/ui.dart` (Components section):

```dart
export 'src/components/avatar/avatar.dart';
export 'src/components/avatar/avatar_size.dart';
```

Add to `example/lib/catalog/component_registry.dart` (import + map entry):

```dart
import 'specs/avatar_showcase_spec.dart';
// ...
'Avatar': buildAvatarShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Avatar" in the catalog list; detail page shows 5 sizes ascending and a "States" section with an initials-fallback avatar and an image-load-failure avatar that also falls back to initials.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/avatar lib/ui.dart example/lib/catalog
git commit -m "Add Avatar component"
```

---

### Task 12: Badge

**Files:**
- Create: `lib/src/components/badge/badge_variant.dart`
- Create: `lib/src/components/badge/badge.dart`
- Create: `example/lib/catalog/specs/badge_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `BadgeVariant { primary, secondary, outline, positive, negative, warning }`, `Badge({required String label, BadgeVariant variant = BadgeVariant.primary})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/badge/badge_variant.dart

enum BadgeVariant { primary, secondary, outline, positive, negative, warning }
```

```dart
// lib/src/components/badge/badge.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'badge_variant.dart';

class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
  });

  final String label;
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final backgroundColor = _resolveBackgroundColor(colors, variant);
    final textColor = _resolveTextColor(colors, variant);
    final borderColor = _resolveBorderColor(colors, variant);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing8,
        vertical: AppSpacing.spacing2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Text(label, style: typography.captionSm.copyWith(color: textColor)),
    );
  }
}

Color _resolveBackgroundColor(SemanticColors colors, BadgeVariant variant) {
  switch (variant) {
    case BadgeVariant.primary:
      return colors.surface.inverted;
    case BadgeVariant.secondary:
      return colors.surface.alternative;
    case BadgeVariant.outline:
      return const Color(0x00000000);
    case BadgeVariant.positive:
      return colors.positive.surface;
    case BadgeVariant.negative:
      return colors.negative.surface;
    case BadgeVariant.warning:
      return colors.warning.surface;
  }
}

Color _resolveTextColor(SemanticColors colors, BadgeVariant variant) {
  switch (variant) {
    case BadgeVariant.primary:
      return colors.content.onBrand;
    case BadgeVariant.secondary:
    case BadgeVariant.outline:
      return colors.content.primary;
    case BadgeVariant.positive:
      return colors.positive.textStrong;
    case BadgeVariant.negative:
      return colors.negative.textStrong;
    case BadgeVariant.warning:
      return colors.warning.textStrong;
  }
}

Color? _resolveBorderColor(SemanticColors colors, BadgeVariant variant) {
  return variant == BadgeVariant.outline ? colors.border.strong : null;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/badge_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildBadgeShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Badge',
    variantsBuilder: () => BadgeVariant.values
        .map((variant) => Badge(label: variant.name, variant: variant))
        .toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/badge/badge.dart';
export 'src/components/badge/badge_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/badge_showcase_spec.dart';
// ...
'Badge': buildBadgeShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Badge" in catalog; detail page's "Variants" section shows 6 pill-shaped badges with distinct backgrounds/text colors per variant.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/badge lib/ui.dart example/lib/catalog
git commit -m "Add Badge component"
```

---

### Task 13: Label

**Files:**
- Create: `lib/src/components/label/label.dart`
- Create: `example/lib/catalog/specs/label_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `Label({required String text, bool required = false, bool disabled = false})`. No variant/size axis.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/label/label.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';

/// Form-field label. `required` appends an asterisk in the negative/error
/// color; `disabled` mutes the text color to match a disabled field.
class Label extends StatelessWidget {
  const Label({
    super.key,
    required this.text,
    this.required = false,
    this.disabled = false,
  });

  final String text;
  final bool required;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final textColor = _resolveTextColor(colors, disabled);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: typography.labelMd.copyWith(color: textColor)),
        if (required) ...[
          const SizedBox(width: AppSpacing.spacing2),
          Text('*', style: typography.labelMd.copyWith(color: colors.negative.text)),
        ],
      ],
    );
  }
}

Color _resolveTextColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.content.primary;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/label_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildLabelShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Label',
    statesBuilder: () => const [
      Label(text: 'Default'),
      Label(text: 'Required', required: true),
      Label(text: 'Disabled', disabled: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/label/label.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/label_showcase_spec.dart';
// ...
'Label': buildLabelShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Label" in catalog; detail page's "States" section shows plain, required (asterisk in negative color), and disabled (muted) labels.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/label lib/ui.dart example/lib/catalog
git commit -m "Add Label component"
```

---

### Task 14: Separator

**Files:**
- Create: `lib/src/components/separator/separator_orientation.dart`
- Create: `lib/src/components/separator/separator.dart`
- Create: `example/lib/catalog/specs/separator_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `SeparatorOrientation { horizontal, vertical }`, `Separator({SeparatorOrientation orientation = SeparatorOrientation.horizontal, double length = 100})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/separator/separator_orientation.dart

enum SeparatorOrientation { horizontal, vertical }
```

```dart
// lib/src/components/separator/separator.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import 'separator_orientation.dart';

class Separator extends StatelessWidget {
  const Separator({
    super.key,
    this.orientation = SeparatorOrientation.horizontal,
    this.length = 100,
  });

  final SeparatorOrientation orientation;
  final double length;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final isHorizontal = orientation == SeparatorOrientation.horizontal;

    return Container(
      width: isHorizontal ? length : 1,
      height: isHorizontal ? 1 : length,
      color: colors.border.base,
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/separator_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSeparatorShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Separator',
    variantsBuilder: () => const [
      Separator(orientation: SeparatorOrientation.horizontal, length: 160),
      Separator(orientation: SeparatorOrientation.vertical, length: 48),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/separator/separator.dart';
export 'src/components/separator/separator_orientation.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/separator_showcase_spec.dart';
// ...
'Separator': buildSeparatorShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Separator" in catalog; detail page's "Variants" section shows one horizontal line and one vertical line, both in the border color.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/separator lib/ui.dart example/lib/catalog
git commit -m "Add Separator component"
```

---

### Task 15: Spinner

**Files:**
- Create: `lib/src/components/spinner/spinner_size.dart`
- Create: `lib/src/components/spinner/spinner.dart`
- Create: `example/lib/catalog/specs/spinner_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `SpinnerSize { sm, md, lg }`, `Spinner({SpinnerSize size = SpinnerSize.md, bool inverted = false})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/spinner/spinner_size.dart

enum SpinnerSize { sm, md, lg }
```

```dart
// lib/src/components/spinner/spinner.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'spinner_size.dart';

/// Indeterminate loading indicator. `inverted` swaps to the on-brand color
/// for use on dark/brand-colored backgrounds (e.g. inside a primary Button).
class Spinner extends StatelessWidget {
  const Spinner({super.key, this.size = SpinnerSize.md, this.inverted = false});

  final SpinnerSize size;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final diameter = _resolveDiameter(size);
    final color = _resolveColor(colors, inverted);

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CircularProgressIndicator(
        strokeWidth: diameter / 8,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

double _resolveDiameter(SpinnerSize size) {
  switch (size) {
    case SpinnerSize.sm:
      return 16;
    case SpinnerSize.md:
      return 24;
    case SpinnerSize.lg:
      return 40;
  }
}

Color _resolveColor(SemanticColors colors, bool inverted) {
  return inverted ? colors.content.onBrand : colors.content.secondary;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/spinner_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSpinnerShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Spinner',
    sizesBuilder: () =>
        SpinnerSize.values.map((size) => Spinner(size: size)).toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/spinner/spinner.dart';
export 'src/components/spinner/spinner_size.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/spinner_showcase_spec.dart';
// ...
'Spinner': buildSpinnerShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Spinner" in catalog; detail page's "Sizes" section shows 3 spinning indicators, animating continuously, ascending in diameter.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/spinner lib/ui.dart example/lib/catalog
git commit -m "Add Spinner component"
```

---

### Task 16: Skeleton

**Files:**
- Create: `lib/src/components/skeleton/skeleton_shape.dart`
- Create: `lib/src/components/skeleton/skeleton.dart`
- Create: `example/lib/catalog/specs/skeleton_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `SkeletonShape { rectangle, circle, text }`, `Skeleton({SkeletonShape shape = SkeletonShape.rectangle, double width = 120, double height = 16})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/skeleton/skeleton_shape.dart

enum SkeletonShape { rectangle, circle, text }
```

```dart
// lib/src/components/skeleton/skeleton.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import 'skeleton_shape.dart';

/// Pulsing placeholder block shown while real content loads.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.shape = SkeletonShape.rectangle,
    this.width = 120,
    this.height = 16,
  });

  final SkeletonShape shape;
  final double width;
  final double height;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final radius = _resolveRadius(widget.shape, widget.height);
    final diameter = widget.shape == SkeletonShape.circle
        ? widget.height
        : null;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.5 + (_controller.value * 0.3);
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        width: diameter ?? widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.surface.alternative,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

double _resolveRadius(SkeletonShape shape, double height) {
  switch (shape) {
    case SkeletonShape.rectangle:
      return AppRadius.radius8;
    case SkeletonShape.circle:
      return height / 2;
    case SkeletonShape.text:
      return AppRadius.radius4;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/skeleton_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSkeletonShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Skeleton',
    variantsBuilder: () => const [
      Skeleton(shape: SkeletonShape.rectangle, width: 160, height: 100),
      Skeleton(shape: SkeletonShape.circle, height: 48),
      Skeleton(shape: SkeletonShape.text, width: 200, height: 12),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/skeleton/skeleton.dart';
export 'src/components/skeleton/skeleton_shape.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/skeleton_showcase_spec.dart';
// ...
'Skeleton': buildSkeletonShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Skeleton" in catalog; detail page's "Variants" section shows a rectangle block, a circle, and a thin text-line block, all gently pulsing in opacity.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/skeleton lib/ui.dart example/lib/catalog
git commit -m "Add Skeleton component"
```

---

### Task 17: Progress

**Files:**
- Create: `lib/src/components/progress/progress_variant.dart`
- Create: `lib/src/components/progress/progress.dart`
- Create: `example/lib/catalog/specs/progress_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `ProgressVariant { primary, positive, warning, negative }`, `Progress({required double value, ProgressVariant variant = ProgressVariant.primary})` (`value` is 0.0–1.0; a null `value` renders indeterminate).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/progress/progress_variant.dart

enum ProgressVariant { primary, positive, warning, negative }
```

```dart
// lib/src/components/progress/progress.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'progress_variant.dart';

/// Horizontal progress bar. Pass `null` for [value] to render an
/// indeterminate (animated, unbounded) bar.
class Progress extends StatefulWidget {
  const Progress({
    super.key,
    this.value,
    this.variant = ProgressVariant.primary,
    this.width = 200,
  });

  final double? value;
  final ProgressVariant variant;
  final double width;

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.value == null) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final fillColor = _resolveFillColor(colors, widget.variant);
    const trackHeight = 8.0;

    return Container(
      width: widget.width,
      height: trackHeight,
      decoration: BoxDecoration(
        color: colors.surface.alternative,
        borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      ),
      child: widget.value != null
          ? FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.value!.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                ),
              ),
            )
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Align(
                  alignment: Alignment(-1 + 2 * _controller.value, 0),
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, 0),
                    child: FractionallySizedBox(
                      widthFactor: 0.3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                        ),
                        child: const SizedBox(height: trackHeight),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

Color _resolveFillColor(SemanticColors colors, ProgressVariant variant) {
  switch (variant) {
    case ProgressVariant.primary:
      return colors.surface.inverted;
    case ProgressVariant.positive:
      return colors.positive.ui;
    case ProgressVariant.warning:
      return colors.warning.ui;
    case ProgressVariant.negative:
      return colors.negative.ui;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/progress_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildProgressShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Progress',
    variantsBuilder: () => ProgressVariant.values
        .map((variant) => Progress(value: 0.6, variant: variant))
        .toList(),
    statesBuilder: () => const [
      Progress(value: 0.0),
      Progress(value: 1.0),
      Progress(value: null),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/progress/progress.dart';
export 'src/components/progress/progress_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/progress_showcase_spec.dart';
// ...
'Progress': buildProgressShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Progress" in catalog; "Variants" section shows 4 bars at 60% fill in distinct colors; "States" section shows an empty bar, a full bar, and an indeterminate bar whose fill segment animates back and forth continuously.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/progress lib/ui.dart example/lib/catalog
git commit -m "Add Progress component"
```

---

### Task 18: Switch

**Files:**
- Create: `lib/src/components/switch/switch_state.dart`
- Create: `lib/src/components/switch/switch.dart`
- Create: `example/lib/catalog/specs/switch_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `AppSwitchState { off, on, disabled }` (named `AppSwitchState`/`AppSwitch` to avoid colliding with Dart's `switch` keyword and Flutter's own `Switch`), `AppSwitch({required bool value, required ValueChanged<bool>? onChanged, bool disabled = false})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/switch/switch_state.dart

enum AppSwitchState { off, on, disabled }
```

```dart
// lib/src/components/switch/switch.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'switch_state.dart';

/// Named `AppSwitch` (not `Switch`) to avoid colliding with
/// `package:flutter/widgets.dart`'s `Switch` and Dart's `switch` keyword.
class AppSwitch extends StatefulWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  bool get _interactive => !widget.disabled && widget.onChanged != null;

  AppSwitchState get _state {
    if (widget.disabled) return AppSwitchState.disabled;
    return widget.value ? AppSwitchState.on : AppSwitchState.off;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final trackColor = _resolveTrackColor(colors, _state);
    const trackWidth = 40.0;
    const trackHeight = 24.0;
    const thumbDiameter = 20.0;

    return GestureDetector(
      onTap: _interactive ? () => widget.onChanged!(!widget.value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: trackWidth,
        height: trackHeight,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(AppRadius.radiusFull),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: thumbDiameter,
            height: thumbDiameter,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

Color _resolveTrackColor(SemanticColors colors, AppSwitchState state) {
  switch (state) {
    case AppSwitchState.on:
      return colors.surface.inverted;
    case AppSwitchState.off:
      return colors.border.strong;
    case AppSwitchState.disabled:
      return colors.surface.alternative;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/switch_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSwitchShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Switch',
    statesBuilder: () => [
      AppSwitch(value: false, onChanged: (_) {}),
      AppSwitch(value: true, onChanged: (_) {}),
      const AppSwitch(value: false, onChanged: null, disabled: true),
      const AppSwitch(value: true, onChanged: null, disabled: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/switch/switch.dart';
export 'src/components/switch/switch_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/switch_showcase_spec.dart';
// ...
'Switch': buildSwitchShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Switch" in catalog; detail page's "States" section shows off/on/disabled-off/disabled-on switches. In the real app (not the static showcase), tapping an interactive switch animates the thumb across and updates the track color.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/switch lib/ui.dart example/lib/catalog
git commit -m "Add Switch component"
```

---

### Task 19: Checkbox

**Files:**
- Create: `lib/src/components/checkbox/checkbox_value.dart`
- Create: `lib/src/components/checkbox/checkbox.dart`
- Create: `example/lib/catalog/specs/checkbox_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `CheckboxValue { unchecked, checked, indeterminate }`, `AppCheckbox({required CheckboxValue value, required ValueChanged<CheckboxValue>? onChanged, bool disabled = false})` (named `AppCheckbox` to avoid colliding with Flutter's `Checkbox`).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/checkbox/checkbox_value.dart

enum CheckboxValue { unchecked, checked, indeterminate }
```

```dart
// lib/src/components/checkbox/checkbox.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'checkbox_value.dart';

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
  });

  final CheckboxValue value;
  final ValueChanged<CheckboxValue>? onChanged;
  final bool disabled;

  bool get _interactive => !disabled && onChanged != null;

  void _handleTap() {
    final next = value == CheckboxValue.checked
        ? CheckboxValue.unchecked
        : CheckboxValue.checked;
    onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final backgroundColor = _resolveBackgroundColor(colors, value, disabled);
    final borderColor = _resolveBorderColor(colors, value, disabled);
    const size = 20.0;

    return GestureDetector(
      onTap: _interactive ? _handleTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.radius4),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: value == CheckboxValue.checked
            ? Icon(_CheckIcon.check, size: 14, color: colors.content.onBrand)
            : value == CheckboxValue.indeterminate
                ? Icon(_CheckIcon.dash, size: 14, color: colors.content.onBrand)
                : null,
      ),
    );
  }
}

/// Minimal check/dash glyphs drawn without a Material icon font dependency.
class _CheckIcon extends StatelessWidget {
  const _CheckIcon._(this._isDash);

  final bool _isDash;

  static const check = _CheckIcon._(false);
  static const dash = _CheckIcon._(true);

  Widget call({required double size, required Color color}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CheckPainter(isDash: _isDash, color: color),
    );
  }
}

class Icon extends StatelessWidget {
  const Icon(this.glyph, {super.key, required this.size, required this.color});

  final _CheckIcon glyph;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => glyph(size: size, color: color);
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.isDash, required this.color});

  final bool isDash;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isDash) {
      canvas.drawLine(
        Offset(size.width * 0.15, size.height / 2),
        Offset(size.width * 0.85, size.height / 2),
        paint,
      );
    } else {
      final path = Path()
        ..moveTo(size.width * 0.15, size.height * 0.55)
        ..lineTo(size.width * 0.42, size.height * 0.8)
        ..lineTo(size.width * 0.85, size.height * 0.2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.isDash != isDash || oldDelegate.color != color;
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  CheckboxValue value,
  bool disabled,
) {
  if (disabled) return colors.surface.alternative;
  return value == CheckboxValue.unchecked
      ? const Color(0x00000000)
      : colors.surface.inverted;
}

Color _resolveBorderColor(
  SemanticColors colors,
  CheckboxValue value,
  bool disabled,
) {
  if (disabled) return colors.border.base;
  return value == CheckboxValue.unchecked
      ? colors.border.strong
      : colors.surface.inverted;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/checkbox_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCheckboxShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Checkbox',
    statesBuilder: () => [
      AppCheckbox(value: CheckboxValue.unchecked, onChanged: (_) {}),
      AppCheckbox(value: CheckboxValue.checked, onChanged: (_) {}),
      AppCheckbox(value: CheckboxValue.indeterminate, onChanged: (_) {}),
      const AppCheckbox(
        value: CheckboxValue.unchecked,
        onChanged: null,
        disabled: true,
      ),
      const AppCheckbox(
        value: CheckboxValue.checked,
        onChanged: null,
        disabled: true,
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/checkbox/checkbox.dart';
export 'src/components/checkbox/checkbox_value.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/checkbox_showcase_spec.dart';
// ...
'Checkbox': buildCheckboxShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Checkbox" in catalog; detail page's "States" section shows unchecked, checked (with drawn checkmark), indeterminate (with drawn dash), and two disabled variants, all with correctly rounded borders.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/checkbox lib/ui.dart example/lib/catalog
git commit -m "Add Checkbox component"
```

---

### Task 20: Radio

**Files:**
- Create: `lib/src/components/radio/radio_state.dart`
- Create: `lib/src/components/radio/radio.dart`
- Create: `example/lib/catalog/specs/radio_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `RadioValueState { unselected, selected, disabled }`, `AppRadio({required bool selected, required VoidCallback? onSelect, bool disabled = false})` (named `AppRadio` to avoid colliding with Flutter's `Radio`).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/radio/radio_state.dart

enum RadioValueState { unselected, selected, disabled }
```

```dart
// lib/src/components/radio/radio.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'radio_state.dart';

class AppRadio extends StatelessWidget {
  const AppRadio({
    super.key,
    required this.selected,
    required this.onSelect,
    this.disabled = false,
  });

  final bool selected;
  final VoidCallback? onSelect;
  final bool disabled;

  bool get _interactive => !disabled && onSelect != null;

  RadioValueState get _state {
    if (disabled) return RadioValueState.disabled;
    return selected ? RadioValueState.selected : RadioValueState.unselected;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final borderColor = _resolveBorderColor(colors, _state);
    final dotColor = _resolveDotColor(colors, _state);
    const size = 20.0;

    return GestureDetector(
      onTap: _interactive ? onSelect : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: selected
            ? Container(
                width: size * 0.5,
                height: size * 0.5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
              )
            : null,
      ),
    );
  }
}

Color _resolveBorderColor(SemanticColors colors, RadioValueState state) {
  switch (state) {
    case RadioValueState.unselected:
      return colors.border.strong;
    case RadioValueState.selected:
      return colors.surface.inverted;
    case RadioValueState.disabled:
      return colors.border.base;
  }
}

Color _resolveDotColor(SemanticColors colors, RadioValueState state) {
  return state == RadioValueState.disabled
      ? colors.content.placeholder
      : colors.surface.inverted;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/radio_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildRadioShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Radio',
    statesBuilder: () => [
      AppRadio(selected: false, onSelect: () {}),
      AppRadio(selected: true, onSelect: () {}),
      const AppRadio(selected: false, onSelect: null, disabled: true),
      const AppRadio(selected: true, onSelect: null, disabled: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/radio/radio.dart';
export 'src/components/radio/radio_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/radio_showcase_spec.dart';
// ...
'Radio': buildRadioShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Radio" in catalog; detail page's "States" section shows unselected, selected (filled dot), and two disabled variants.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/radio lib/ui.dart example/lib/catalog
git commit -m "Add Radio component"
```

---

### Task 21: Toggle

**Files:**
- Create: `lib/src/components/toggle/toggle_variant.dart`
- Create: `lib/src/components/toggle/toggle.dart`
- Create: `example/lib/catalog/specs/toggle_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `ToggleVariant { standard, outline }`, `Toggle({required String label, required bool selected, required ValueChanged<bool>? onChanged, ToggleVariant variant = ToggleVariant.standard, bool disabled = false})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/toggle/toggle_variant.dart

enum ToggleVariant { standard, outline }
```

```dart
// lib/src/components/toggle/toggle.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'toggle_variant.dart';

/// Single-button pressed/unpressed toggle (e.g. "Bold" in a toolbar).
class Toggle extends StatefulWidget {
  const Toggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.variant = ToggleVariant.standard,
    this.disabled = false,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onChanged;
  final ToggleVariant variant;
  final bool disabled;

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  bool _isPressed = false;

  bool get _interactive => !widget.disabled && widget.onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final backgroundColor = _resolveBackgroundColor(
      colors,
      widget.selected,
      _isPressed,
      widget.disabled,
    );
    final textColor = _resolveTextColor(colors, widget.selected, widget.disabled);
    final borderColor = widget.variant == ToggleVariant.outline
        ? (widget.disabled ? colors.border.base : colors.border.strong)
        : null;

    return GestureDetector(
      onTapDown: _interactive ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _interactive ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _interactive ? () => setState(() => _isPressed = false) : null,
      onTap: _interactive ? () => widget.onChanged!(!widget.selected) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
          vertical: AppSpacing.spacing8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(AppRadius.radius8),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Text(widget.label, style: typography.labelMd.copyWith(color: textColor)),
      ),
    );
  }
}

Color _resolveBackgroundColor(
  SemanticColors colors,
  bool selected,
  bool pressed,
  bool disabled,
) {
  if (disabled) return colors.surface.alternative;
  if (selected) return colors.surface.inverted;
  return pressed ? colors.surface.alternative : const Color(0x00000000);
}

Color _resolveTextColor(SemanticColors colors, bool selected, bool disabled) {
  if (disabled) return colors.content.placeholder;
  return selected ? colors.content.onBrand : colors.content.primary;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/toggle_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToggleShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle',
    variantsBuilder: () => [
      Toggle(
        label: 'standard',
        selected: true,
        onChanged: (_) {},
        variant: ToggleVariant.standard,
      ),
      Toggle(
        label: 'outline',
        selected: true,
        onChanged: (_) {},
        variant: ToggleVariant.outline,
      ),
    ],
    statesBuilder: () => [
      Toggle(label: 'unselected', selected: false, onChanged: (_) {}),
      Toggle(label: 'selected', selected: true, onChanged: (_) {}),
      const Toggle(
        label: 'disabled',
        selected: false,
        onChanged: null,
        disabled: true,
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/toggle/toggle.dart';
export 'src/components/toggle/toggle_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/toggle_showcase_spec.dart';
// ...
'Toggle': buildToggleShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Toggle" in catalog; "Variants" section shows a selected standard toggle and a selected outline toggle; "States" section shows unselected/selected/disabled.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/toggle lib/ui.dart example/lib/catalog
git commit -m "Add Toggle component"
```

---

### Task 22: Toggle Group

**Files:**
- Create: `lib/src/components/toggle_group/toggle_group_mode.dart`
- Create: `lib/src/components/toggle_group/toggle_group.dart`
- Create: `example/lib/catalog/specs/toggle_group_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Toggle` (Task 21).
- Produces: `ToggleGroupMode { single, multiple }`, `ToggleGroup({required List<String> labels, required Set<int> selectedIndices, required ValueChanged<Set<int>> onChanged, ToggleGroupMode mode = ToggleGroupMode.single})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/toggle_group/toggle_group_mode.dart

enum ToggleGroupMode { single, multiple }
```

```dart
// lib/src/components/toggle_group/toggle_group.dart

import 'package:flutter/widgets.dart';

import '../../tokens/primitives/app_spacing.dart';
import '../toggle/toggle.dart';
import 'toggle_group_mode.dart';

/// Row of connected Toggles that share single- or multiple-selection logic.
class ToggleGroup extends StatelessWidget {
  const ToggleGroup({
    super.key,
    required this.labels,
    required this.selectedIndices,
    required this.onChanged,
    this.mode = ToggleGroupMode.single,
  });

  final List<String> labels;
  final Set<int> selectedIndices;
  final ValueChanged<Set<int>> onChanged;
  final ToggleGroupMode mode;

  void _handleToggle(int index, bool nowSelected) {
    if (mode == ToggleGroupMode.single) {
      onChanged(nowSelected ? {index} : <int>{});
      return;
    }
    final next = Set<int>.from(selectedIndices);
    nowSelected ? next.add(index) : next.remove(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.spacing8,
      children: [
        for (var i = 0; i < labels.length; i++)
          Toggle(
            label: labels[i],
            selected: selectedIndices.contains(i),
            onChanged: (nowSelected) => _handleToggle(i, nowSelected),
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/toggle_group_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToggleGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toggle Group',
    variantsBuilder: () => [
      ToggleGroup(
        labels: const ['Left', 'Center', 'Right'],
        selectedIndices: const {0},
        onChanged: (_) {},
        mode: ToggleGroupMode.single,
      ),
      ToggleGroup(
        labels: const ['Bold', 'Italic', 'Underline'],
        selectedIndices: const {0, 2},
        onChanged: (_) {},
        mode: ToggleGroupMode.multiple,
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/toggle_group/toggle_group.dart';
export 'src/components/toggle_group/toggle_group_mode.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/toggle_group_showcase_spec.dart';
// ...
'Toggle Group': buildToggleGroupShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Toggle Group" in catalog; "Variants" section shows a single-select group with "Left" selected and a multi-select group with "Bold" and "Underline" selected.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/toggle_group lib/ui.dart example/lib/catalog
git commit -m "Add Toggle Group component"
```

---

### Task 23: Input

**Files:**
- Create: `lib/src/components/input/input_size.dart`
- Create: `lib/src/components/input/input_state.dart`
- Create: `lib/src/components/input/input.dart`
- Create: `example/lib/catalog/specs/input_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `InputSize { sm, md, lg }`, `InputState { enabled, focused, disabled, error }`, `Input({TextEditingController? controller, String? placeholder, InputSize size = InputSize.md, bool disabled = false, bool error = false, InputState? showcaseState})`.

- [ ] **Step 1: Create the enums and widget**

```dart
// lib/src/components/input/input_size.dart

enum InputSize { sm, md, lg }
```

```dart
// lib/src/components/input/input_state.dart

enum InputState { enabled, focused, disabled, error }
```

```dart
// lib/src/components/input/input.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'input_size.dart';
import 'input_state.dart';

class Input extends StatefulWidget {
  const Input({
    super.key,
    this.controller,
    this.placeholder,
    this.size = InputSize.md,
    this.disabled = false,
    this.error = false,
    this.showcaseState,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final InputSize size;
  final bool disabled;
  final bool error;

  /// Showcase-only override for the "focused" state, which is inherently
  /// transient and cannot be held via real focus signals in a static
  /// screenshot. Null in normal app usage.
  final InputState? showcaseState;

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  InputState get _liveState {
    if (widget.showcaseState != null) return widget.showcaseState!;
    if (widget.disabled) return InputState.disabled;
    if (widget.error) return InputState.error;
    if (_isFocused) return InputState.focused;
    return InputState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final state = _liveState;
    final borderColor = _resolveBorderColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);
    final textStyle = _resolveTextStyle(typography, widget.size);
    final padding = _resolvePadding(widget.size);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(
          color: borderColor,
          width: state == InputState.focused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        style: textStyle.copyWith(color: colors.content.primary),
        decoration: InputDecoration.collapsed(
          hintText: widget.placeholder,
          hintStyle: textStyle.copyWith(color: colors.content.placeholder),
        ),
      ),
    );
  }
}

Color _resolveBorderColor(SemanticColors colors, InputState state) {
  switch (state) {
    case InputState.enabled:
      return colors.border.base;
    case InputState.focused:
      return colors.surface.inverted;
    case InputState.disabled:
      return colors.border.base;
    case InputState.error:
      return colors.negative.border;
  }
}

Color _resolveBackgroundColor(SemanticColors colors, InputState state) {
  return state == InputState.disabled ? colors.surface.alternative : colors.surface.base;
}

TextStyle _resolveTextStyle(SemanticTypography typography, InputSize size) {
  switch (size) {
    case InputSize.sm:
      return typography.bodySm;
    case InputSize.md:
      return typography.bodyMd;
    case InputSize.lg:
      return typography.bodyLg;
  }
}

EdgeInsets _resolvePadding(InputSize size) {
  switch (size) {
    case InputSize.sm:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing6,
      );
    case InputSize.md:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing8,
      );
    case InputSize.lg:
      return const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      );
  }
}
```

Note: `TextField`/`TextEditingController`/`InputDecoration` above come from `package:flutter/material.dart`, not `widgets.dart` — the file's import must be `import 'package:flutter/material.dart';` instead of `widgets.dart`. This is the one accepted exception to "no Material widget wrapping": `TextField` provides text-editing/IME/selection/clipboard behavior with no low-level primitive equivalent in `widgets.dart`; every visual property (border, background, padding, type style) is still fully controlled by the token-driven `Container` wrapper and `InputDecoration.collapsed`, which strips all of `TextField`'s own chrome.

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/input_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInputShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input',
    sizesBuilder: () => InputSize.values
        .map((size) => Input(placeholder: size.name, size: size))
        .toList(),
    statesBuilder: () => const [
      Input(placeholder: 'Enabled'),
      Input(placeholder: 'Focused', showcaseState: InputState.focused),
      Input(placeholder: 'Disabled', disabled: true),
      Input(placeholder: 'Error', error: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/input/input.dart';
export 'src/components/input/input_size.dart';
export 'src/components/input/input_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/input_showcase_spec.dart';
// ...
'Input': buildInputShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Input" in catalog; "Sizes" section shows three ascending text fields; "States" section shows enabled/focused (thicker inverted border)/disabled (muted background)/error (red border). Tap into the "Enabled" input in a live run and confirm typing works and the border thickens/darkens on real focus.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/input lib/ui.dart example/lib/catalog
git commit -m "Add Input component"
```

---

### Task 24: Textarea

**Files:**
- Create: `lib/src/components/textarea/textarea.dart`
- Create: `example/lib/catalog/specs/textarea_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `InputState` (Task 23, reused — textarea shares the same enabled/focused/disabled/error vocabulary).
- Produces: `Textarea({TextEditingController? controller, String? placeholder, int minLines = 3, bool disabled = false, bool error = false, InputState? showcaseState})`.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/textarea/textarea.dart

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../input/input_state.dart';

class Textarea extends StatefulWidget {
  const Textarea({
    super.key,
    this.controller,
    this.placeholder,
    this.minLines = 3,
    this.disabled = false,
    this.error = false,
    this.showcaseState,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final int minLines;
  final bool disabled;
  final bool error;
  final InputState? showcaseState;

  @override
  State<Textarea> createState() => _TextareaState();
}

class _TextareaState extends State<Textarea> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  InputState get _liveState {
    if (widget.showcaseState != null) return widget.showcaseState!;
    if (widget.disabled) return InputState.disabled;
    if (widget.error) return InputState.error;
    if (_isFocused) return InputState.focused;
    return InputState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final state = _liveState;
    final borderColor = _resolveBorderColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(
          color: borderColor,
          width: state == InputState.focused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        enabled: !widget.disabled,
        minLines: widget.minLines,
        maxLines: null,
        style: typography.bodyMd.copyWith(color: colors.content.primary),
        decoration: InputDecoration.collapsed(
          hintText: widget.placeholder,
          hintStyle: typography.bodyMd.copyWith(color: colors.content.placeholder),
        ),
      ),
    );
  }
}

Color _resolveBorderColor(SemanticColors colors, InputState state) {
  switch (state) {
    case InputState.enabled:
      return colors.border.base;
    case InputState.focused:
      return colors.surface.inverted;
    case InputState.disabled:
      return colors.border.base;
    case InputState.error:
      return colors.negative.border;
  }
}

Color _resolveBackgroundColor(SemanticColors colors, InputState state) {
  return state == InputState.disabled ? colors.surface.alternative : colors.surface.base;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/textarea_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildTextareaShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Textarea',
    statesBuilder: () => const [
      Textarea(placeholder: 'Enabled'),
      Textarea(placeholder: 'Focused', showcaseState: InputState.focused),
      Textarea(placeholder: 'Disabled', disabled: true),
      Textarea(placeholder: 'Error', error: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/textarea/textarea.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/textarea_showcase_spec.dart';
// ...
'Textarea': buildTextareaShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Textarea" in catalog; "States" section shows four 3-line-tall text areas in enabled/focused/disabled/error styling matching Input's palette.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/textarea lib/ui.dart example/lib/catalog
git commit -m "Add Textarea component"
```

---

### Task 25: Input Group

**Files:**
- Create: `lib/src/components/input_group/input_group.dart`
- Create: `example/lib/catalog/specs/input_group_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Input` (Task 23).
- Produces: `InputGroup({Widget? leading, Widget? trailing, required Input input})` — composes a leading/trailing slot (icon, text addon) with an `Input` inside one bordered container.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/input_group/input_group.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../input/input.dart';

/// Wraps an [Input] with an optional leading/trailing slot (icon or text
/// addon) inside one shared bordered container, so the border reads as a
/// single control rather than three stacked ones.
class InputGroup extends StatelessWidget {
  const InputGroup({
    super.key,
    this.leading,
    this.trailing,
    required this.input,
  });

  final Widget? leading;
  final Widget? trailing;
  final Input input;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: colors.border.base),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.spacing8),
          ],
          Expanded(child: input),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.spacing8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
```

Note: `InputGroup` relies on the inner `Input` to render with no border/background of its own when embedded — for this showcase-scale iteration, the plain `Input` inside `InputGroup` will show a redundant inner border. **Decision:** accept this for now (YAGNI — do not add an `InputGroup`-only borderless `Input` variant this iteration); flag it as a known visual nit during the Task 25 emulator verification step and revisit only if the user asks.

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/input_group_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInputGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input Group',
    variantsBuilder: () => [
      InputGroup(
        leading: const Text('\$'),
        input: const Input(placeholder: 'Amount'),
      ),
      InputGroup(
        input: const Input(placeholder: 'Search'),
        trailing: const Text('Go'),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/input_group/input_group.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/input_group_showcase_spec.dart';
// ...
'Input Group': buildInputGroupShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Input Group" in catalog; "Variants" section shows a leading-`$`-addon field and a trailing-`Go`-addon field, each in one bordered container.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/input_group lib/ui.dart example/lib/catalog
git commit -m "Add Input Group component"
```

---

### Task 26: Input OTP

**Files:**
- Create: `lib/src/components/input_otp/input_otp.dart`
- Create: `example/lib/catalog/specs/input_otp_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `InputOtp({required int length, required String value, required ValueChanged<String>? onChanged, bool disabled = false, bool error = false})` — fixed-length one-time-code boxes.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/input_otp/input_otp.dart

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';

/// Fixed-length one-time-code input: `length` single-character boxes
/// backed by one hidden `TextField` that drives them all, so focus/caret/
/// paste/backspace behavior comes from the platform IME rather than being
/// reimplemented per box.
class InputOtp extends StatefulWidget {
  const InputOtp({
    super.key,
    required this.length,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.error = false,
  });

  final int length;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool disabled;
  final bool error;

  @override
  State<InputOtp> createState() => _InputOtpState();
}

class _InputOtpState extends State<InputOtp> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return GestureDetector(
      onTap: widget.disabled ? null : () => _focusNode.requestFocus(),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.spacing8),
                _OtpBox(
                  char: i < widget.value.length ? widget.value[i] : '',
                  isActiveCaret: _isFocused && i == widget.value.length,
                  borderColor: _resolveBorderColor(
                    colors,
                    disabled: widget.disabled,
                    error: widget.error,
                    isActiveCaret: _isFocused && i == widget.value.length,
                  ),
                  textStyle: typography.h4.copyWith(color: colors.content.primary),
                ),
              ],
            ],
          ),
          // Offstage field: captures real keyboard/paste input, invisible
          // itself, positioned to overlay the boxes for tap-to-focus.
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: widget.length * 48.0,
              height: 48,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.disabled,
                maxLength: widget.length,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration.collapsed(hintText: null),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.char,
    required this.isActiveCaret,
    required this.borderColor,
    required this.textStyle,
  });

  final String char;
  final bool isActiveCaret;
  final Color borderColor;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: borderColor, width: isActiveCaret ? 2 : 1),
      ),
      child: Text(char, style: textStyle),
    );
  }
}

Color _resolveBorderColor(
  SemanticColors colors, {
  required bool disabled,
  required bool error,
  required bool isActiveCaret,
}) {
  if (disabled) return colors.border.base;
  if (error) return colors.negative.border;
  return isActiveCaret ? colors.surface.inverted : colors.border.base;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/input_otp_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInputOtpShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input OTP',
    statesBuilder: () => [
      InputOtp(length: 6, value: '', onChanged: (_) {}),
      InputOtp(length: 6, value: '123', onChanged: (_) {}),
      const InputOtp(length: 6, value: '123456', onChanged: null, disabled: true),
      InputOtp(length: 6, value: '12', onChanged: (_) {}, error: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/input_otp/input_otp.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/input_otp_showcase_spec.dart';
// ...
'Input OTP': buildInputOtpShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Input OTP" in catalog; "States" section shows 4 six-box rows: empty, partially filled, full+disabled, partially filled+error border. In a live run, tapping the empty row and typing digits fills boxes left to right.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/input_otp lib/ui.dart example/lib/catalog
git commit -m "Add Input OTP component"
```

---

### Task 27: Form Field

**Files:**
- Create: `lib/src/components/form_field/form_field.dart`
- Create: `example/lib/catalog/specs/form_field_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Label` (Task 13).
- Produces: `AppFormField({required String label, bool required = false, String? helperText, String? errorText, bool disabled = false, required Widget child})` (named `AppFormField` to avoid colliding with Flutter's `FormField`) — wraps `Label` + any input-like `child` + helper/error text.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/form_field/form_field.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../label/label.dart';

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.label,
    this.required = false,
    this.helperText,
    this.errorText,
    this.disabled = false,
    required this.child,
  });

  final String label;
  final bool required;
  final String? helperText;
  final String? errorText;
  final bool disabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final hasError = errorText != null;
    final helpColor = _resolveHelpColor(colors, hasError);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(text: label, required: required, disabled: disabled),
        const SizedBox(height: AppSpacing.spacing6),
        child,
        if (helperText != null || errorText != null) ...[
          const SizedBox(height: AppSpacing.spacing6),
          Text(
            errorText ?? helperText!,
            style: typography.captionSm.copyWith(color: helpColor),
          ),
        ],
      ],
    );
  }
}

Color _resolveHelpColor(SemanticColors colors, bool hasError) {
  return hasError ? colors.negative.text : colors.content.muted;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/form_field_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildFormFieldShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Form Field',
    statesBuilder: () => const [
      AppFormField(
        label: 'Email',
        required: true,
        helperText: "We'll never share your email.",
        child: Input(placeholder: 'you@example.com'),
      ),
      AppFormField(
        label: 'Email',
        required: true,
        errorText: 'Enter a valid email address.',
        child: Input(placeholder: 'you@example.com', error: true),
      ),
      AppFormField(
        label: 'Email',
        disabled: true,
        child: Input(placeholder: 'you@example.com', disabled: true),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/form_field/form_field.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/form_field_showcase_spec.dart';
// ...
'Form Field': buildFormFieldShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Form Field" in catalog; "States" section shows a required field with helper text, a required field with error text and a red-bordered input, and a disabled field with a muted label and disabled input.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/form_field lib/ui.dart example/lib/catalog
git commit -m "Add Form Field component"
```

---

### Task 28: Select

**Files:**
- Create: `lib/src/components/select/select_state.dart`
- Create: `lib/src/components/select/select.dart`
- Create: `example/lib/catalog/specs/select_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `SelectVisualState { closed, open, disabled }`, `AppSelect({required List<String> options, String? selected, required ValueChanged<String>? onChanged, bool disabled = false, bool error = false})` (named `AppSelect` for clarity/consistency with `AppSwitch`/`AppRadio`).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/select/select_state.dart

enum SelectVisualState { closed, open, disabled }
```

```dart
// lib/src/components/select/select.dart

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'select_state.dart';

/// Dropdown built on `showMenu` (the lowest-level Flutter primitive that
/// provides a positioned overlay menu with proper routing/dismiss behavior;
/// there is no non-Material equivalent). The trigger itself is fully
/// custom-painted — no Material button/field chrome.
class AppSelect extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.options,
    this.selected,
    required this.onChanged,
    this.disabled = false,
    this.error = false,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String>? onChanged;
  final bool disabled;
  final bool error;

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  bool _isOpen = false;

  bool get _interactive => !widget.disabled && widget.onChanged != null;

  SelectVisualState get _state {
    if (widget.disabled) return SelectVisualState.disabled;
    return _isOpen ? SelectVisualState.open : SelectVisualState.closed;
  }

  Future<void> _openMenu(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromLTRB(
      box.localToGlobal(Offset.zero).dx,
      box.localToGlobal(Offset(0, box.size.height)).dy,
      0,
      0,
    );
    setState(() => _isOpen = true);
    final result = await showMenu<String>(
      context: context,
      position: position,
      items: widget.options
          .map((option) => PopupMenuItem<String>(value: option, child: Text(option)))
          .toList(),
    );
    setState(() => _isOpen = false);
    if (result != null) widget.onChanged!(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final state = _state;
    final borderColor = _resolveBorderColor(colors, state, widget.error);
    final textColor = _resolveTextColor(colors, state);

    return GestureDetector(
      onTap: _interactive ? () => _openMenu(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing12,
          vertical: AppSpacing.spacing8,
        ),
        decoration: BoxDecoration(
          color: state == SelectVisualState.disabled
              ? colors.surface.alternative
              : colors.surface.base,
          borderRadius: BorderRadius.circular(AppRadius.radius8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selected ?? 'Select…',
              style: typography.bodyMd.copyWith(color: textColor),
            ),
            const SizedBox(width: AppSpacing.spacing8),
            Text('▾', style: typography.bodyMd.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}

Color _resolveBorderColor(SemanticColors colors, SelectVisualState state, bool error) {
  if (error) return colors.negative.border;
  switch (state) {
    case SelectVisualState.closed:
      return colors.border.base;
    case SelectVisualState.open:
      return colors.surface.inverted;
    case SelectVisualState.disabled:
      return colors.border.base;
  }
}

Color _resolveTextColor(SemanticColors colors, SelectVisualState state) {
  return state == SelectVisualState.disabled
      ? colors.content.placeholder
      : colors.content.primary;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/select_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSelectShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Select',
    statesBuilder: () => [
      AppSelect(options: const ['One', 'Two'], onChanged: (_) {}),
      AppSelect(options: const ['One', 'Two'], selected: 'One', onChanged: (_) {}),
      const AppSelect(options: ['One', 'Two'], onChanged: null, disabled: true),
      AppSelect(options: const ['One', 'Two'], onChanged: (_) {}, error: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/select/select.dart';
export 'src/components/select/select_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/select_showcase_spec.dart';
// ...
'Select': buildSelectShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Select" in catalog; "States" section shows placeholder, selected value, disabled, and error-bordered triggers. In a live run, tapping an interactive trigger opens a dropdown menu positioned below it; picking an option updates the trigger text.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/select lib/ui.dart example/lib/catalog
git commit -m "Add Select component"
```

---

### Task 29: Slider

**Files:**
- Create: `lib/src/components/slider/slider.dart`
- Create: `example/lib/catalog/specs/slider_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `AppSlider({required double value, double min = 0, double max = 1, required ValueChanged<double>? onChanged, bool disabled = false})` (named `AppSlider` to avoid colliding with Flutter's `Slider`).

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/slider/slider.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/semantic/semantic_colors.dart';

class AppSlider extends StatefulWidget {
  const AppSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    required this.onChanged,
    this.disabled = false,
    this.width = 200,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;
  final bool disabled;
  final double width;

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  bool _isDragging = false;

  bool get _interactive => !widget.disabled && widget.onChanged != null;

  void _updateFromLocalX(double localX) {
    final fraction = (localX / widget.width).clamp(0.0, 1.0);
    final next = widget.min + fraction * (widget.max - widget.min);
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final trackColor = _resolveTrackColor(colors, widget.disabled);
    final fillColor = _resolveFillColor(colors, widget.disabled);
    final fraction =
        ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    const trackHeight = 4.0;
    const thumbDiameter = 18.0;

    return GestureDetector(
      onHorizontalDragStart: _interactive ? (_) => setState(() => _isDragging = true) : null,
      onHorizontalDragUpdate: _interactive
          ? (details) => _updateFromLocalX(details.localPosition.dx)
          : null,
      onHorizontalDragEnd: _interactive ? (_) => setState(() => _isDragging = false) : null,
      onTapDown: _interactive ? (details) => _updateFromLocalX(details.localPosition.dx) : null,
      child: SizedBox(
        width: widget.width,
        height: thumbDiameter,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: widget.width,
              height: trackHeight,
              color: trackColor,
            ),
            Container(
              width: widget.width * fraction,
              height: trackHeight,
              color: fillColor,
            ),
            Positioned(
              left: (widget.width * fraction) - (thumbDiameter / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: thumbDiameter,
                height: thumbDiameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fillColor,
                  border: Border.all(
                    color: colors.surface.base,
                    width: _isDragging ? 3 : 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _resolveTrackColor(SemanticColors colors, bool disabled) {
  return colors.surface.alternative;
}

Color _resolveFillColor(SemanticColors colors, bool disabled) {
  return disabled ? colors.content.placeholder : colors.surface.inverted;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/slider_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildSliderShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Slider',
    statesBuilder: () => [
      AppSlider(value: 0.2, onChanged: (_) {}),
      AppSlider(value: 0.7, onChanged: (_) {}),
      const AppSlider(value: 0.5, onChanged: null, disabled: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/slider/slider.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/slider_showcase_spec.dart';
// ...
'Slider': buildSliderShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Slider" in catalog; "States" section shows sliders at 20%, 70%, and a muted disabled slider at 50%. In a live run, dragging the thumb on an interactive slider updates its position and the thumb border thickens while dragging.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/slider lib/ui.dart example/lib/catalog
git commit -m "Add Slider component"
```

---

### Task 30: Button Group

**Files:**
- Create: `lib/src/components/button_group/button_group.dart`
- Create: `example/lib/catalog/specs/button_group_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Button` (Task 7).
- Produces: `ButtonGroup({required List<Button> buttons})` — lays out buttons in a row with shared, connected corner radii (square inner corners, rounded outer corners) and a single 1px divider between adjacent buttons.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/button_group/button_group.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../button/button.dart';

/// Lays out [Button]s edge-to-edge with only the group's outer corners
/// rounded, and a 1px divider between adjacent buttons, so the group reads
/// as one connected control.
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({super.key, required this.buttons});

  final List<Button> buttons;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0)
              Container(width: 1, color: colors.border.base),
            buttons[i],
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/button_group_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildButtonGroupShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Button Group',
    variantsBuilder: () => [
      ButtonGroup(
        buttons: [
          Button(label: 'Day', variant: ButtonVariant.secondary, onPressed: () {}),
          Button(label: 'Week', variant: ButtonVariant.secondary, onPressed: () {}),
          Button(label: 'Month', variant: ButtonVariant.secondary, onPressed: () {}),
        ],
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/button_group/button_group.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/button_group_showcase_spec.dart';
// ...
'Button Group': buildButtonGroupShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Button Group" in catalog; "Variants" section shows one connected 3-segment group ("Day"/"Week"/"Month") with rounded outer corners, square joins, and thin dividers between segments.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/button_group lib/ui.dart example/lib/catalog
git commit -m "Add Button Group component"
```

---

### Task 31: Tabs

**Files:**
- Create: `lib/src/components/tabs/tabs_variant.dart`
- Create: `lib/src/components/tabs/tabs.dart`
- Create: `example/lib/catalog/specs/tabs_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `TabsVariant { underline, pills }`, `AppTabs({required List<String> labels, required int selectedIndex, required ValueChanged<int> onChanged, TabsVariant variant = TabsVariant.underline})` (named `AppTabs` to avoid colliding with anything user-imported later).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/tabs/tabs_variant.dart

enum TabsVariant { underline, pills }
```

```dart
// lib/src/components/tabs/tabs.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'tabs_variant.dart';

class AppTabs extends StatelessWidget {
  const AppTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = TabsVariant.underline,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final TabsVariant variant;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: EdgeInsets.only(right: i < labels.length - 1 ? AppSpacing.spacing8 : 0),
            child: _TabItem(
              label: labels[i],
              isSelected: i == selectedIndex,
              variant: variant,
              onTap: () => onChanged(i),
            ),
          ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final TabsVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final textColor = _resolveTextColor(colors, isSelected);

    return GestureDetector(
      onTap: onTap,
      child: variant == TabsVariant.pills
          ? Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing12,
                vertical: AppSpacing.spacing6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.surface.inverted : const Color(0x00000000),
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
              child: Text(label, style: typography.labelMd.copyWith(color: textColor)),
            )
          : Container(
              padding: const EdgeInsets.only(bottom: AppSpacing.spacing8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? colors.surface.inverted : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
              child: Text(label, style: typography.labelMd.copyWith(color: textColor)),
            ),
    );
  }
}

Color _resolveTextColor(SemanticColors colors, bool isSelected) {
  return isSelected ? colors.content.primary : colors.content.muted;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/tabs_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildTabsShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Tabs',
    variantsBuilder: () => [
      AppTabs(
        labels: const ['Overview', 'Activity', 'Settings'],
        selectedIndex: 0,
        onChanged: (_) {},
        variant: TabsVariant.underline,
      ),
      AppTabs(
        labels: const ['Overview', 'Activity', 'Settings'],
        selectedIndex: 1,
        onChanged: (_) {},
        variant: TabsVariant.pills,
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/tabs/tabs.dart';
export 'src/components/tabs/tabs_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/tabs_showcase_spec.dart';
// ...
'Tabs': buildTabsShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Tabs" in catalog; "Variants" section shows an underline-style row with "Overview" selected and a pills-style row with "Activity" selected.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/tabs lib/ui.dart example/lib/catalog
git commit -m "Add Tabs component"
```

---

### Task 32: Card

**Files:**
- Create: `lib/src/components/card/card_variant.dart`
- Create: `lib/src/components/card/card.dart`
- Create: `example/lib/catalog/specs/card_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `CardVariant { flat, outlined, elevated }`, `AppCard({Widget? header, required Widget body, Widget? footer, CardVariant variant = CardVariant.outlined})` (named `AppCard` to avoid colliding with Flutter's `Card`).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/card/card_variant.dart

enum CardVariant { flat, outlined, elevated }
```

```dart
// lib/src/components/card/card.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'card_variant.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.variant = CardVariant.outlined,
  });

  final Widget? header;
  final Widget body;
  final Widget? footer;
  final CardVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final borderColor = _resolveBorderColor(colors, variant);
    final shadow = _resolveShadow(variant);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: BorderRadius.circular(AppRadius.radius12),
        border: borderColor != null ? Border.all(color: borderColor) : null,
        boxShadow: shadow,
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: AppSpacing.spacing12),
          ],
          body,
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.spacing12),
            footer!,
          ],
        ],
      ),
    );
  }
}

Color? _resolveBorderColor(SemanticColors colors, CardVariant variant) {
  return variant == CardVariant.outlined ? colors.border.base : null;
}

List<BoxShadow> _resolveShadow(CardVariant variant) {
  return variant == CardVariant.elevated ? AppElevation.level2 : AppElevation.level0;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/card_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCardShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Card',
    variantsBuilder: () => CardVariant.values
        .map((variant) => AppCard(
              variant: variant,
              header: Text(variant.name),
              body: const Text('Card body content goes here.'),
            ))
        .toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/card/card.dart';
export 'src/components/card/card_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/card_showcase_spec.dart';
// ...
'Card': buildCardShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Card" in catalog; "Variants" section shows a borderless flat card, a bordered outlined card, and a shadowed elevated card, each with a header and body.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/card lib/ui.dart example/lib/catalog
git commit -m "Add Card component"
```

---

### Task 33: List Item

**Files:**
- Create: `lib/src/components/list_item/list_item_state.dart`
- Create: `lib/src/components/list_item/list_item.dart`
- Create: `example/lib/catalog/specs/list_item_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `ListItemState { enabled, selected, disabled }`, `AppListItem({Widget? leading, required String title, String? subtitle, Widget? trailing, bool selected = false, bool disabled = false, VoidCallback? onTap})` — built before `List` (Task 34) since `List` composes `AppListItem`s.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/list_item/list_item_state.dart

enum ListItemState { enabled, selected, disabled }
```

```dart
// lib/src/components/list_item/list_item.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'list_item_state.dart';

class AppListItem extends StatefulWidget {
  const AppListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.disabled = false,
    this.onTap,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  bool _isHovered = false;

  bool get _interactive => !widget.disabled && widget.onTap != null;

  ListItemState get _state {
    if (widget.disabled) return ListItemState.disabled;
    return widget.selected ? ListItemState.selected : ListItemState.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final backgroundColor = _resolveBackgroundColor(colors, _state, _isHovered);
    final titleColor = _resolveTitleColor(colors, _state);

    return MouseRegion(
      onEnter: _interactive ? (_) => setState(() => _isHovered = true) : null,
      onExit: _interactive ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: _interactive ? widget.onTap : null,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing16,
            vertical: AppSpacing.spacing12,
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: AppSpacing.spacing12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title, style: typography.bodyMd.copyWith(color: titleColor)),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: typography.captionMd.copyWith(color: colors.content.muted),
                      ),
                  ],
                ),
              ),
              if (widget.trailing != null) widget.trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

Color _resolveBackgroundColor(SemanticColors colors, ListItemState state, bool hovered) {
  if (state == ListItemState.selected) return colors.surface.alternative;
  if (hovered) return colors.surface.alternative;
  return const Color(0x00000000);
}

Color _resolveTitleColor(SemanticColors colors, ListItemState state) {
  return state == ListItemState.disabled ? colors.content.placeholder : colors.content.primary;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/list_item_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildListItemShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'List Item',
    statesBuilder: () => [
      AppListItem(title: 'Enabled', subtitle: 'Subtitle text', onTap: () {}),
      AppListItem(title: 'Selected', subtitle: 'Subtitle text', selected: true, onTap: () {}),
      const AppListItem(title: 'Disabled', subtitle: 'Subtitle text', disabled: true),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/list_item/list_item.dart';
export 'src/components/list_item/list_item_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/list_item_showcase_spec.dart';
// ...
'List Item': buildListItemShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "List Item" in catalog; "States" section shows an enabled row, a selected row (tinted background), and a disabled row (muted title, no tap response).

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/list_item lib/ui.dart example/lib/catalog
git commit -m "Add List Item component"
```

---

### Task 34: List

**Files:**
- Create: `lib/src/components/list/list.dart`
- Create: `example/lib/catalog/specs/list_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `AppListItem` (Task 33).
- Produces: `AppList({required List<AppListItem> items, bool showDividers = true})` (named `AppList` to avoid colliding with Dart's `List<T>`).

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/list/list.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../list_item/list_item.dart';

class AppList extends StatelessWidget {
  const AppList({super.key, required this.items, this.showDividers = true});

  final List<AppListItem> items;
  final bool showDividers;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          items[i],
          if (showDividers && i < items.length - 1)
            Container(height: 1, color: colors.border.base),
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/list_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildListShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'List',
    variantsBuilder: () => [
      SizedBox(
        width: 280,
        child: AppList(
          items: [
            AppListItem(title: 'Alpha', onTap: () {}),
            AppListItem(title: 'Beta', onTap: () {}),
            AppListItem(title: 'Gamma', onTap: () {}),
          ],
        ),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/list/list.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/list_showcase_spec.dart';
// ...
'List': buildListShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "List" in catalog; "Variants" section shows a 3-row list ("Alpha"/"Beta"/"Gamma") separated by 1px dividers, no divider after the last row.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/list lib/ui.dart example/lib/catalog
git commit -m "Add List component"
```

---

### Task 35: Empty

**Files:**
- Create: `lib/src/components/empty/empty.dart`
- Create: `example/lib/catalog/specs/empty_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Button` (Task 7).
- Produces: `Empty({Widget? icon, required String title, String? description, Button? action})`.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/empty/empty.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../button/button.dart';

class Empty extends StatelessWidget {
  const Empty({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
  });

  final Widget? icon;
  final String title;
  final String? description;
  final Button? action;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(height: AppSpacing.spacing16),
        ],
        Text(
          title,
          style: typography.h4.copyWith(color: colors.content.primary),
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            description!,
            style: typography.bodySm.copyWith(color: colors.content.muted),
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: AppSpacing.spacing16),
          action!,
        ],
      ],
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/empty_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildEmptyShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Empty',
    statesBuilder: () => [
      const SizedBox(
        width: 280,
        child: Empty(title: 'No results', description: 'Try a different search term.'),
      ),
      SizedBox(
        width: 280,
        child: Empty(
          title: 'No projects yet',
          description: 'Create your first project to get started.',
          action: Button(label: 'Create project', onPressed: () {}),
        ),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/empty/empty.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/empty_showcase_spec.dart';
// ...
'Empty': buildEmptyShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Empty" in catalog; "States" section shows a centered title+description block, and a second block with a title, description, and primary Button action.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/empty lib/ui.dart example/lib/catalog
git commit -m "Add Empty component"
```

---

### Task 36: Attachment

**Files:**
- Create: `lib/src/components/attachment/attachment_state.dart`
- Create: `lib/src/components/attachment/attachment.dart`
- Create: `example/lib/catalog/specs/attachment_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `AttachmentState { idle, uploading, error }`, `Attachment({required String fileName, String? fileSize, AttachmentState state = AttachmentState.idle, VoidCallback? onRemove})`.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/attachment/attachment_state.dart

enum AttachmentState { idle, uploading, error }
```

```dart
// lib/src/components/attachment/attachment.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../spinner/spinner.dart';
import 'attachment_state.dart';

/// File chip showing name/size and an upload/error/idle status, with an
/// optional remove action.
class Attachment extends StatelessWidget {
  const Attachment({
    super.key,
    required this.fileName,
    this.fileSize,
    this.state = AttachmentState.idle,
    this.onRemove,
  });

  final String fileName;
  final String? fileSize;
  final AttachmentState state;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final borderColor = _resolveBorderColor(colors, state);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (state == AttachmentState.uploading)
            const Spinner(size: SpinnerSize.sm)
          else
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.surface.alternative,
                borderRadius: BorderRadius.circular(AppRadius.radius4),
              ),
            ),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: typography.bodySm.copyWith(color: colors.content.primary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null)
                  Text(
                    fileSize!,
                    style: typography.captionSm.copyWith(color: colors.content.muted),
                  ),
              ],
            ),
          ),
          if (onRemove != null)
            GestureDetector(
              onTap: onRemove,
              child: Text('✕', style: typography.bodySm.copyWith(color: colors.content.muted)),
            ),
        ],
      ),
    );
  }
}

Color _resolveBorderColor(SemanticColors colors, AttachmentState state) {
  return state == AttachmentState.error ? colors.negative.border : colors.border.base;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/attachment_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildAttachmentShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Attachment',
    statesBuilder: () => [
      Attachment(fileName: 'report.pdf', fileSize: '1.2 MB', onRemove: () {}),
      const Attachment(fileName: 'uploading.png', state: AttachmentState.uploading),
      const Attachment(fileName: 'corrupt.zip', state: AttachmentState.error),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/attachment/attachment.dart';
export 'src/components/attachment/attachment_state.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/attachment_showcase_spec.dart';
// ...
'Attachment': buildAttachmentShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Attachment" in catalog; "States" section shows an idle chip with a remove button, an uploading chip with a spinner, and an error chip with a red border.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/attachment lib/ui.dart example/lib/catalog
git commit -m "Add Attachment component"
```

---

### Task 37: Collapsible

**Files:**
- Create: `lib/src/components/collapsible/collapsible.dart`
- Create: `example/lib/catalog/specs/collapsible_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `Collapsible({required String title, required Widget content, bool initiallyExpanded = false})`.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/collapsible/collapsible.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_spacing.dart';

class Collapsible extends StatefulWidget {
  const Collapsible({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget content;
  final bool initiallyExpanded;

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  late bool _isExpanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _isExpanded ? 0.25 : 0,
                duration: AppMotion.durationFast,
                child: Text('▸', style: typography.bodyMd.copyWith(color: colors.content.secondary)),
              ),
              const SizedBox(width: AppSpacing.spacing8),
              Text(widget.title, style: typography.labelMd.copyWith(color: colors.content.primary)),
            ],
          ),
        ),
        AnimatedSize(
          duration: AppMotion.durationNormal,
          curve: AppMotion.curveStandard,
          child: _isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.spacing8),
                  child: widget.content,
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/collapsible_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCollapsibleShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Collapsible',
    statesBuilder: () => [
      SizedBox(
        width: 280,
        child: Collapsible(
          title: 'Collapsed',
          content: const Text('Hidden content.'),
        ),
      ),
      SizedBox(
        width: 280,
        child: Collapsible(
          title: 'Expanded',
          initiallyExpanded: true,
          content: const Text('Visible content revealed by expansion.'),
        ),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/collapsible/collapsible.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/collapsible_showcase_spec.dart';
// ...
'Collapsible': buildCollapsibleShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Collapsible" in catalog; "States" section shows one collapsed section (chevron pointing right, no visible content) and one expanded section (chevron rotated down, content visible). In a live run, tapping a header animates the chevron rotation and content reveal/hide.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/collapsible lib/ui.dart example/lib/catalog
git commit -m "Add Collapsible component"
```

---

### Task 38: Carousel

**Files:**
- Create: `lib/src/components/carousel/carousel.dart`
- Create: `example/lib/catalog/specs/carousel_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `Carousel({required List<Widget> items, double viewportWidth = 280, double itemHeight = 160})` — horizontal `PageView` with dot indicators.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/carousel/carousel.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';

class Carousel extends StatefulWidget {
  const Carousel({
    super.key,
    required this.items,
    this.viewportWidth = 280,
    this.itemHeight = 160,
  });

  final List<Widget> items;
  final double viewportWidth;
  final double itemHeight;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.viewportWidth,
          height: widget.itemHeight,
          child: PageView(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: widget.items,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _Dot(
                  isActive: i == _currentPage,
                  color: _resolveDotColor(colors, i == _currentPage),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.isActive, required this.color});

  final bool isActive;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
    );
  }
}

Color _resolveDotColor(SemanticColors colors, bool isActive) {
  return isActive ? colors.surface.inverted : colors.border.strong;
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/carousel_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildCarouselShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Carousel',
    variantsBuilder: () => [
      Carousel(
        items: [
          Container(color: const Color(0xFFEFF6FF)),
          Container(color: const Color(0xFFF0FDF4)),
          Container(color: const Color(0xFFFEF2F2)),
        ],
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/carousel/carousel.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/carousel_showcase_spec.dart';
// ...
'Carousel': buildCarouselShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Carousel" in catalog; "Variants" section shows a 3-page swipeable carousel with 3 dot indicators, the first (leftmost) dot elongated/active. Swiping updates the active dot.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/carousel lib/ui.dart example/lib/catalog
git commit -m "Add Carousel component"
```

---

### Task 39: Alert

**Files:**
- Create: `lib/src/components/alert/alert_variant.dart`
- Create: `lib/src/components/alert/alert.dart`
- Create: `example/lib/catalog/specs/alert_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `AlertVariant { info, positive, warning, negative }`, `Alert({required String title, String? description, AlertVariant variant = AlertVariant.info})` — the shape `Toast` (Task 40) reuses for its content.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/alert/alert_variant.dart

enum AlertVariant { info, positive, warning, negative }
```

```dart
// lib/src/components/alert/alert.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'alert_variant.dart';

class Alert extends StatelessWidget {
  const Alert({
    super.key,
    required this.title,
    this.description,
    this.variant = AlertVariant.info,
  });

  final String title;
  final String? description;
  final AlertVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final backgroundColor = _resolveBackgroundColor(colors, variant);
    final borderColor = _resolveBorderColor(colors, variant);
    final titleColor = _resolveTitleColor(colors, variant);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: typography.labelMd.copyWith(color: titleColor)),
          if (description != null) ...[
            const SizedBox(height: AppSpacing.spacing4),
            Text(
              description!,
              style: typography.bodySm.copyWith(color: colors.content.secondary),
            ),
          ],
        ],
      ),
    );
  }
}

Color _resolveBackgroundColor(SemanticColors colors, AlertVariant variant) {
  switch (variant) {
    case AlertVariant.info:
      return colors.info.surface;
    case AlertVariant.positive:
      return colors.positive.surface;
    case AlertVariant.warning:
      return colors.warning.surface;
    case AlertVariant.negative:
      return colors.negative.surface;
  }
}

Color _resolveBorderColor(SemanticColors colors, AlertVariant variant) {
  switch (variant) {
    case AlertVariant.info:
      return colors.info.border;
    case AlertVariant.positive:
      return colors.positive.border;
    case AlertVariant.warning:
      return colors.warning.border;
    case AlertVariant.negative:
      return colors.negative.border;
  }
}

Color _resolveTitleColor(SemanticColors colors, AlertVariant variant) {
  switch (variant) {
    case AlertVariant.info:
      return colors.info.textStrong;
    case AlertVariant.positive:
      return colors.positive.textStrong;
    case AlertVariant.warning:
      return colors.warning.textStrong;
    case AlertVariant.negative:
      return colors.negative.textStrong;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/alert_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildAlertShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Alert',
    variantsBuilder: () => AlertVariant.values
        .map((variant) => Alert(
              title: variant.name,
              description: 'This is an example ${variant.name} alert message.',
              variant: variant,
            ))
        .toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/alert/alert.dart';
export 'src/components/alert/alert_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/alert_showcase_spec.dart';
// ...
'Alert': buildAlertShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Alert" in catalog; "Variants" section shows 4 tinted, bordered alert boxes (info/positive/warning/negative) each with a title and description in matching status colors.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/alert lib/ui.dart example/lib/catalog
git commit -m "Add Alert component"
```

---

### Task 40: Toast

**Files:**
- Create: `lib/src/components/toast/toast.dart`
- Create: `example/lib/catalog/specs/toast_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `AlertVariant` (Task 39).
- Produces: `Toast({required String title, String? description, AlertVariant variant = AlertVariant.info})` — visually identical content block to `Alert` but with elevation (shadow) instead of a border, since it floats above content rather than sitting inline.

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/toast/toast.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../alert/alert_variant.dart';

/// Transient floating notification. Shares [AlertVariant]'s color mapping
/// with [Alert] but uses elevation instead of a border, since it floats
/// above content rather than sitting inline in a layout.
class Toast extends StatelessWidget {
  const Toast({
    super.key,
    required this.title,
    this.description,
    this.variant = AlertVariant.info,
  });

  final String title;
  final String? description;
  final AlertVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final titleColor = _resolveTitleColor(colors, variant);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppSpacing.spacing12),
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        boxShadow: AppElevation.level3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: titleColor,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: typography.labelMd.copyWith(color: colors.content.primary)),
                if (description != null) ...[
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    description!,
                    style: typography.bodySm.copyWith(color: colors.content.secondary),
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

Color _resolveTitleColor(SemanticColors colors, AlertVariant variant) {
  switch (variant) {
    case AlertVariant.info:
      return colors.info.ui;
    case AlertVariant.positive:
      return colors.positive.ui;
    case AlertVariant.warning:
      return colors.warning.ui;
    case AlertVariant.negative:
      return colors.negative.ui;
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/toast_showcase_spec.dart

import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildToastShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Toast',
    variantsBuilder: () => AlertVariant.values
        .map((variant) => Toast(
              title: variant.name,
              description: 'This is an example ${variant.name} toast.',
              variant: variant,
            ))
        .toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/toast/toast.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/toast_showcase_spec.dart';
// ...
'Toast': buildToastShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Toast" in catalog; "Variants" section shows 4 shadowed toast cards with a colored left accent bar per variant, distinct from Alert's flat-bordered look.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/toast lib/ui.dart example/lib/catalog
git commit -m "Add Toast component"
```

---

### Task 41: Popover

**Files:**
- Create: `lib/src/components/popover/popover.dart`
- Create: `example/lib/catalog/specs/popover_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Button` (Task 7).
- Produces: `Popover({required Widget trigger, required Widget Function(BuildContext) contentBuilder})` — anchored floating content triggered by tapping `trigger`, built on `OverlayEntry` (the low-level primitive for a positioned floating layer; there is no non-Material, non-`Overlay` equivalent in Flutter for this).

- [ ] **Step 1: Create the widget**

```dart
// lib/src/components/popover/popover.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';

/// Anchored floating content triggered by tapping [trigger]. Built on
/// [OverlayEntry] — the lowest-level Flutter primitive for a positioned
/// floating layer above the current route, with no non-Material
/// equivalent. Dismisses on tapping outside via a full-screen barrier.
class Popover extends StatefulWidget {
  const Popover({super.key, required this.trigger, required this.contentBuilder});

  final Widget trigger;
  final Widget Function(BuildContext context) contentBuilder;

  @override
  State<Popover> createState() => _PopoverState();
}

class _PopoverState extends State<Popover> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  void _toggle() {
    if (_entry != null) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    final colors = AppTokens.of(context).colors;
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: const Offset(0, 44),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: colors.surface.base,
                borderRadius: BorderRadius.circular(AppRadius.radius8),
                boxShadow: AppElevation.level3,
              ),
              child: widget.contentBuilder(context),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
    setState(() {});
  }

  void _close() {
    _entry?.remove();
    _entry = null;
    setState(() {});
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(onTap: _toggle, child: widget.trigger),
    );
  }
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/popover_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildPopoverShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Popover',
    variantsBuilder: () => [
      Popover(
        trigger: Button(label: 'Open popover', onPressed: () {}),
        contentBuilder: (context) => const SizedBox(
          width: 200,
          child: Text('Popover content goes here.'),
        ),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/popover/popover.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/popover_showcase_spec.dart';
// ...
'Popover': buildPopoverShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Popover" in catalog; "Variants" section shows an "Open popover" Button. In a live run, tapping it shows a shadowed floating content box below the button; tapping outside the box dismisses it.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/popover lib/ui.dart example/lib/catalog
git commit -m "Add Popover component"
```

---

### Task 42: Dialog

**Files:**
- Create: `lib/src/components/dialog/dialog_size.dart`
- Create: `lib/src/components/dialog/dialog.dart`
- Create: `example/lib/catalog/specs/dialog_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Consumes: `Button` (Task 7).
- Produces: `DialogSize { sm, md, lg }`, `AppDialog({required String title, required Widget content, List<Button> actions = const [], DialogSize size = DialogSize.md})` (named `AppDialog`) plus `Future<void> showAppDialog(BuildContext context, {required AppDialog dialog})` built on `showGeneralDialog` (the low-level primitive for a routed, barrier-dismissible modal; no non-Material equivalent).

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/dialog/dialog_size.dart

enum DialogSize { sm, md, lg }
```

```dart
// lib/src/components/dialog/dialog.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../button/button.dart';
import 'dialog_size.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions = const [],
    this.size = DialogSize.md,
  });

  final String title;
  final Widget content;
  final List<Button> actions;
  final DialogSize size;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;
    final width = _resolveWidth(size);

    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.spacing20),
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        boxShadow: AppElevation.level4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: typography.h3.copyWith(color: colors.content.primary)),
          const SizedBox(height: AppSpacing.spacing12),
          content,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.spacing20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.spacing8),
                  actions[i],
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

double _resolveWidth(DialogSize size) {
  switch (size) {
    case DialogSize.sm:
      return 280;
    case DialogSize.md:
      return 400;
    case DialogSize.lg:
      return 560;
  }
}

/// Presents [dialog] as a routed, barrier-dismissible modal built on
/// `showGeneralDialog` — the lowest-level Flutter primitive for this, with
/// no non-Material equivalent.
Future<void> showAppDialog(BuildContext context, {required AppDialog dialog}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(child: dialog);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      );
    },
  );
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/dialog_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildDialogShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Dialog',
    sizesBuilder: () => DialogSize.values
        .map((size) => AppDialog(
              title: '${size.name} dialog',
              size: size,
              content: const Text('Dialog body content goes here.'),
              actions: [
                Button(label: 'Cancel', variant: ButtonVariant.ghost, onPressed: () {}),
                Button(label: 'Confirm', onPressed: () {}),
              ],
            ))
        .toList(),
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/dialog/dialog.dart';
export 'src/components/dialog/dialog_size.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/dialog_showcase_spec.dart';
// ...
'Dialog': buildDialogShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Dialog" in catalog; "Sizes" section shows 3 ascending-width dialog cards, each with a title, body text, and Cancel/Confirm actions (rendered inline in the showcase, not as a presented modal — `showAppDialog` is exercised separately by wiring a temporary "Open dialog" Button in the same showcase page during manual verification, then removed before commit since the showcase renders static matrices only).

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/dialog lib/ui.dart example/lib/catalog
git commit -m "Add Dialog component"
```

---

### Task 43: Bottom Sheet

**Files:**
- Create: `lib/src/components/bottom_sheet/bottom_sheet_variant.dart`
- Create: `lib/src/components/bottom_sheet/bottom_sheet.dart`
- Create: `example/lib/catalog/specs/bottom_sheet_showcase_spec.dart`
- Modify: `lib/ui.dart`, `example/lib/catalog/component_registry.dart`

**Interfaces:**
- Produces: `BottomSheetVariant { standard, scrollable }`, `AppBottomSheet({required Widget content, BottomSheetVariant variant = BottomSheetVariant.standard})` (named `AppBottomSheet` to avoid colliding with Flutter's `BottomSheet`) plus `Future<void> showAppBottomSheet(BuildContext context, {required AppBottomSheet sheet})` built on `showModalBottomSheet`'s underlying `showGeneralDialog`-based routing — actually built directly on `showGeneralDialog` + slide transition for full control, matching Dialog's approach rather than pulling in a Material bottom-sheet widget.

- [ ] **Step 1: Create the enum and widget**

```dart
// lib/src/components/bottom_sheet/bottom_sheet_variant.dart

enum BottomSheetVariant { standard, scrollable }
```

```dart
// lib/src/components/bottom_sheet/bottom_sheet.dart

import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import 'bottom_sheet_variant.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.content,
    this.variant = BottomSheetVariant.standard,
  });

  final Widget content;
  final BottomSheetVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    final body = Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 480),
      padding: const EdgeInsets.all(AppSpacing.spacing20),
      decoration: BoxDecoration(
        color: colors.surface.base,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.radius16)),
        boxShadow: AppElevation.level4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.spacing16),
            decoration: BoxDecoration(
              color: colors.border.strong,
              borderRadius: BorderRadius.circular(AppRadius.radiusFull),
            ),
          ),
          variant == BottomSheetVariant.scrollable
              ? Flexible(child: SingleChildScrollView(child: content))
              : content,
        ],
      ),
    );

    return body;
  }
}

/// Presents [sheet] sliding up from the bottom, built directly on
/// `showGeneralDialog` with a slide transition (matching AppDialog's
/// approach) rather than Flutter's Material `showModalBottomSheet`.
Future<void> showAppBottomSheet(BuildContext context, {required AppBottomSheet sheet}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: const Color(0x66000000),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(alignment: Alignment.bottomCenter, child: sheet);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}
```

- [ ] **Step 2: Create the showcase spec and register it**

```dart
// example/lib/catalog/specs/bottom_sheet_showcase_spec.dart

import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildBottomSheetShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Bottom Sheet',
    variantsBuilder: () => [
      SizedBox(
        width: 320,
        child: AppBottomSheet(
          variant: BottomSheetVariant.standard,
          content: const Text('Standard bottom sheet content.'),
        ),
      ),
      SizedBox(
        width: 320,
        height: 200,
        child: AppBottomSheet(
          variant: BottomSheetVariant.scrollable,
          content: Column(
            children: List.generate(
              10,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text('Scrollable item $i'),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
```

Add to `lib/ui.dart`:

```dart
export 'src/components/bottom_sheet/bottom_sheet.dart';
export 'src/components/bottom_sheet/bottom_sheet_variant.dart';
```

Add to `component_registry.dart`:

```dart
import 'specs/bottom_sheet_showcase_spec.dart';
// ...
'Bottom Sheet': buildBottomSheetShowcaseSpec,
```

- [ ] **Step 3: Run on an emulator and visually verify**

```bash
cd /Users/eakl/dev/projects/roojai/example
fvm flutter run
```

Expected: "Bottom Sheet" in catalog; "Variants" section shows a standard sheet card and a scrollable sheet card (both rendered inline with rounded top corners and a drag-handle bar, matching the shape a real presented sheet would have), with the scrollable variant's 10 items scrolling within its constrained height.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/bottom_sheet lib/ui.dart example/lib/catalog
git commit -m "Add Bottom Sheet component"
```

---

## Done

After Task 43, all 33 components (Button + 32 others) are built, showcased, and verified on an emulator, matching every requirement in the spec's "Build phasing" section.
