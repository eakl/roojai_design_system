# card_2 Variant Trim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reshape `DsCard`'s `DsCardVariant` from `{ surface, elevated, ghost, bordered }` to `{ elevated, bordered, filled }`, with a new `DsCardTone { base, alternative, inverted }` parameter controlling `filled`'s background color.

**Architecture:** Two enums (`DsCardVariant`, `DsCardTone`) in `card_2_variants.dart`, a `tone` field added to the `DsCard` widget in `card_2.dart`, and updated switch logic in `card_2_style_resolver.dart`'s `resolveDsCardStyle`. The showcase spec is updated to enumerate all five visual permutations explicitly (since `filled` alone no longer shows its three tones via `DsCardVariant.values`).

**Tech Stack:** Dart, Flutter, `mix`/`remix` styling packages (`RemixCardStyler`, `ColorToken`).

## Global Constraints

- No test suite exists in this repo (`ui` package or `example` app) — verification is via `dart analyze`/`flutter analyze` after each change, plus a final manual check that the catalog app builds and the card showcase renders all 5 variant/tone combinations correctly.
- Follow existing code comment conventions in `card_2_style_resolver.dart` (explain *why*, not *what* — see existing comments on lines 3-8 and 32-35 of the current file for tone).
- `surface` and `ghost` are removed outright (breaking change) — no backward-compat shims, no deprecated re-exports. This package has no external consumers to protect (`publish_to: "none"`).
- Default `variant` becomes `DsCardVariant.filled`; default `tone` becomes `DsCardTone.base`. Combined, this exactly reproduces the old default (`DsCardVariant.surface`) appearance: `$surfaceDefault()` background, no border.

---

### Task 1: Update `DsCardVariant` and add `DsCardTone` enums

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/card_2/card_2_variants.dart`

**Interfaces:**
- Consumes: nothing (leaf file, no imports needed — plain enums).
- Produces: `enum DsCardVariant { elevated, bordered, filled }` and `enum DsCardTone { base, alternative, inverted }`, consumed by Task 2 (`card_2.dart`) and Task 3 (`card_2_style_resolver.dart`).

- [ ] **Step 1: Replace the file contents**

Current content (for reference, `card_2_variants.dart`):
```dart
enum DsCardSize { sm, md, lg }

enum DsCardVariant { surface, elevated, ghost, bordered };
```
(Note: the real current file has no trailing semicolon after the enum — see below for exact new content.)

Write the new file:
```dart
enum DsCardSize { sm, md, lg }

enum DsCardVariant { elevated, bordered, filled }

/// Background tone for [DsCardVariant.filled]; ignored for
/// [DsCardVariant.elevated] and [DsCardVariant.bordered].
enum DsCardTone { base, alternative, inverted }
```

- [ ] **Step 2: Run static analysis to confirm the file is syntactically valid**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/card_2/card_2_variants.dart`
Expected: Errors about `DsCardVariant`/`DsCardTone` being referenced with old names in `card_2.dart` and `card_2_style_resolver.dart` (those files haven't been updated yet — this is expected at this point, not a regression). No syntax errors in `card_2_variants.dart` itself.

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/card_2/card_2_variants.dart
git commit -m "card_2: trim DsCardVariant to elevated/bordered/filled, add DsCardTone"
```

---

### Task 2: Add `tone` field to `DsCard` widget

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/card_2/card_2.dart`

**Interfaces:**
- Consumes: `DsCardVariant`, `DsCardTone` from Task 1 (`card_2_variants.dart`, already imported via existing `import 'card_2_variants.dart';` on line 7).
- Produces: `DsCard.tone` field (type `DsCardTone`, default `DsCardTone.base`) and updated `DsCard.variant` default (`DsCardVariant.filled`), both passed into `resolveDsCardStyle(...)` for Task 3 to consume as named parameters `variant` and `tone`.

- [ ] **Step 1: Update the constructor and fields**

In `card_2.dart`, replace:
```dart
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    this.child,
    this.variant = DsCardVariant.surface,
    this.size = DsCardSize.md,
    this.style = const RemixCardStyler.create(),
    this.styleSpec,
  });

  /// The widget below this widget in the tree. Non-interactive container
  /// — same single-child constraint as [RemixCard] itself.
  final Widget? child;

  /// Visual treatment — see [DsCardVariant].
  final DsCardVariant variant;

  /// Physical size — see [DsCardSize]. Controls padding only; unlike
  /// [DsButton]/[DsInput], a card has no intrinsic height to vary.
  final DsCardSize size;
```

with:
```dart
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    this.child,
    this.variant = DsCardVariant.filled,
    this.tone = DsCardTone.base,
    this.size = DsCardSize.md,
    this.style = const RemixCardStyler.create(),
    this.styleSpec,
  });

  /// The widget below this widget in the tree. Non-interactive container
  /// — same single-child constraint as [RemixCard] itself.
  final Widget? child;

  /// Visual treatment — see [DsCardVariant].
  final DsCardVariant variant;

  /// Background tone, only meaningful when [variant] is
  /// [DsCardVariant.filled] — see [DsCardTone]. Ignored for
  /// [DsCardVariant.elevated] and [DsCardVariant.bordered].
  final DsCardTone tone;

  /// Physical size — see [DsCardSize]. Controls padding only; unlike
  /// [DsButton]/[DsInput], a card has no intrinsic height to vary.
  final DsCardSize size;
```

- [ ] **Step 2: Pass `tone` into style resolution**

Replace:
```dart
  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCardStyle(
      variant: variant,
      size: size,
    ).merge(style);
```

with:
```dart
  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsCardStyle(
      variant: variant,
      tone: tone,
      size: size,
    ).merge(style);
```

- [ ] **Step 3: Update the class doc comment's stale "varies along variant/size" note**

Replace:
```dart
/// no interaction states (hover/press/focus/disabled) to resolve — it only
/// varies along [variant] (semantic surface treatment) and [size]
/// (padding).
```

with:
```dart
/// no interaction states (hover/press/focus/disabled) to resolve — it only
/// varies along [variant] (semantic surface treatment), [tone] (background
/// color when filled), and [size] (padding).
```

- [ ] **Step 4: Run static analysis**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/card_2/card_2.dart`
Expected: Errors only about `resolveDsCardStyle` not yet accepting a `tone` parameter and switch statements in `card_2_style_resolver.dart` not covering `DsCardVariant.filled`/missing `DsCardTone` cases (Task 3 not done yet — expected at this point). No errors in `card_2.dart` itself.

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/card_2/card_2.dart
git commit -m "card_2: add tone field, default variant to filled/base"
```

---

### Task 3: Update style resolution for the new variant/tone shape

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/lib/src/components/card_2/card_2_style_resolver.dart`

**Interfaces:**
- Consumes: `DsCardVariant`, `DsCardTone` from Task 1; called from Task 2's `card_2.dart` `build()` with `variant:`, `tone:`, `size:` named args.
- Produces: `RemixCardStyler resolveDsCardStyle({required DsCardVariant variant, required DsCardTone tone, required DsCardSize size})` — same public shape other than the added `tone` parameter, so no other files depend on internals here.

- [ ] **Step 1: Update the function signature and variant switch**

Replace:
```dart
RemixCardStyler resolveDsCardStyle({
  required DsCardVariant variant,
  required DsCardSize size,
}) {
  final baseStyle = RemixCardStyler().borderRadiusAll($radius008());

  final sizeStyle = switch (size) {
    DsCardSize.sm =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsCardSize.md =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsCardSize.lg =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  const transparent = Color(0x00000000);

  // `surface` has a background + `$borderDefault` border; `elevated`
  // trades the border for a shadow (having both would double the edge
  // treatment); `ghost` has neither, matching Fortal's ghost; `bordered`
  // has no background but an emphasized `$borderStrong` border.
  final variantStyle = switch (variant) {
    DsCardVariant.surface => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .borderAll(color: $borderDefault(), width: 1),
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.ghost => RemixCardStyler().backgroundColor(transparent),
    // Transparent background with an emphasized border — no fill to help
    // it read visually, so it uses $borderStrong (vs. `surface`'s
    // $borderDefault) rather than reusing surface's subtler border color.
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

with:
```dart
RemixCardStyler resolveDsCardStyle({
  required DsCardVariant variant,
  required DsCardTone tone,
  required DsCardSize size,
}) {
  final baseStyle = RemixCardStyler().borderRadiusAll($radius008());

  final sizeStyle = switch (size) {
    DsCardSize.sm =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsCardSize.md =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsCardSize.lg =>
      RemixCardStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  const transparent = Color(0x00000000);

  // `elevated` trades a border for a shadow (having both would double the
  // edge treatment); `bordered` has no background but an emphasized
  // `$borderStrong` border; `filled` has a background (picked by [tone])
  // and no border in any tone, matching badge_2's borderless
  // primary/secondary precedent.
  final variantStyle = switch (variant) {
    DsCardVariant.elevated => RemixCardStyler()
        .backgroundColor($surfaceDefault())
        .shadow(_cardElevatedShadow),
    DsCardVariant.bordered => RemixCardStyler()
        .backgroundColor(transparent)
        .borderAll(color: $borderStrong(), width: 1),
    DsCardVariant.filled => RemixCardStyler().backgroundColor(
        switch (tone) {
          // `base` reproduces the old `surface` variant's background
          // exactly, so the new default (filled + base) matches the old
          // default (surface) look.
          DsCardTone.base => $surfaceDefault(),
          DsCardTone.alternative => $surfaceAlternative(),
          DsCardTone.inverted => $surfaceInverted(),
        },
      ),
  };

  return baseStyle.merge(sizeStyle).merge(variantStyle);
}
```

- [ ] **Step 2: Run static analysis on the whole `card_2` component**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze lib/src/components/card_2/`
Expected: No errors. (`$surfaceAlternative` and `$surfaceInverted` are already imported transitively via `card_2.dart`'s `import '../../theme/light/colors.dart';` on line 4, since `card_2_style_resolver.dart` is `part of 'card_2.dart'`.)

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/card_2/card_2_style_resolver.dart
git commit -m "card_2: resolve filled variant background from tone"
```

---

### Task 4: Update the showcase spec to enumerate all variant/tone combinations

**Files:**
- Modify: `/Users/eakl/dev/projects/roojai/example/lib/catalog/specs/card_2_showcase_spec.dart`

**Interfaces:**
- Consumes: `DsCard`, `DsCardVariant`, `DsCardTone`, `DsCardSize` from `package:ui/ui.dart` (already imported on line 2); `ComponentShowcaseSpec` from `../component_showcase_spec.dart` (already imported).
- Produces: nothing consumed elsewhere — this is a leaf showcase file.

- [ ] **Step 1: Replace `variantsBuilder`**

Replace:
```dart
    variantsBuilder: () => DsCardVariant.values
        .map(
          (variant) => DsCard(
            variant: variant,
            child: Text(variant.name),
          ),
        )
        .toList(),
```

with:
```dart
    // `filled` has three tones (base/alternative/inverted) that collapse
    // into one `DsCardVariant.values` entry, so list combinations
    // explicitly instead of mapping over the enum — otherwise the
    // alternative/inverted tones would never be shown.
    variantsBuilder: () => [
      DsCard(
        variant: DsCardVariant.elevated,
        child: const Text('elevated'),
      ),
      DsCard(
        variant: DsCardVariant.bordered,
        child: const Text('bordered'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.base,
        child: const Text('filled (base)'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.alternative,
        child: const Text('filled (alternative)'),
      ),
      DsCard(
        variant: DsCardVariant.filled,
        tone: DsCardTone.inverted,
        child: const Text('filled (inverted)'),
      ),
    ],
```

- [ ] **Step 2: Run static analysis on the example app**

Run: `cd /Users/eakl/dev/projects/roojai/example && dart analyze lib/catalog/specs/card_2_showcase_spec.dart`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/card_2_showcase_spec.dart
git commit -m "card_2: show all variant/tone combinations in showcase spec"
```

---

### Task 5: Full-project analysis and manual verification

**Files:** none (verification only)

**Interfaces:** none — final gate confirming Tasks 1–4 integrate cleanly.

- [ ] **Step 1: Run analysis across the whole `ui` package**

Run: `cd /Users/eakl/dev/projects/roojai && dart analyze`
Expected: No errors (existing pre-existing warnings/infos unrelated to `card_2` are fine, but zero errors and nothing new referencing `card_2`, `DsCardVariant`, `DsCardTone`, or `surface`/`ghost`).

- [ ] **Step 2: Run analysis across the example/catalog app**

Run: `cd /Users/eakl/dev/projects/roojai/example && dart analyze`
Expected: No errors.

- [ ] **Step 3: Confirm no other file references the removed `surface`/`ghost` variants**

Run: `cd /Users/eakl/dev/projects/roojai && grep -rn "DsCardVariant.surface\|DsCardVariant.ghost" lib example`
Expected: No output (empty result).

- [ ] **Step 4: Launch the catalog app and visually verify the card_2 showcase**

Use the project's `run` skill (or `cd /Users/eakl/dev/projects/roojai/example && flutter run -d chrome` / a connected device) to launch the storybook/catalog app, navigate to the "Card 2" showcase, and confirm:
- 5 cards render under the variants section: `elevated`, `bordered`, `filled (base)`, `filled (alternative)`, `filled (inverted)`.
- `elevated` shows a shadow, no border.
- `bordered` shows a `$borderStrong` border, transparent background.
- `filled (base)` shows the same background as the old default `surface` variant did, no border.
- `filled (alternative)` shows a visibly greyer background than base, no border.
- `filled (inverted)` shows a dark/inverted background, no border.
- The `sizes` section (sm/md/lg) still renders using the new default `variant`/`tone` without error.

- [ ] **Step 5: No commit needed for this task** (verification-only; if any issue is found, return to the relevant task above, fix, and commit there).

---

## Self-Review Notes

- **Spec coverage:** `DsCardVariant` trim (Task 1), `DsCardTone` addition (Task 1), `DsCard.tone` field + new defaults (Task 2), style resolution for `filled`'s three tones (Task 3), showcase spec update (Task 4) — all five spec sections covered. Final verification (Task 5) confirms no stray `surface`/`ghost` references remain anywhere in the repo.
- **Placeholder scan:** no TBD/TODO; every step shows exact before/after code or an exact runnable command with expected output.
- **Type consistency:** `resolveDsCardStyle({required DsCardVariant variant, required DsCardTone tone, required DsCardSize size})` in Task 3 matches the call site `resolveDsCardStyle(variant: variant, tone: tone, size: size)` added in Task 2. `DsCard.tone` type (`DsCardTone`, default `DsCardTone.base`) matches enum defined in Task 1. `DsCardVariant.filled` and `DsCardTone.{base,alternative,inverted}` are used identically across Tasks 2, 3, and 4.
