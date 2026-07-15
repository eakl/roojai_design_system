# dialog_2 (DsDialog) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `DsDialog` + `showDsDialog()` to the `ui` package as a thin wrapper around `remix`'s `RemixDialog`/`showRemixDialog`, following the file structure and conventions of `button_2`/`input_2`, and register it in the example catalog app.

**Architecture:** One new component directory `lib/src/components/dialog_2/` with a widget file (`DsDialog` + `showDsDialog`) and a `part`-file style resolver (`resolveDsDialogStyle()`), exported from `lib/ui.dart`. One new catalog spec file wired into `example/lib/catalog/component_registry.dart`.

**Tech Stack:** Flutter (fvm-pinned `3.41.9`), Dart `3.11.5`, `mix: ^2.1.0`, `remix: ^0.2.0` (unchanged — see spec's "Remix version constraint" section for why this task does not touch the `remix` dependency).

## Global Constraints

- `remix` stays pinned at `^0.2.0` (resolves to `0.2.0`) — do not modify `pubspec.yaml`'s `remix`/`mix`/SDK constraints as part of this plan.
- No `DsAlertDialog`/`showDsAlertDialog` — out of scope per the spec.
- No `dialog_2_variants.dart` file and no `DsDialogSize`/`DsDialogVariant` enum — there is no size/variant axis.
- Follow `button_2`/`input_2`'s file-header comment convention (`part of`, explaining why the split exists) and doc-comment style (`///` on every public class/member).
- This package has no `test/` directory and no widget-test setup anywhere in the repo — verification is via `fvm flutter analyze` (static analysis) plus interactively running the example catalog app, matching the caveat already recorded in `button_2`'s and `input_2`'s design specs ("verified interactively in the running catalog app").

---

### Task 1: `DsDialog` widget + style resolver

**Files:**
- Create: `lib/src/components/dialog_2/dialog_2.dart`
- Create: `lib/src/components/dialog_2/dialog_2_style_resolver.dart`
- Modify: `lib/ui.dart:43` (insert dialog_2 export alphabetically, between `checkbox`-related comments and `icon_2`, matching the existing alphabetical-by-directory-name ordering — i.e. right before the `icon_2` export block)

**Interfaces:**
- Consumes: `$radius008` (`lib/src/tokens/semantic/radius.dart`), `$surfaceDefault`/`$contentPrimary`/`$contentSecondary` (`lib/src/tokens/semantic/colors.dart`), `$labelLg`/`$bodyMd` (`lib/src/tokens/semantic/typography.dart`), `$spacing008`/`$spacing016`/`$spacing020` (`lib/src/tokens/semantic/spacing.dart`) — all already defined, no changes needed to any token file.
- Produces: `DsDialog` (widget, constructor params `child`/`title`/`description`/`actions`/`modal`/`semanticLabel`/`style`/`styleSpec`), `showDsDialog<T>()` (top-level function), `resolveDsDialogStyle()` (top-level function returning `RemixDialogStyle`, no parameters). Task 2's catalog spec consumes all three by name.

- [ ] **Step 1: Write `dialog_2_style_resolver.dart`**

```dart
part of 'dialog_2.dart';

// AppElevation.level3's concrete shadow, inlined as a literal — Mix's
// BoxDecorationMix.boxShadow (and RemixDialogStyle.shadow, which delegates
// to it) only accepts `List<BoxShadowMix>`/`BoxShadowMix`, with no way to
// feed in a `BoxShadowToken` (`MixToken<List<BoxShadow>>`) token reference
// directly. Same class of limitation button_2's resolver hit with
// Curve/Duration token refs — falls back to a literal matching
// `AppElevation.level3` (lib/src/tokens/primitives/elevation.dart) until
// Mix supports resolving this token type outside of a theme lookup.
final _dialogShadow = BoxShadowMix(
  color: const Color(0x1F000000),
  offset: const Offset(0, 4),
  blurRadius: 12,
);

RemixDialogStyle resolveDsDialogStyle() {
  return RemixDialogStyle(
    title: TextStyler(style: $labelLg.mix()).color($contentPrimary()),
    description: TextStyler(
      style: $bodyMd.mix(),
    ).color($contentSecondary()),
    actions: FlexBoxStyler()
        .direction(Axis.horizontal)
        .mainAxisAlignment(MainAxisAlignment.end)
        .spacing($spacing008())
        .padding(EdgeInsetsGeometryMix.only(top: $spacing016())),
  )
      .borderRadiusAll($radius008())
      .backgroundColor($surfaceDefault())
      .padding(EdgeInsetsGeometryMix.all($spacing020()))
      .shadow(_dialogShadow);
}
```

- [ ] **Step 2: Write `dialog_2.dart`**

```dart
import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';

// The `resolveDsDialogStyle` function consumed by `build()` below lives in
// dialog_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsDialog while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'dialog_2_style_resolver.dart';

/// Shows a [DsDialog] (or any widget built by [builder]) as a modal route.
///
/// Thin wrapper around `remix`'s `showRemixDialog`, forwarding every param
/// unchanged. `RemixDialog` only renders correctly inside
/// `showRemixDialog`'s `MixScope`-wrapped route builder, so this is the
/// supported way to present a [DsDialog] — constructing one directly and
/// pushing it via `Navigator`/`showDialog` bypasses that scope.
Future<T?> showDsDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  Duration transitionDuration = const Duration(milliseconds: 400),
  RouteTransitionsBuilder? transitionBuilder,
  bool requestFocus = true,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  return showRemixDialog<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    transitionDuration: transitionDuration,
    transitionBuilder: transitionBuilder,
    requestFocus: requestFocus,
    traversalEdgeBehavior: traversalEdgeBehavior,
  );
}

/// A modal dialog built on top of the `remix` package's [RemixDialog],
/// styled through the design system's Mix semantic tokens.
///
/// Unlike [DsButton]/[DsInput], there is no legacy hand-rolled `Dialog` this
/// replaces — this is a new component. Must be shown via [showDsDialog] (or
/// `showRemixDialog` directly), not pushed as a standalone route — see
/// [showDsDialog]'s doc comment.
///
/// There is no `DsDialogSize`/`DsDialogVariant` — `RemixDialog` itself has
/// no size prop (only a `.size(width, height)` style escape hatch), and
/// there is no legacy component to carry a variant axis forward from. See
/// `docs/superpowers/specs/2026-07-16-dialog-2-component-design.md`.
class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    this.child,
    this.title,
    this.description,
    this.actions,
    this.modal = true,
    this.semanticLabel,
    this.style = const RemixDialogStyle.create(),
    this.styleSpec,
  }) : assert(
         child != null || title != null || description != null,
         'Either child, title, or description must be provided',
       );

  /// Custom content widget. When set, overrides the default
  /// [title]/[description]/[actions] composition entirely.
  final Widget? child;

  /// Dialog title text, rendered above [description].
  final String? title;

  /// Dialog description/body text, rendered below [title].
  final String? description;

  /// Action buttons rendered in a trailing-aligned row below
  /// [description]. Typically [DsButton]s.
  final List<Widget>? actions;

  /// Whether to block interaction with content behind the dialog.
  final bool modal;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [title] when null (same fallback [RemixDialog] applies).
  final String? semanticLabel;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsDialogStyle]'s output).
  final RemixDialogStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixDialogSpec] directly, bypassing style resolution entirely.
  final RemixDialogSpec? styleSpec;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsDialogStyle().merge(style);

    return RemixDialog(
      title: title,
      description: description,
      actions: actions,
      modal: modal,
      semanticLabel: semanticLabel,
      style: resolvedStyle,
      child: child,
    );
  }
}
```

- [ ] **Step 3: Add the `lib/ui.dart` export**

In `lib/ui.dart`, insert immediately before the existing `// Components.` section's `export 'src/components/icon_2/icon.dart';` line:

```dart
export 'src/components/dialog_2/dialog_2.dart';
```

(No second export line — unlike `button_2`/`input_2`, there is no `dialog_2_variants.dart` to export.)

- [ ] **Step 4: Run static analysis**

Run: `cd /Users/eakl/dev/projects/roojai && fvm flutter analyze lib/src/components/dialog_2 lib/ui.dart`
Expected: `No issues found!`

If it reports unresolved-method/unresolved-getter errors on `RemixDialogStyle`, `TextStyler`, `FlexBoxStyler`, or `EdgeInsetsGeometryMix`, re-check the corresponding class in the installed packages before changing anything:
- `~/.pub-cache/hosted/pub.dev/remix-0.2.0/lib/src/components/dialog/dialog_style.dart` for `RemixDialogStyle`
- `~/.pub-cache/hosted/pub.dev/mix-2.1.0/lib/src/specs/text/text_spec.g.dart` for `TextStyler`
- `~/.pub-cache/hosted/pub.dev/mix-2.1.0/lib/src/specs/flexbox/flexbox_spec.g.dart` for `FlexBoxStyler`
- `~/.pub-cache/hosted/pub.dev/mix-2.1.0/lib/src/properties/layout/edge_insets_geometry_mix.dart` for `EdgeInsetsGeometryMix`

- [ ] **Step 5: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add lib/src/components/dialog_2/dialog_2.dart lib/src/components/dialog_2/dialog_2_style_resolver.dart lib/ui.dart
git commit -m "feat(dialog_2): add DsDialog widget and style resolver"
```

---

### Task 2: Catalog showcase spec + registry registration

**Files:**
- Create: `example/lib/catalog/specs/dialog_2_showcase_spec.dart`
- Modify: `example/lib/catalog/component_registry.dart` (add import + registry entry, alphabetically between `Button 2` and `Icon 2`)

**Interfaces:**
- Consumes: `DsDialog`, `showDsDialog` (Task 1, via `package:ui/ui.dart`), `DsButton`/`DsButtonVariant` (already exported from `package:ui/ui.dart`), `ComponentShowcaseSpec` (`example/lib/catalog/component_showcase_spec.dart`, constructor takes `title` + optional `variantsBuilder`/`sizesBuilder`/`statesBuilder`, each `List<Widget> Function()?`).
- Produces: `buildDialog2ShowcaseSpec()` (top-level function returning `ComponentShowcaseSpec`), imported and registered by name in `component_registry.dart`.

- [ ] **Step 1: Write `dialog_2_showcase_spec.dart`**

Each `statesBuilder` entry is a `DsButton` trigger wrapped in a `Builder` — `statesBuilder` is called with no arguments (see `component_showcase_spec.dart`), so there is no ambient `BuildContext` at construction time; each trigger widget must obtain its own via `Builder` before calling `showDsDialog`.

```dart
import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildDialog2ShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Dialog 2',
    // No variantsBuilder/sizesBuilder — dialog_2 has no variant or size
    // axis (see the component's design spec).
    statesBuilder: () => [
      Builder(
        builder: (context) => DsButton(
          label: 'title + description + actions',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => DsDialog(
              title: 'Delete item',
              description:
                  'Are you sure you want to delete this item? This '
                  'action cannot be undone.',
              actions: [
                DsButton(
                  label: 'Cancel',
                  variant: DsButtonVariant.ghost,
                  onPressed: () => Navigator.pop(context),
                ),
                DsButton(
                  label: 'Delete',
                  variant: DsButtonVariant.destructive,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'custom child',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => const DsDialog(
              child: SizedBox(
                width: 240,
                child: Text('Fully custom dialog content goes here.'),
              ),
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'non-modal',
          onPressed: () => showDsDialog<void>(
            context: context,
            builder: (context) => DsDialog(
              modal: false,
              title: 'Non-modal dialog',
              description: 'Background content stays interactive.',
              actions: [
                DsButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
      Builder(
        builder: (context) => DsButton(
          label: 'non-dismissible',
          onPressed: () => showDsDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => DsDialog(
              title: 'Non-dismissible',
              description: 'Tapping the barrier will not close this.',
              actions: [
                DsButton(
                  label: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 2: Register in `component_registry.dart`**

Add the import alphabetically among the existing `specs/*_showcase_spec.dart` imports (between `button_2_showcase_spec.dart` and `icon_2_showcase_spec.dart`):

```dart
import 'specs/dialog_2_showcase_spec.dart';
```

Add the registry entry alphabetically among the existing map entries (between `'Button 2'` and `'Icon 2'`):

```dart
  'Dialog 2': buildDialog2ShowcaseSpec,
```

- [ ] **Step 3: Run static analysis**

Run: `cd /Users/eakl/dev/projects/roojai/example && fvm flutter analyze lib/catalog`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
cd /Users/eakl/dev/projects/roojai
git add example/lib/catalog/specs/dialog_2_showcase_spec.dart example/lib/catalog/component_registry.dart
git commit -m "feat(dialog_2): add catalog showcase spec"
```

---

### Task 3: Interactive verification in the running catalog app

**Files:** None (manual verification only — no code changes).

**Interfaces:** None produced. Consumes the fully wired-up catalog app from Tasks 1–2.

- [ ] **Step 1: Launch the example app**

Run: `cd /Users/eakl/dev/projects/roojai/example && fvm flutter run -d macos`

Wait for it to build and open the macOS app window.

- [ ] **Step 2: Navigate to the Dialog 2 showcase**

In the running app, go to the catalog home page and open "Dialog 2".

Expected: a "States" section with four buttons: "title + description + actions", "custom child", "non-modal", "non-dismissible".

- [ ] **Step 3: Verify each trigger**

- Tap "title + description + actions": a dialog opens showing the title, description, and two right-aligned action buttons (Cancel/Delete). Tap Cancel or Delete — dialog closes. Reopen and tap outside the dialog (the barrier) — dialog closes (barrier-dismissible by default).
- Tap "custom child": a dialog opens showing only the custom text content, no title/description/action-row chrome. Tap the barrier to close.
- Tap "non-modal": a dialog opens; confirm content behind it remains tappable/interactive while the dialog is open. Close via its Close button.
- Tap "non-dismissible": a dialog opens; tap the barrier — it must **not** close. Close it via its own Close button instead.

Expected: all four behave as described, with no layout overflow/clipping and dialog styling (rounded corners, background, shadow, right-aligned actions) visually consistent with `button_2`/`input_2`'s existing look (rounded `$radius008` corners, `$surfaceDefault` background).

- [ ] **Step 4: Stop the app**

Press `q` in the terminal running `flutter run`, or close the app window.

No commit for this task — it's verification only, not a code change.
