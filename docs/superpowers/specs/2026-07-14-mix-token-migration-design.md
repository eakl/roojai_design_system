# Mix Token Migration — Design

Date: 2026-07-14

## Goal

Replace the design system's hand-rolled token layer (plain Dart value classes
+ a custom `AppTokens` `InheritedWidget`) with Fluttermix's token system
(`MixToken` subclasses resolved through `MixScope`), while preserving the
existing two-layer architecture: **primitives** (raw values, no semantic
meaning) → **semantic tokens** (named, theme-able values components consume).

This is **Part 1 of 3** in the broader Mix adoption:

1. **This spec** — migrate the token layer (primitives + semantic) to Mix's
   `MixToken`/`MixScope` system.
2. *(Follow-up spec)* — rewrite each component's `*_style_resolvers.dart` to
   declare a Mix `Style` (with variants) per component, driven by props
   (variant, size, state, disabled, loading, etc.) instead of per-property
   resolver functions returning raw Flutter values.
3. *(Follow-up spec)* — rewrite each component's `build()` to render via
   Mix's `Box`/styled-widget API instead of raw Flutter widgets
   (`Container`, `AnimatedContainer`, etc.), superseding the "no Material/
   wrapper widget" constraint from the original storybook spec.

Parts 2 and 3 are out of scope here and will each get their own spec/plan.

## Non-goals (this spec)

- No changes to component `build()` methods or `*_style_resolvers.dart`
  files — they still call the now-deleted `AppTokens.of(context)` API and
  **will not compile** until Part 2 lands. This is an accepted, temporary
  break; Part 2 is expected to follow immediately after this spec.
- No dark mode / multi-theme switching — single default-light theme only,
  same as today. The token map structure must not preclude adding themes
  later (Mix's `MixScope` override maps support this natively).
- No automated tests — this package has none today; verification stays
  visual (see Testing below), deferred until Part 2 restores compilation.

## Current state

- `lib/src/tokens/primitives/*.dart` — six files of raw Dart constants
  (`AppColors`, `AppSpacing`, `AppRadius`, `AppTypeScale`, `AppMotion`,
  `AppElevation`). No semantic meaning; only the semantic layer may import
  them.
- `lib/src/tokens/semantic/*.dart` — two files: `SemanticColors` (nested
  value classes: `CanvasColors`, `SurfaceColors`, `ContentColors`,
  `BorderColors`, `StatusColors` × positive/negative/warning/alert/info) and
  `SemanticTypography` (17 named `TextStyle` fields). Spacing, radius,
  motion, and elevation have **no** semantic layer today — components use
  the primitive scale directly (e.g. `AppSpacing.spacing16`).
- `lib/src/theme/app_tokens.dart` — `AppTokens` `InheritedWidget` exposing
  `colors`/`typography` via `AppTokens.of(context)`.
- `lib/src/theme/app_tokens_scope.dart` — `AppTokensScope` widget that
  installs `AppTokens` at the app root, defaulting to
  `SemanticColors.defaultLight` / `SemanticTypography.defaultScale`.
- `mix: ^2.1.0` is already a `pubspec.yaml` dependency but is not referenced
  anywhere in the codebase yet.

## Target architecture

Same two layers, now built on Mix's token primitives:

- **Primitives** — unchanged. Still plain Dart constants; still never
  imported by components directly.
- **Semantic** — every previously-hardcoded value becomes a top-level
  `final` variable declared with a `$` prefix and a hierarchical string id,
  e.g.:

  ```dart
  // lib/src/tokens/semantic/colors.dart
  final $canvasBase = ColorToken('color.canvas.base');
  final $contentOnBrand = ColorToken('color.content.onBrand');
  ```

  Grouped one file per category (`colors.dart`, `typography.dart`,
  `spacing.dart`, `radius.dart`, `motion.dart`, `elevation.dart`) under
  `lib/src/tokens/semantic/`.

- **Theme data** — a new `lib/src/theme/app_theme_data.dart` maps every
  semantic token to its default-light primitive value (the direct
  replacement for `SemanticColors.defaultLight` /
  `SemanticTypography.defaultScale`), e.g.:

  ```dart
  final defaultLightTokens = <MixToken, Object>{
    $canvasBase: AppColors.white,
    $contentOnBrand: AppColors.white,
    // ...
  };
  ```

- **Exposure** — `AppTokensScope` is rewritten to build a `MixScope` seeded
  from `app_theme_data.dart`, still accepting optional per-category
  override maps (`colors`, `textStyles`, `spaces`, `radii`, etc. — Mix
  `MixScope`'s existing constructor params) so a consuming app can retheme
  without touching component code. `AppTokens` (the accessor class) and
  `app_tokens.dart` are deleted; future resolvers (Part 2) will call
  `$token.resolve(context)` or embed `$token()` refs directly into a Mix
  `Style`.

## Token mapping per category

| Category | Mix token type | Naming scheme | Fidelity |
|---|---|---|---|
| Colors | `ColorToken` | `color.canvas.base`, `color.content.onBrand`, `color.positive.surface`, etc. | 1:1 mirror of every existing `SemanticColors` field. |
| Typography | `TextStyleToken` | `typography.displayMd`, `typography.bodyMd`, etc. | 1:1 mirror of every existing `SemanticTypography` field. |
| Spacing | `SpaceToken` | `spacing.2` … `spacing.96` | 1:1 mirror of all 15 primitive values — kept granular (not compressed to xs/sm/md/lg) because size-based padding resolvers depend on exact values. |
| Radius | `RadiusToken` | `radius.sm` (4), `radius.md` (8), `radius.lg` (12), `radius.xl` (16), `radius.full` | Only 5 primitive values — clean fit for a named scale. |
| Motion (duration) | `DurationToken` | `motion.duration.fast/normal/slow` | 1:1 mirror. |
| Motion (curve) | New `CurveToken extends MixToken<Curve>` | `motion.curve.standard/emphasized` | Mix ships no curve token type; `Curve` isn't a supported `MixToken.call()` reference type, so this token is resolved via `.resolve(context)` only — never via `call()`/`Prop` chains. |
| Elevation | `BoxShadowToken` | `elevation.level0` … `elevation.level4` | 1:1 mirror. |

## File layout

```
lib/src/tokens/
  primitives/              # unchanged
    app_colors.dart
    app_spacing.dart
    app_radius.dart
    app_typography.dart
    app_motion.dart
    app_elevation.dart
  semantic/
    colors.dart            # replaces semantic_colors.dart
    typography.dart        # replaces semantic_typography.dart
    spacing.dart           # new
    radius.dart            # new
    motion.dart            # new
    elevation.dart         # new
lib/src/theme/
  curve_token.dart         # new: CurveToken class
  app_theme_data.dart      # new: default-light token -> value map
  app_tokens_scope.dart    # rewritten: builds MixScope
  app_tokens.dart          # deleted
```

`lib/ui.dart` (public barrel) is updated to export the new semantic token
files in place of `semantic_colors.dart`/`semantic_typography.dart`, and to
drop the `app_tokens.dart` export.

## Migration steps

1. Add `curve_token.dart` (`CurveToken extends MixToken<Curve>`).
2. Create the six semantic token files, one `$`-prefixed `ColorToken`/
   `TextStyleToken`/`SpaceToken`/`RadiusToken`/`DurationToken`/`CurveToken`
   per existing value (colors, typography) or primitive entry (spacing,
   radius, motion, elevation).
3. Create `app_theme_data.dart` with the default-light token→value map,
   porting every value currently in `SemanticColors.defaultLight` /
   `SemanticTypography.defaultScale`, plus new entries for spacing/radius/
   motion/elevation aliasing their respective primitives.
4. Rewrite `app_tokens_scope.dart` to construct a `MixScope` from the theme
   data map, exposing the same override-friendly constructor shape as
   today's `AppTokensScope`.
5. Delete `app_tokens.dart`, `semantic_colors.dart`, `semantic_typography.dart`.
6. Update `lib/ui.dart` exports.
7. Leave component/`*_style_resolvers.dart` files untouched (they will fail
   to compile — expected, resolved in Part 2).

## Testing

No automated tests exist for this package; this holds for the token layer
too. Because component resolvers still reference the deleted `AppTokens`
API until Part 2 lands, this spec cannot be verified via the storybook app
on its own — compilation is expected to fail until Part 2's resolver
rewrite is merged. Verification for this spec is therefore limited to:

- `dart analyze` on the new/changed token and theme files in isolation.
- Manual review that every token id, naming, and default value is a
  faithful 1:1 (or documented named-scale) port of the current primitive/
  semantic values, with no value silently dropped or changed.

Full visual verification (running `ui_storybook`) happens once Part 2 is
complete.
