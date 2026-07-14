# Icon Component — Design

Date: 2026-07-14

## Goal

Add a design-system `Icon` component wrapping Phosphor icons (`phosphor_flutter`,
already a `pubspec.yaml` dependency, used today only by `button_2`'s loading
spinner). Callers pass a Phosphor glyph plus a t-shirt `size` and semantic
`variant`; `Icon` resolves both to concrete pixel/color values from the
design system's token layer.

## Context: which token system to build on

The codebase is mid-migration (see `2026-07-14-mix-token-migration-design.md`).
Part 1 replaced the hand-rolled `AppTokens`/`SemanticColors` token layer with
Mix's `MixToken`/`MixScope` system and deleted `app_tokens.dart` +
`semantic_colors.dart`. Part 2 (rewriting each component's build method to
consume Mix tokens) has not landed yet, so every "legacy" component that
still calls `AppTokens.of(context)` (`Badge`, `ButtonGroup`, `Select`,
`Avatar`, etc.) currently fails to compile — an accepted, temporary state
per that spec.

`button_2`/`DsButton` is the only component already migrated to the working
Mix-token system, and is not yet exported from `lib/ui.dart` or wired into
the example app's catalog.

`Icon` is built directly on the working Mix-token system (matching
`button_2`'s pattern), not the broken legacy pattern. It is intentionally
**not** exported from `lib/ui.dart` and **not** added to the catalog's
`componentRegistry`, matching `button_2`'s current (also unexported,
unshowcased) status — both will presumably be wired in together once Part 2
lands.

## File layout

New directory `lib/src/components/icon/`:

- `icon.dart` — the `Icon` widget.
- `icon_size.dart` — `enum IconSize { sm, md, lg, xl }`.
- `icon_variant.dart` — `enum IconVariant { neutral, brand, positive, negative, warning }`.
- `icon_style_resolver.dart` — `part of 'icon.dart'`, holds
  `_resolveIconSize`/`_resolveIconColor`, one pure function per resolved
  property (mirrors `button_2_style_resolver.dart`/
  `badge_style_resolvers.dart`'s one-resolver-per-property split).

## Widget API

```dart
class Icon extends StatelessWidget {
  const Icon(
    this.glyph, {
    super.key,
    this.size = IconSize.md,
    this.variant = IconVariant.neutral,
    this.style,
  });

  /// The glyph to render, e.g. `PhosphorIcons.check()`.
  final IconData glyph;

  /// Physical size — see [IconSize].
  final IconSize size;

  /// Semantic color treatment — see [IconVariant].
  final IconVariant variant;

  /// Escape hatch merged on top of the resolved style (e.g. a one-off
  /// color/opacity override), same shape as `DsButton.style`.
  final IconStyler? style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveIconStyle(size: size, variant: variant)
        .merge(style);
    return StyledIcon(icon: glyph, style: resolvedStyle);
  }
}
```

`StyledIcon` is Mix's own icon primitive (the same one `RemixButton` uses
internally to render `leadingIcon`/`trailingIcon`) — it takes a
`Style<IconSpec>` (`IconStyler`) and resolves any token refs against the
ambient `MixScope` itself. This means `Icon` never manually resolves a
`ColorToken` to a raw `Color` in plain Dart, matching how `DsButton` avoids
that entirely today.

`resolveIconStyle` (in `icon_style_resolver.dart`):

```dart
IconStyler resolveIconStyle({
  required IconSize size,
  required IconVariant variant,
}) {
  return IconStyler()
      .size(_resolveIconSize(size))
      .color(_resolveIconColor(variant));
}
```

## Sizes

`IconSize` maps to the existing spacing primitive scale (already used
elsewhere for icon extents, e.g. `input`'s `sm=20/md=24/lg=28`):

| `IconSize` | px | token |
|---|---|---|
| `sm` | 16 | `$spacing016` |
| `md` | 20 | `$spacing020` |
| `lg` | 24 | `$spacing024` |
| `xl` | 32 | `$spacing032` |

## Colors

`IconVariant` reuses four existing semantic color tokens as-is:

| `IconVariant` | token |
|---|---|
| `brand` | `$brandText` |
| `positive` | `$positiveText` |
| `negative` | `$negativeText` |
| `warning` | `$warningText` |

`neutral` (the default) needs one **new** semantic token, since no existing
token resolves to `AppColors.neutral600`:

- `lib/src/tokens/semantic/colors.dart` — add
  `final $iconNeutral = ColorToken('color.icon.neutral');`
- `lib/src/theme/light/colors.dart` — add
  `$iconNeutral: AppColors.neutral600,` to `lightColors`.

No other new tokens are added — the other four variants deliberately reuse
existing `*Text` tokens rather than introducing icon-specific duplicates.

## Non-goals

- No `lib/ui.dart` export, no catalog `componentRegistry`/showcase spec —
  see Context above.
- No Phosphor weight-variant param (regular/bold/duotone/fill/thin/light) —
  callers select the weight themselves via the glyph they pass in (e.g.
  `PhosphorIcons.check(PhosphorIconsStyle.bold)`); `Icon` only controls
  size/color.
- No automated tests — none exist for this package yet (see the migration
  spec's Testing section).

## Testing

Same constraint as the migration spec: the example app (`ui_storybook`)
cannot currently build (legacy components still reference the deleted
`AppTokens` API), so this can't be verified by running the storybook.
Verification is limited to `dart analyze` on the new `icon/` files in
isolation (`flutter analyze lib/src/components/icon`, using an SDK new
enough for the `remix`/`mix` dependency versions — the project's only
available local Flutter SDK, 3.19.0/Dart 3.3.0, is too old and cannot even
run `pub get` for this repo).
