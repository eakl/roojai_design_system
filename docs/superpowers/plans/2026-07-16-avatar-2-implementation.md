# avatar_2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `DsAvatar` (`avatar_2`), a design-system wrapper around the `remix` package's `RemixAvatar`, matching the structural conventions of `button_2`/`badge_2`/`input_2`, with automatic image-load fallback and a catalog showcase entry.

**Architecture:** Three files under `lib/src/components/avatar_2/` — an enums file (`avatar_2_variants.dart`), a pure style-resolver function (`avatar_2_style_resolver.dart`, `part of` the main library), and the `DsAvatar` widget itself (`avatar_2.dart`). `DsAvatar` is a `StatefulWidget` (unlike its `_2` siblings) because it must track image-load failure itself and swap to fallback content — `RemixAvatar` only exposes an error *callback*, it doesn't re-render on failure. Exported from `lib/ui.dart`; showcased via a new `avatar_2_showcase_spec.dart` registered in `example/lib/catalog/component_registry.dart`.

**Tech Stack:** Flutter, the `remix` package (`RemixAvatar`/`RemixAvatarStyle`/`RemixAvatarSpec`), Mix (`package:mix/mix.dart`) semantic design tokens.

## Global Constraints

- Follow the exact file-split convention used by `button_2`/`badge_2`: enums in their own file, style resolver as a `part of` file, widget in the main file — see `lib/src/components/badge_2/badge_2.dart:1-17` for the `part` directive pattern.
- No `child` escape-hatch parameter — matches legacy `Avatar` and every other `_2` component.
- `style`/`styleSpec` escape hatches must follow the exact naming/typing convention from `badge_2.dart:59-75` (`final RemixAvatarStyle style;` defaulting to `const RemixAvatarStyle.create()`, `final StyleSpec<RemixAvatarSpec>? styleSpec;`).
- This repo has no widget-test suite for any `_2` component (confirmed: no `test/` directory exists) — verification is via `flutter analyze` (or `dart analyze`, whichever the project uses — check `melos.yaml`/`analysis_options.yaml` if unsure) and manually running the catalog app. Do not invent a test file/directory that doesn't match an existing pattern.
- Design spec of record: `docs/superpowers/specs/2026-07-16-avatar-2-component-design.md`. Exact token names, size table, and color mappings below are copied from it — do not deviate.

---

### Task 1: `avatar_2_variants.dart` — enums

**Files:**
- Create: `lib/src/components/avatar_2/avatar_2_variants.dart`

**Interfaces:**
- Produces: `DsAvatarSize` (`sm`, `md`, `lg`, `xl`), `DsAvatarVariant` (`soft`, `solid`), `DsAvatarShape` (`circle`, `square`) — consumed by Task 2 (style resolver) and Task 3 (widget).

- [ ] **Step 1: Write the enums file**

```dart
enum DsAvatarSize { sm, md, lg, xl }

enum DsAvatarVariant { soft, solid }

enum DsAvatarShape { circle, square }
```

- [ ] **Step 2: Verify it analyzes cleanly**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze lib/src/components/avatar_2/avatar_2_variants.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/avatar_2/avatar_2_variants.dart
git commit -m "feat(avatar_2): add DsAvatarSize/DsAvatarVariant/DsAvatarShape enums"
```

---

### Task 2: `avatar_2_style_resolver.dart` — `resolveDsAvatarStyle`

**Files:**
- Create: `lib/src/components/avatar_2/avatar_2_style_resolver.dart` (declared `part of 'avatar_2.dart';` — this file cannot be analyzed standalone; it's pulled in once `avatar_2.dart` exists in Task 3. Write it now, verify it in Task 3's analyze step.)

**Interfaces:**
- Consumes: `DsAvatarSize`, `DsAvatarVariant`, `DsAvatarShape` from Task 1.
- Produces: `RemixAvatarStyle resolveDsAvatarStyle({required DsAvatarVariant variant, required DsAvatarSize size, required DsAvatarShape shape})` — consumed by Task 3's `DsAvatar.build`.

- [ ] **Step 1: Write the style resolver**

```dart
part of 'avatar_2.dart';

RemixAvatarStyle resolveDsAvatarStyle({
  required DsAvatarVariant variant,
  required DsAvatarSize size,
  required DsAvatarShape shape,
}) {
  // `clipBehavior(.hardEdge)` is required for `image` to actually clip to
  // the resolved shape — `BoxDecoration`'s image otherwise ignores
  // `borderRadius`. `labelFontWeight` matches legacy `Avatar`'s and Remix
  // Fortal's fallback-text weight.
  final baseStyle = RemixAvatarStyle()
      .clipBehavior(Clip.hardEdge)
      .labelFontWeight(FontWeight.w500);

  final sizeStyle = switch (size) {
    DsAvatarSize.sm => RemixAvatarStyle()
        .square(24)
        .labelStyle($captionSm.mix()),
    DsAvatarSize.md => RemixAvatarStyle()
        .square(32)
        .labelStyle($labelSm.mix()),
    DsAvatarSize.lg => RemixAvatarStyle()
        .square(40)
        .labelStyle($labelMd.mix()),
    DsAvatarSize.xl => RemixAvatarStyle()
        .square(64)
        .labelStyle($labelLg.mix()),
  };

  // Icon fallback size is fixed per `size`, reusing `icon_2`'s own
  // `DsIconSize` scale 1:1 (both have exactly 4 steps) — same pattern as
  // `input_2`'s `_resolveDsInputIconSize`. `DsAvatar` maps this separately
  // in `avatar_2.dart` when building the `Icon` fallback widget; here we
  // only size Remix's own `IconStyler` slot to match, in case a caller's
  // `iconBuilder`-less default path is ever exercised directly through
  // `styleSpec`.
  final iconSizeStyle = switch (size) {
    DsAvatarSize.sm => RemixAvatarStyle().iconSize($spacing016()),
    DsAvatarSize.md => RemixAvatarStyle().iconSize($spacing020()),
    DsAvatarSize.lg => RemixAvatarStyle().iconSize($spacing024()),
    DsAvatarSize.xl => RemixAvatarStyle().iconSize($spacing032()),
  };

  // `circle` uses a radius token large enough that a square container
  // renders fully round at every size. `square` uses a per-size radius
  // that grows with diameter so corner rounding stays proportional.
  final shapeStyle = switch (shape) {
    DsAvatarShape.circle => RemixAvatarStyle().borderRadiusAll($radiusFull()),
    DsAvatarShape.square => switch (size) {
        DsAvatarSize.sm => RemixAvatarStyle().borderRadiusAll($radius004()),
        DsAvatarSize.md => RemixAvatarStyle().borderRadiusAll($radius008()),
        DsAvatarSize.lg => RemixAvatarStyle().borderRadiusAll($radius012()),
        DsAvatarSize.xl => RemixAvatarStyle().borderRadiusAll($radius016()),
      },
  };

  // Fallback-only colors — a rendered `image` visually hides these, since
  // `RemixAvatar` paints the image as a `BoxDecoration.image` above the
  // container's background color.
  final variantStyle = switch (variant) {
    DsAvatarVariant.soft => RemixAvatarStyle()
        .backgroundColor($accentSurface())
        .labelColor($accentText())
        .iconColor($accentText()),
    DsAvatarVariant.solid => RemixAvatarStyle()
        .backgroundColor($accentSurfaceStrong())
        .labelColor($contentOnBrand())
        .iconColor($contentOnBrand()),
  };

  return baseStyle
      .merge(sizeStyle)
      .merge(iconSizeStyle)
      .merge(shapeStyle)
      .merge(variantStyle);
}
```

- [ ] **Step 2: Move to Task 3** — this file has no standalone analyze step; verification happens once `avatar_2.dart` exists (Task 3, Step 4).

---

### Task 3: `avatar_2.dart` — the `DsAvatar` widget

**Files:**
- Create: `lib/src/components/avatar_2/avatar_2.dart`

**Interfaces:**
- Consumes: `DsAvatarSize`/`DsAvatarVariant`/`DsAvatarShape` (Task 1), `resolveDsAvatarStyle` (Task 2), `Icon`/`DsIconSize` from `../icon_2/icon.dart` + `../icon_2/icon_variants.dart` (existing).
- Produces: `class DsAvatar extends StatefulWidget` with constructor `DsAvatar({Key? key, ImageProvider? image, ImageErrorListener? onImageError, String? label, IconData? icon, DsAvatarVariant variant = DsAvatarVariant.soft, DsAvatarSize size = DsAvatarSize.md, DsAvatarShape shape = DsAvatarShape.circle, RemixAvatarStyle style = const RemixAvatarStyle.create(), StyleSpec<RemixAvatarSpec>? styleSpec})` — consumed by Task 5 (catalog showcase) and Task 6 (export).

- [ ] **Step 1: Write the widget file**

```dart
import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import '../icon_2/icon.dart';
import '../icon_2/icon_variants.dart';
import 'avatar_2_variants.dart';

// The `resolveDsAvatarStyle` function consumed by `build()` below lives in
// avatar_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsAvatar while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsBadge`'s `badge_2_style_resolver.dart`.
part 'avatar_2_style_resolver.dart';

/// Maps [DsAvatar]'s own size enum onto [Icon]'s, so the fallback glyph
/// scales with the avatar instead of needing a second size prop from
/// callers — same pattern as `input_2`'s `_resolveDsInputIconSize`. Both
/// enums have exactly four steps, so this is a direct 1:1 mapping.
DsIconSize _resolveDsAvatarIconSize(DsAvatarSize size) {
  return switch (size) {
    DsAvatarSize.sm => DsIconSize.sm,
    DsAvatarSize.md => DsIconSize.md,
    DsAvatarSize.lg => DsIconSize.lg,
    DsAvatarSize.xl => DsIconSize.xl,
  };
}

/// Normalizes [label] to at most two uppercase characters, so a caller
/// passing a full name or lowercase text still lays out as a compact
/// two-glyph initials circle instead of overflowing or looking
/// inconsistent with the rest of the design system. Ported from legacy
/// `Avatar`'s `_resolveFallbackText`.
String _resolveDsAvatarLabelText(String label) {
  final normalized = label.trim().toUpperCase();
  return normalized.length <= 2 ? normalized : normalized.substring(0, 2);
}

/// A circular or rounded-square photo avatar with a text/icon fallback,
/// built on top of the `remix` package's [RemixAvatar], styled through the
/// design system's Mix semantic tokens.
///
/// Unlike every other `_2` component, [DsAvatar] is a [StatefulWidget]:
/// [RemixAvatar] does not automatically swap to fallback content when
/// [image] fails to load — it only exposes an
/// `onBackgroundImageError`/[onImageError]-style *callback*, leaving state
/// management to the caller. [DsAvatar] tracks that failure itself
/// (mirroring legacy `Avatar`'s `Image.errorBuilder` behavior) so callers
/// get automatic fallback-on-error without wiring anything themselves. See
/// `docs/superpowers/specs/2026-07-16-avatar-2-component-design.md`.
class DsAvatar extends StatefulWidget {
  const DsAvatar({
    super.key,
    this.image,
    this.onImageError,
    this.label,
    this.icon,
    this.variant = DsAvatarVariant.soft,
    this.size = DsAvatarSize.md,
    this.shape = DsAvatarShape.circle,
    this.style = const RemixAvatarStyle.create(),
    this.styleSpec,
  });

  /// The avatar's photo, from any source Flutter supports —
  /// `NetworkImage`, `AssetImage`, `MemoryImage`, `FileImage`, etc. When
  /// null, or when it fails to load, [label]/[icon] are shown instead.
  final ImageProvider? image;

  /// Optional passthrough so callers can also observe image-load
  /// failures (e.g. for logging), independent of the automatic fallback
  /// this widget performs on failure.
  final ImageErrorListener? onImageError;

  /// Fallback text shown when [image] is null or fails to load, and no
  /// [icon] fallback takes priority. Expected to be two-letter initials
  /// (e.g. "JD"), but defensively uppercased and truncated to two
  /// characters — see [_resolveDsAvatarLabelText].
  final String? label;

  /// Fallback icon shown when [image] is null or fails to load and
  /// [label] is null. Ignored when [label] is non-null — same
  /// content-priority chain as [RemixAvatar] itself.
  final IconData? icon;

  /// Visual treatment of the fallback content — see [DsAvatarVariant].
  /// A rendered [image] visually hides this.
  final DsAvatarVariant variant;

  /// Physical size — see [DsAvatarSize].
  final DsAvatarSize size;

  /// Corner shape — see [DsAvatarShape].
  final DsAvatarShape shape;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsAvatarStyle]'s output). Same
  /// convention as [DsButton.style]/[DsBadge.style].
  final RemixAvatarStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixAvatarSpec] directly, bypassing style resolution entirely.
  final StyleSpec<RemixAvatarSpec>? styleSpec;

  @override
  State<DsAvatar> createState() => _DsAvatarState();
}

class _DsAvatarState extends State<DsAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(DsAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A newly-assigned image gets a fresh load attempt instead of staying
    // stuck on a previous image's failure.
    if (widget.image != oldWidget.image) {
      _imageFailed = false;
    }
  }

  void _handleImageError(Object error, StackTrace? stackTrace) {
    widget.onImageError?.call(error, stackTrace);
    if (!_imageFailed) {
      setState(() => _imageFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsAvatarStyle(
      variant: widget.variant,
      size: widget.size,
      shape: widget.shape,
    ).merge(widget.style);

    final showImage = widget.image != null && !_imageFailed;

    return RemixAvatar(
      backgroundImage: showImage ? widget.image : null,
      onBackgroundImageError: showImage ? _handleImageError : null,
      label: widget.label == null
          ? null
          : _resolveDsAvatarLabelText(widget.label!),
      iconBuilder: widget.label == null && widget.icon != null
          ? (context, spec, icon) => Icon(
                icon!,
                size: _resolveDsAvatarIconSize(widget.size),
              )
          : null,
      icon: widget.label == null ? widget.icon : null,
      style: resolvedStyle,
      styleSpec: widget.styleSpec,
    );
  }
}
```

- [ ] **Step 2: Sanity-check the content-priority wiring by reading it back**

Confirm in the written file: `label` is passed whenever `widget.label != null` (regardless of `icon`), and `icon`/`iconBuilder` are only passed when `widget.label == null` — this matches `RemixAvatar`'s own "label wins over icon" priority documented in `avatar_widget.dart`.

- [ ] **Step 3: Run `flutter pub get` to make sure the `ui` package still resolves**

Run: `cd /Users/eakl/dev/projects/roojai && flutter pub get`
Expected: exits 0, no dependency errors.

- [ ] **Step 4: Analyze the whole `avatar_2` directory (pulls in Task 2's `part` file too)**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze lib/src/components/avatar_2/`
Expected: `No issues found!` — fix any errors before proceeding (common ones: missing `$spacing016` import from `tokens/primitives/spacing.dart`, wrong token names — cross-check against `lib/src/tokens/semantic/colors.dart`, `radius.dart`, `typography.dart`, `lib/src/tokens/primitives/spacing.dart`).

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/avatar_2/avatar_2.dart lib/src/components/avatar_2/avatar_2_style_resolver.dart
git commit -m "feat(avatar_2): add DsAvatar widget with automatic image-fallback"
```

---

### Task 4: Export from `lib/ui.dart`

**Files:**
- Modify: `lib/ui.dart:21-22` (insert before the existing commented-out legacy `avatar` export block and before `badge_2`'s export, keeping alphabetical component ordering)

**Interfaces:**
- Consumes: `DsAvatar` (Task 3), `DsAvatarSize`/`DsAvatarVariant`/`DsAvatarShape` (Task 1).
- Produces: public export surface used by Task 5 (catalog, via `package:ui/ui.dart`) and any external consumer.

- [ ] **Step 1: Add the export lines**

In `lib/ui.dart`, immediately above the existing commented-out block:
```dart
// export 'src/components/avatar/avatar.dart';
// export 'src/components/avatar/avatar_group.dart';
// export 'src/components/avatar/avatar_size.dart';
```
insert:
```dart
export 'src/components/avatar_2/avatar_2.dart';
export 'src/components/avatar_2/avatar_2_variants.dart';
```

So the surrounding block reads:
```dart
// Components.
export 'src/components/avatar_2/avatar_2.dart';
export 'src/components/avatar_2/avatar_2_variants.dart';
// export 'src/components/avatar/avatar.dart';
// export 'src/components/avatar/avatar_group.dart';
// export 'src/components/avatar/avatar_size.dart';
export 'src/components/badge_2/badge_2.dart';
export 'src/components/badge_2/badge_2_variants.dart';
```

- [ ] **Step 2: Analyze the whole package**

Run: `cd /Users/eakl/dev/projects/roojai && flutter analyze lib/`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/ui.dart
git commit -m "feat(avatar_2): export DsAvatar from ui.dart"
```

---

### Task 5: Catalog showcase spec + registry entry

**Files:**
- Create: `example/lib/catalog/specs/avatar_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart:2-27` (add import + registry entry, alphabetically before `Badge 2`)

**Interfaces:**
- Consumes: `DsAvatar`, `DsAvatarVariant`, `DsAvatarSize` (from `package:ui/ui.dart`, Task 4), `ComponentShowcaseSpec` (existing, `example/lib/catalog/component_showcase_spec.dart`).
- Produces: `ComponentShowcaseSpec buildAvatar2ShowcaseSpec()`, registered under the key `'Avatar 2'`.

- [ ] **Step 1: Write the showcase spec**

```dart
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildAvatar2ShowcaseSpec() {
  const brokenImageUrl = 'https://example.invalid/broken-avatar.png';
  const photoUrl =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop';

  return ComponentShowcaseSpec(
    title: 'Avatar 2',
    variantsBuilder: () => DsAvatarVariant.values
        .map(
          (variant) => DsAvatar(
            label: variant.name.substring(0, 2),
            variant: variant,
          ),
        )
        .toList(),
    sizesBuilder: () => DsAvatarSize.values
        .map(
          (size) => DsAvatar(
            label: size.name,
            size: size,
          ),
        )
        .toList(),
    statesBuilder: () => [
      const DsAvatar(
        image: NetworkImage(photoUrl),
        label: 'JD',
      ),
      const DsAvatar(
        image: NetworkImage(brokenImageUrl),
        label: 'JD',
      ),
      const DsAvatar(label: 'AB'),
      DsAvatar(icon: PhosphorIcons.user()),
      const DsAvatar(label: 'SQ', shape: DsAvatarShape.square),
    ],
  );
}
```

- [ ] **Step 2: Register it**

In `example/lib/catalog/component_registry.dart`, add the import alongside the other spec imports (alphabetically first):
```dart
import 'specs/avatar_2_showcase_spec.dart';
```
and add the registry entry as the first line of the map (alphabetically before `'Badge 2'`):
```dart
'Avatar 2': buildAvatar2ShowcaseSpec,
```

- [ ] **Step 3: Analyze the example app**

Run: `cd /Users/eakl/dev/projects/roojai/example && flutter analyze lib/catalog/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/avatar_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(avatar_2): add catalog showcase spec"
```

---

### Task 6: Manual verification in the catalog app

**Files:** none (verification only)

**Interfaces:**
- Consumes: everything from Tasks 1-5.

- [ ] **Step 1: Launch the catalog app**

Use the project's `run` skill (or `cd /Users/eakl/dev/projects/roojai/example && flutter run -d chrome`, whichever the project's established launch method is) and navigate to the "Avatar 2" entry in the component catalog.

- [ ] **Step 2: Verify each showcase section renders correctly**

Check:
- **Variants** section shows a `soft` avatar (tinted background, accent-colored initials) and a `solid` avatar (bold accent background, contrasting initials).
- **Sizes** section shows four avatars visibly increasing in diameter (24/32/40/64px).
- **States** section shows: a real photo rendering correctly; a broken-image URL avatar that displays its "JD" initials fallback (not a broken-image icon or blank box) — this specifically confirms the automatic image-fallback state management from Task 3 works; a label-only "AB" avatar; an icon-only avatar; and a square-shaped "SQ" avatar with visibly rounded corners (not a full circle).

- [ ] **Step 3: Fix and re-verify if anything looks wrong**

If the broken-image state doesn't fall back correctly, re-check Task 3 Step 1's `_handleImageError`/`didUpdateWidget` wiring against the spec's "Automatic image-fallback" section before re-running Step 1.

No commit for this task — it's verification only, confirming the prior five commits are correct.
