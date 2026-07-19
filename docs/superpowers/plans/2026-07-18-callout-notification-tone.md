# callout_2 / notification_2 Soft/Solid Tone Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `tone` axis (`{ soft, solid }`) to `DsCallout` and `DsNotification`, independent of their existing semantic-color `variant` axis, so each color can render either the current tinted "soft" look or a new saturated "solid" look — matching `avatar_2`'s existing `DsAvatarVariant { soft, solid }` precedent (`*Surface`/`*Text` vs `*Ui`/`$contentOnBrand()`).

**Architecture:** Two independent enums added (`DsCalloutTone`, `DsNotificationTone`), a `tone` field added to each widget defaulting to `soft` (non-breaking), and each style resolver's variant switch nested under a new `tone` switch. Showcase specs updated to enumerate all variant × tone combinations explicitly (mirrors the recent `card_2` variant/tone showcase update).

**Tech Stack:** Dart, Flutter, `mix`/`remix` styling packages (`RemixCalloutStyler`, `BoxStyler`, `TextStyler`, `ColorToken`).

## Global Constraints

- No test suite exists in this repo (`ui` package or `example` app) — verification is via `dart analyze`/`flutter analyze` after each change, plus a final manual check that the catalog app builds and both showcases render all variant/tone combinations correctly.
- Default `tone` is `DsCalloutTone.soft` / `DsNotificationTone.soft` for both widgets — this exactly reproduces current behavior, so no existing caller's rendering changes.
- Solid tone reuses each color's existing `*Ui` token (already defined in `lib/src/theme/light/colors.dart`) paired with `$contentOnBrand()` (white) foreground — no new color tokens.
- Follow existing code comment conventions in both style resolvers (explain *why*, not *what*).

---

### Task 1: Add `DsCalloutTone` enum and thread it through `DsCallout`

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/callout_2/callout_2_variants.dart`
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/callout_2/callout_2.dart`
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/callout_2/callout_2_style_resolver.dart`

**Interfaces:**
- Consumes: nothing external.
- Produces: `enum DsCalloutTone { soft, solid }`; `DsCallout.tone` field (default `DsCalloutTone.soft`); `resolveDsCalloutStyle({required DsCalloutVariant variant, required DsCalloutTone tone, required DsCalloutSize size})` — consumed by Task 3 (showcase spec).

- [ ] **Step 1: Add the enum**

In `callout_2_variants.dart`, current content:
```dart
enum DsCalloutVariant { neutral, brand, positive, negative, warning }

enum DsCalloutSize { sm, md, lg }
```

Replace with:
```dart
enum DsCalloutVariant { neutral, brand, positive, negative, warning }

enum DsCalloutSize { sm, md, lg }

/// Emphasis level: `soft` tints the background with the color's `*Surface`
/// token and colors text/icon with `*Text` (today's only look); `solid`
/// fills the background with the color's saturated `*Ui` token and switches
/// text/icon to `$contentOnBrand()` (white) — same soft/solid pairing
/// `DsAvatarVariant` already uses.
enum DsCalloutTone { soft, solid }
```

- [ ] **Step 2: Add the `tone` field to `DsCallout`**

In `callout_2.dart`, replace:
```dart
  const DsCallout({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.variant = DsCalloutVariant.neutral,
    this.size = DsCalloutSize.md,
    this.style = const RemixCalloutStyler.create(),
    this.styleSpec,
  }) : assert(
         text != null || child != null,
         'Provide either text or child to DsCallout.',
       );
```

with:
```dart
  const DsCallout({
    super.key,
    this.text,
    this.icon,
    this.child,
    this.variant = DsCalloutVariant.neutral,
    this.tone = DsCalloutTone.soft,
    this.size = DsCalloutSize.md,
    this.style = const RemixCalloutStyler.create(),
    this.styleSpec,
  }) : assert(
         text != null || child != null,
         'Provide either text or child to DsCallout.',
       );
```

Then replace:
```dart
  /// Semantic color treatment — see [DsCalloutVariant].
  final DsCalloutVariant variant;

  /// Physical size — see [DsCalloutSize].
  final DsCalloutSize size;
```

with:
```dart
  /// Semantic color treatment — see [DsCalloutVariant].
  final DsCalloutVariant variant;

  /// Emphasis level — see [DsCalloutTone].
  final DsCalloutTone tone;

  /// Physical size — see [DsCalloutSize].
  final DsCalloutSize size;
```

Then replace:
```dart
    final resolvedStyle = resolveDsCalloutStyle(
      variant: variant,
      size: size,
    ).merge(style);
```

with:
```dart
    final resolvedStyle = resolveDsCalloutStyle(
      variant: variant,
      tone: tone,
      size: size,
    ).merge(style);
```

- [ ] **Step 3: Update the resolver to branch on `tone`**

In `callout_2_style_resolver.dart`, replace:
```dart
RemixCalloutStyler resolveDsCalloutStyle({
  required DsCalloutVariant variant,
  required DsCalloutSize size,
}) {
```

with:
```dart
RemixCalloutStyler resolveDsCalloutStyle({
  required DsCalloutVariant variant,
  required DsCalloutTone tone,
  required DsCalloutSize size,
}) {
```

Replace the `variantStyle` block:
```dart
  // Each variant pairs a semantic `*Surface` background with the matching
  // `*Text` foreground (shared across the icon and text via
  // `.foregroundColor()`), the same surface/text token pairing
  // `DsIconVariant` uses for its own neutral/brand/positive/negative/warning
  // set — kept in lockstep so an icon dropped into a callout with a matching
  // `DsIconVariant` looks consistent.
  final variantStyle = switch (variant) {
    DsCalloutVariant.neutral =>
      RemixCalloutStyler()
          .backgroundColor($neutralSurface())
          .foregroundColor($neutralText()),
    DsCalloutVariant.brand =>
      RemixCalloutStyler()
          .backgroundColor($brandSurface())
          .foregroundColor($brandText()),
    DsCalloutVariant.positive =>
      RemixCalloutStyler()
          .backgroundColor($positiveSurface())
          .foregroundColor($positiveText()),
    DsCalloutVariant.negative =>
      RemixCalloutStyler()
          .backgroundColor($negativeSurface())
          .foregroundColor($negativeText()),
    DsCalloutVariant.warning =>
      RemixCalloutStyler()
          .backgroundColor($warningSurface())
          .foregroundColor($warningText()),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

with:
```dart
  // Each variant pairs a semantic background with a matching foreground
  // (shared across the icon and text via `.foregroundColor()`). `soft` uses
  // `*Surface`/`*Text` — the same pairing `DsIconVariant` uses for its own
  // neutral/brand/positive/negative/warning set, kept in lockstep so an
  // icon dropped into a callout with a matching `DsIconVariant` looks
  // consistent. `solid` uses the saturated `*Ui` token with
  // `$contentOnBrand()` (white) text, the same soft/solid pairing
  // `DsAvatarVariant` already establishes.
  final variantStyle = switch (tone) {
    DsCalloutTone.soft => switch (variant) {
      DsCalloutVariant.neutral =>
        RemixCalloutStyler()
            .backgroundColor($neutralSurface())
            .foregroundColor($neutralText()),
      DsCalloutVariant.brand =>
        RemixCalloutStyler()
            .backgroundColor($brandSurface())
            .foregroundColor($brandText()),
      DsCalloutVariant.positive =>
        RemixCalloutStyler()
            .backgroundColor($positiveSurface())
            .foregroundColor($positiveText()),
      DsCalloutVariant.negative =>
        RemixCalloutStyler()
            .backgroundColor($negativeSurface())
            .foregroundColor($negativeText()),
      DsCalloutVariant.warning =>
        RemixCalloutStyler()
            .backgroundColor($warningSurface())
            .foregroundColor($warningText()),
    },
    DsCalloutTone.solid => switch (variant) {
      DsCalloutVariant.neutral =>
        RemixCalloutStyler()
            .backgroundColor($neutralUi())
            .foregroundColor($contentOnBrand()),
      DsCalloutVariant.brand =>
        RemixCalloutStyler()
            .backgroundColor($brandUi())
            .foregroundColor($contentOnBrand()),
      DsCalloutVariant.positive =>
        RemixCalloutStyler()
            .backgroundColor($positiveUi())
            .foregroundColor($contentOnBrand()),
      DsCalloutVariant.negative =>
        RemixCalloutStyler()
            .backgroundColor($negativeUi())
            .foregroundColor($contentOnBrand()),
      DsCalloutVariant.warning =>
        RemixCalloutStyler()
            .backgroundColor($warningUi())
            .foregroundColor($contentOnBrand()),
    },
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

- [ ] **Step 4: Run static analysis on the whole `callout_2` component**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/callout_2/`
Expected: No errors. (`$neutralUi`, `$brandUi`, `$positiveUi`, `$negativeUi`, `$warningUi`, `$contentOnBrand` are already imported transitively via `callout_2.dart`'s `import '../../theme/light/colors.dart';`.)

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/callout_2/
git commit -m "callout_2: add soft/solid tone axis"
```

---

### Task 2: Add `DsNotificationTone` enum and thread it through `DsNotification`

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/notification_2/notification_2_variants.dart`
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/notification_2/notification_2.dart`
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/notification_2/notification_2_style_resolver.dart`

**Interfaces:**
- Consumes: nothing external.
- Produces: `enum DsNotificationTone { soft, solid }`; `DsNotification.tone` field (default `DsNotificationTone.soft`); updated signatures `resolveDsNotificationContainerStyle({required DsNotificationVariant variant, required DsNotificationTone tone, required DsNotificationSize size})`, `resolveDsNotificationTitleStyle({required DsNotificationVariant variant, required DsNotificationTone tone, required DsNotificationSize size})`, `resolveDsNotificationTextStyle({required DsNotificationVariant variant, required DsNotificationTone tone, required DsNotificationSize size})`, `_resolveDsNotificationTextColor(DsNotificationVariant variant, DsNotificationTone tone)` — consumed by Task 3 (showcase spec).

- [ ] **Step 1: Add the enum**

In `notification_2_variants.dart`, current content:
```dart
enum DsNotificationVariant { neutral, brand, positive, negative, warning }

enum DsNotificationSize { sm, md, lg }
```

Replace with:
```dart
enum DsNotificationVariant { neutral, brand, positive, negative, warning }

enum DsNotificationSize { sm, md, lg }

/// Emphasis level — same soft/solid meaning as [DsCalloutTone]: `soft`
/// tints the container with the color's `*Surface` token and colors
/// title/text/leading-icon with `*Text` (today's only look); `solid` fills
/// the container with the color's saturated `*Ui` token and switches
/// title/text/leading-icon to `$contentOnBrand()` (white).
enum DsNotificationTone { soft, solid }
```

- [ ] **Step 2: Add the `tone` field and thread it through `build()`**

In `notification_2.dart`, replace:
```dart
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
```

with:
```dart
  const DsNotification({
    super.key,
    this.leading,
    this.title,
    required this.text,
    this.actions,
    this.variant = DsNotificationVariant.neutral,
    this.tone = DsNotificationTone.soft,
    this.size = DsNotificationSize.md,
    this.style,
    this.titleStyle,
    this.textStyle,
  });
```

Then replace:
```dart
  /// Semantic color treatment — see [DsNotificationVariant].
  final DsNotificationVariant variant;

  /// Physical size — see [DsNotificationSize].
  final DsNotificationSize size;
```

with:
```dart
  /// Semantic color treatment — see [DsNotificationVariant].
  final DsNotificationVariant variant;

  /// Emphasis level — see [DsNotificationTone].
  final DsNotificationTone tone;

  /// Physical size — see [DsNotificationSize].
  final DsNotificationSize size;
```

Then replace:
```dart
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
    final leadingColor = _resolveDsNotificationTextColor(variant);
```

with:
```dart
    final resolvedContainerStyle = resolveDsNotificationContainerStyle(
      variant: variant,
      tone: tone,
      size: size,
    ).merge(style);

    final resolvedTitleStyle = resolveDsNotificationTitleStyle(
      variant: variant,
      tone: tone,
      size: size,
    ).merge(titleStyle);

    final resolvedTextStyle = resolveDsNotificationTextStyle(
      variant: variant,
      tone: tone,
      size: size,
    ).merge(textStyle);

    final gap = resolveDsNotificationGap(context, size);
    final hasActions = actions != null && actions!.isNotEmpty;
    final leadingColor = _resolveDsNotificationTextColor(variant, tone);
```

- [ ] **Step 3: Update the resolver functions to branch on `tone`**

In `notification_2_style_resolver.dart`, replace the entire file contents:
```dart
part of 'notification_2.dart';

// Resolver functions for DsNotification. Split into container/title/text/gap
// (rather than one composite style, the way `resolveDsCalloutStyle` returns
// a single `RemixCalloutStyler`) because there is no composite Remix spec
// backing this hand-rolled component — see the class doc comment in
// notification_2.dart for why this isn't built on RemixCallout.

BoxStyler resolveDsNotificationContainerStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing012()),
    ),
    DsNotificationSize.md => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing016()),
    ),
    DsNotificationSize.lg => BoxStyler().padding(
      EdgeInsetsGeometryMix.all($spacing020()),
    ),
  };

  // `soft` tints with `*Surface` (today's only look); `solid` fills with the
  // saturated `*Ui` token — same soft/solid pairing `DsAvatarVariant`
  // already establishes, applied here to the container background instead
  // of an avatar's circle/square fill.
  final variantStyle = switch (tone) {
    DsNotificationTone.soft => switch (variant) {
      DsNotificationVariant.neutral => BoxStyler().color($neutralSurface()),
      DsNotificationVariant.brand => BoxStyler().color($brandSurface()),
      DsNotificationVariant.positive => BoxStyler().color($positiveSurface()),
      DsNotificationVariant.negative => BoxStyler().color($negativeSurface()),
      DsNotificationVariant.warning => BoxStyler().color($warningSurface()),
    },
    DsNotificationTone.solid => switch (variant) {
      DsNotificationVariant.neutral => BoxStyler().color($neutralUi()),
      DsNotificationVariant.brand => BoxStyler().color($brandUi()),
      DsNotificationVariant.positive => BoxStyler().color($positiveUi()),
      DsNotificationVariant.negative => BoxStyler().color($negativeUi()),
      DsNotificationVariant.warning => BoxStyler().color($warningUi()),
    },
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(sizeStyle)
      .merge(variantStyle);
}

TextStyler resolveDsNotificationTitleStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
  required DsNotificationSize size,
}) {
  return TextStyler(
    style: $headingH4.mix(),
  ).color(_resolveDsNotificationTextColor(variant, tone));
}

TextStyler resolveDsNotificationTextStyle({
  required DsNotificationVariant variant,
  required DsNotificationTone tone,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $bodySm.mix()),
    DsNotificationSize.md => TextStyler(style: $bodyMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $bodyLg.mix()),
  };

  return sizeStyle.color(_resolveDsNotificationTextColor(variant, tone));
}

/// Shared by [resolveDsNotificationTitleStyle] and
/// [resolveDsNotificationTextStyle] (and the leading icon color in
/// `notification_2.dart`'s `build()`) — all three use the same
/// variant/tone-paired foreground color, only type size differs between
/// title and text.
Color _resolveDsNotificationTextColor(
  DsNotificationVariant variant,
  DsNotificationTone tone,
) {
  return switch (tone) {
    DsNotificationTone.soft => switch (variant) {
      DsNotificationVariant.neutral => $neutralText(),
      DsNotificationVariant.brand => $brandText(),
      DsNotificationVariant.positive => $positiveText(),
      DsNotificationVariant.negative => $negativeText(),
      DsNotificationVariant.warning => $warningText(),
    },
    DsNotificationTone.solid => $contentOnBrand(),
  };
}

/// Gap between leading/title/text/actions in the hand-rolled Row/Column
/// layout. Needs [context] (unlike the resolvers above) because it feeds a
/// plain `SizedBox`/`Row.spacing`, not a `Styler`'s fluent chain — same
/// reasoning `toggle_group_2_style_resolver.dart`'s `_resolveGap` documents.
double resolveDsNotificationGap(BuildContext context, DsNotificationSize size) {
  return switch (size) {
    DsNotificationSize.sm => $spacing002.resolve(context),
    DsNotificationSize.md => $spacing004.resolve(context),
    DsNotificationSize.lg => $spacing006.resolve(context),
  };
}
```

(Note: `_resolveDsNotificationTextColor`'s `solid` branch returns `$contentOnBrand()` directly without a nested `variant` switch, since white applies uniformly regardless of color — unlike the container background, which must vary by color even under `solid`.)

- [ ] **Step 4: Run static analysis on the whole `notification_2` component**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/notification_2/`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/notification_2/
git commit -m "notification_2: add soft/solid tone axis"
```

---

### Task 3: Update both showcase specs to enumerate variant × tone combinations

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/example/lib/catalog/specs/callout_2_showcase_spec.dart`
- Modify: `/Users/eakl/dev/projects/roojai/example/lib/catalog/specs/notification_2_showcase_spec.dart`

**Interfaces:**
- Consumes: `DsCallout`, `DsCalloutVariant`, `DsCalloutTone` and `DsNotification`, `DsNotificationVariant`, `DsNotificationTone` from Tasks 1–2 (via `package:ui/ui.dart`, already imported in both files).
- Produces: nothing consumed elsewhere — both are leaf showcase files.

- [ ] **Step 1: Replace `callout_2_showcase_spec.dart`'s `variantsBuilder`**

Replace:
```dart
    variantsBuilder: () => DsCalloutVariant.values
        .map(
          (variant) => DsCallout(
            text: variant.name,
            icon: PhosphorIcons.info(),
            variant: variant,
          ),
        )
        .toList(),
```

with:
```dart
    // Each color has both a soft and solid tone, which collapse into one
    // `DsCalloutVariant.values` entry — list combinations explicitly
    // instead of mapping over the enum so solid tones are shown too.
    variantsBuilder: () => [
      for (final variant in DsCalloutVariant.values)
        for (final tone in DsCalloutTone.values)
          DsCallout(
            text: '${variant.name} (${tone.name})',
            icon: PhosphorIcons.info(),
            variant: variant,
            tone: tone,
          ),
    ],
```

- [ ] **Step 2: Replace `notification_2_showcase_spec.dart`'s `variantsBuilder`**

Replace:
```dart
    variantsBuilder: () => DsNotificationVariant.values
        .map(
          (variant) => DsNotification(
            text: variant.name,
            leading: Icon(PhosphorIcons.info()),
            variant: variant,
          ),
        )
        .toList(),
```

with:
```dart
    // Each color has both a soft and solid tone, which collapse into one
    // `DsNotificationVariant.values` entry — list combinations explicitly
    // instead of mapping over the enum so solid tones are shown too.
    variantsBuilder: () => [
      for (final variant in DsNotificationVariant.values)
        for (final tone in DsNotificationTone.values)
          DsNotification(
            text: '${variant.name} (${tone.name})',
            leading: Icon(PhosphorIcons.info()),
            variant: variant,
            tone: tone,
          ),
    ],
```

- [ ] **Step 3: Run static analysis on the example app**

Run: `cd /Users/eakl/dev/projects/roojai/example && dart analyze lib/catalog/specs/callout_2_showcase_spec.dart lib/catalog/specs/notification_2_showcase_spec.dart`
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/callout_2_showcase_spec.dart example/lib/catalog/specs/notification_2_showcase_spec.dart
git commit -m "callout_2/notification_2: show all variant/tone combinations in showcases"
```

---

### Task 4: Full-project analysis and manual catalog verification

**Files:** none (verification only)

**Interfaces:** none — final gate confirming Tasks 1–3 integrate cleanly.

- [ ] **Step 1: Run analysis across the whole `ui` package**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze`
Expected: No errors (pre-existing warnings/infos unrelated to this change are fine; zero errors, nothing new referencing `callout_2`, `notification_2`, `DsCalloutTone`, or `DsNotificationTone`).

- [ ] **Step 2: Run analysis across the example/catalog app**

Run: `cd /Users/eakl/dev/projects/roojai/example && dart analyze`
Expected: No errors.

- [ ] **Step 3: Launch the catalog app and visually verify both showcases**

Use the project's `run` skill (or `cd /Users/eakl/dev/projects/roojai/example && flutter run -d chrome`) to launch the catalog app, navigate to "Callout 2" and "Notification 2", and confirm:
- Both showcases' "Variants" sections show 10 entries each: `neutral (soft)`, `neutral (solid)`, `brand (soft)`, `brand (solid)`, `positive (soft)`, `positive (solid)`, `negative (soft)`, `negative (solid)`, `warning (soft)`, `warning (solid)`.
- Every `(soft)` entry looks identical to how that variant rendered before this change (tinted background, colored text/icon).
- Every `(solid)` entry shows a saturated background in the matching color with white text/icon.
- The "Sizes" and "States" sections still render using the new default `tone: soft` without error or visual regression.

- [ ] **Step 4: No commit needed for this task** (verification-only; if any issue is found, return to the relevant task above, fix, and commit there).

---

## Self-Review Notes

- **Spec coverage:** `DsCalloutTone` addition + `DsCallout.tone` field + resolver branching (Task 1), `DsNotificationTone` addition + `DsNotification.tone` field + all four resolver functions branching (Task 2), both showcase specs enumerating variant×tone (Task 3), full verification + manual catalog check (Task 4) — all spec sections covered, including the neutral-solid limitation (inherent in reusing `$neutralUi()`, no separate task needed since it's a documented token limitation, not a bug).
- **Placeholder scan:** no TBD/TODO; every step shows exact before/after code or an exact runnable command with expected output.
- **Type consistency:** `resolveDsCalloutStyle({required variant, required tone, required size})` in Task 1 matches the call site added in the same task. `resolveDsNotificationContainerStyle`/`resolveDsNotificationTitleStyle`/`resolveDsNotificationTextStyle`/`_resolveDsNotificationTextColor` signatures in Task 2 all consistently add `tone` and match their call sites in the same task's `notification_2.dart` edit. `DsCalloutTone`/`DsNotificationTone` values (`soft`, `solid`) used identically across Tasks 1, 2, and 3.
