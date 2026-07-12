# Flutter Design System + Storybook App — Design

Date: 2026-07-12

## Goal

Scaffold a Flutter project that is a **design system package** (`ui`) plus a
runnable **showcase/storybook app** (`ui_storybook`) that can be launched on
an iOS or Android emulator. The storybook app lists every design system
component on a home page; tapping a component opens a detail page that
statically renders all of its variants, sizes, and states — driven by real
components wired to primitive and semantic design tokens, not screenshots or
mockups.

## Non-goals (this iteration)

- No dark mode / multi-theme switching (single theme only; architecture
  should not preclude adding it later).
- No automated tests (widget/golden) — verification is visual, by running the
  app on an emulator.
- No wrapping of Flutter Material widgets — components are built from
  low-level primitives for full visual control.
- No Storybook-style interactive controls/knobs — sections are static
  matrices of pre-selected variant/size/state combinations.
- Flutter/Xcode/Android SDK toolchain installation is out of scope; assumed
  to be installed by the user before scaffolding begins.

## Repo layout

Single Flutter package with a nested `example/` app, the standard pub.dev
pattern:

```
roojai/
  pubspec.yaml                    # package name: ui
  lib/
    ui.dart                       # public barrel export
    src/
      tokens/
        primitives/
          app_colors.dart
          app_spacing.dart
          app_radius.dart
          app_typography.dart
          app_elevation.dart
          app_motion.dart
        semantic/
          semantic_colors.dart
          semantic_spacing.dart
          semantic_typography.dart
          semantic_radius.dart
      theme/
        app_tokens.dart           # InheritedWidget exposing semantic tokens
        app_tokens_scope.dart     # widget that installs AppTokens at the app root
      components/
        button/
          button.dart
          button_variant.dart
          button_size.dart
          button_state.dart
        avatar/
        badge/
        alert/
        dialog/
        attachment/
        button_group/
        card/
        carousel/
        checkbox/
        collapsible/
        empty/
        form_field/
        input/
        input_group/
        input_otp/
        list/
        list_item/
        label/
        select/
        popover/
        progress/
        radio/
        separator/
        bottom_sheet/
        skeleton/
        slider/
        toast/
        spinner/
        switch/
        tabs/
        textarea/
        toggle/
        toggle_group/
  example/
    pubspec.yaml                  # app: ui_storybook, depends on ../ (path dependency)
    ios/, android/                # standard Flutter platform folders
    lib/
      main.dart
      catalog/
        catalog_home_page.dart          # flat alphabetical list of all components
        component_showcase_page.dart    # generic scaffold rendering Variants/Sizes/States
        component_showcase_spec.dart    # data model for a component's showcase spec
        specs/
          button_showcase_spec.dart
          avatar_showcase_spec.dart
          ...                          # one per component
```

## Tokens

**Primitives** (`lib/src/tokens/primitives/`): plain Dart classes with
`static const` fields holding raw design values — color swatches
(`AppColors.blue500`), spacing scale (`AppSpacing.space4`), radius scale
(`AppRadius.radius8`), type scale (`AppTypography.textSm`), elevation/shadow
definitions, motion durations/curves. No semantic meaning, just raw values.

**Semantic tokens** (`lib/src/tokens/semantic/`): classes that map primitives
to semantic roles — e.g. `SemanticColors.backgroundPrimary`,
`SemanticColors.textOnPrimary`, `SemanticColors.borderDanger`,
`SemanticSpacing.componentPaddingMd`. These are what components actually
reference — never primitives directly — so retheming means changing the
semantic layer only.

**Token access**: a single `InheritedWidget`, `AppTokens`, holds one instance
of each semantic token class and is installed once at the app root via
`AppTokensScope`. Components call `AppTokens.of(context).colors.xxx` etc.
Built as a plain custom `InheritedWidget` (not `ThemeData`/`ThemeExtension`,
per explicit preference) so it composes independently of `MaterialApp`/
`CupertinoApp` theming. Kept as a single light theme for now, but the
`AppTokens` shape (one token set object) means a second (dark) instance and a
switch mechanism can be added later without touching component code.

## Component pattern

Every component's code must be **explicit and readable over clever/compact**:
inline comments explaining non-obvious choices, no unnecessary abstraction,
straightforward control flow a newcomer can follow.

Each component folder (e.g. `components/button/`) contains:

- **`<name>_variant.dart`**: an enum of the component's visual variants (e.g.
  `enum ButtonVariant { primary, secondary, outline, ghost, destructive }`).
  Omitted for components with no variant axis.
- **`<name>_size.dart`**: an enum of sizes (e.g.
  `enum ButtonSize { sm, md, lg }`). Omitted for components with no size axis.
- **`<name>_state.dart`**: an enum of visual states the component can be
  rendered in for the showcase (e.g.
  `enum ButtonState { enabled, hovered, pressed, focused, disabled, loading }`).
  Real interactive components also derive their *live* state at runtime from
  actual gesture/focus signals (see below) — this enum is the shared
  vocabulary used both by live-state derivation and by the static showcase.
- **`<name>.dart`**: the public widget. Structure inside this file, top to
  bottom:
  1. **Token block at the top** — a small, clearly-commented section (e.g. a
     `_ButtonTokens` helper or a set of local `final` bindings resolved at
     the top of `build()`) that pulls every semantic token this component
     uses out of `AppTokens.of(context)` by name, e.g.:
     ```dart
     // Semantic tokens used by Button — change these bindings to restyle
     // the component without touching layout/behavior code below.
     final tokens = AppTokens.of(context);
     final backgroundColor = _resolveBackgroundColor(tokens, variant, state);
     final textColor = _resolveTextColor(tokens, variant, state);
     final padding = _resolvePadding(tokens, size);
     final borderRadius = tokens.radius.radiusMd;
     ```
     This block is the single place to look to see (and edit) exactly which
     semantic tokens a component depends on.
  2. **Resolver functions** — whenever a size, variant, or state must be
     mapped to a concrete token/value, this happens in a named, private,
     pure function (e.g. `_resolveBackgroundColor(AppTokens, ButtonVariant,
     ButtonState) -> Color`), not inline in `build()` and not via scattered
     ternaries. One resolver per resolved property. This keeps every
     decision point named, testable in isolation, and easy to scan.
  3. **Live state derivation** — interactive components wrap their content
     in the minimal widgets needed to derive real state (`GestureDetector` +
     manual pressed tracking, `FocusNode`/`Focus`, `MouseRegion` for hover on
     desktop/web pointers), map that to the shared `<name>_state.dart` enum,
     and feed it into the resolver functions. Disabled/loading are explicit
     constructor parameters, not inferred.
  4. **Build/layout** — assembles the widget tree from the resolved values.
     No token lookups or resolution logic inline here.

**Reference implementation**: `Button` is built first, fully following this
pattern (tokens, variant/size/state enums, resolvers, live state, showcase
spec). Every other component copies this shape.

## Catalog app

- **`CatalogHomePage`**: a flat, alphabetically sorted `ListView` of all 33
  component names; tapping one navigates to `ComponentShowcasePage` for that
  component.
- **`ComponentShowcaseSpec`**: a small data class each component defines
  (under `example/lib/catalog/specs/`) declaring:
  - `title` (display name)
  - `variantsBuilder`: `List<Widget> Function()?` — one widget per variant,
    each rendered with default size/state (omitted if no variants)
  - `sizesBuilder`: `List<Widget> Function()?` — one widget per size
  - `statesBuilder`: `List<Widget> Function()?` — one widget per showcased
    state (disabled, loading, etc. — using the component's real constructor
    flags, not visual faking, wherever the component supports them directly;
    a display-only override is used only for states that are inherently
    transient, e.g. "pressed")
- **`ComponentShowcasePage`**: one generic, reusable page that takes a
  `ComponentShowcaseSpec` and renders each non-null builder as a labeled
  section ("Variants", "Sizes", "States") with its widgets laid out in a
  wrapped row/grid. Components without a given axis simply don't show that
  section. This page is written once and reused for all 33 components.

## Build phasing

1. **Foundation** — `pubspec.yaml` for `ui`, `example/` app scaffold
   (`ui_storybook`, bundle id `com.roojai.ui_storybook`) wired as a path
   dependency, primitive + semantic token files, `AppTokens`/
   `AppTokensScope`, `CatalogHomePage` (can be empty list), app runs on
   iOS/Android emulator showing the empty catalog shell.
2. **Reference component** — `Button` built fully per the pattern above,
   its `ComponentShowcaseSpec`, `ComponentShowcasePage` built and wired,
   verified visually in the running app.
3. **Remaining 32 components** in small batches, following the Button
   pattern, roughly in this order: Avatar, Badge, Label, Separator, Spinner,
   Skeleton, Progress, Switch, Checkbox, Radio, Toggle, Toggle Group, Input,
   Textarea, Input Group, Input OTP, Form Field, Select, Slider, Button
   Group, Tabs, Card, List, List Item, Empty, Attachment, Collapsible,
   Carousel, Alert, Toast, Popover, Dialog, Bottom Sheet. Each batch: build
   widget(s) → showcase spec → run on emulator → visually verify.

## Verification approach

No automated tests in this iteration. After each batch in phase 3 (and after
phases 1–2), run the storybook app on an iOS or Android emulator and visually
confirm: the component appears on the home list, its detail page renders all
declared variants/sizes/states correctly, and interactive states (hover/press/
focus/disabled) behave as expected when touched/clicked in the running app.

## Naming

- Package: `ui`
- Example app: `ui_storybook`, bundle id `com.roojai.ui_storybook`
- Prerequisite: Flutter SDK must be installed and `flutter doctor` clean
  before scaffolding begins (not installed as of this writing — user will
  install separately).
