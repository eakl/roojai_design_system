# `dialog_2` (`DsDialog`) design

## Context

The design system is migrating components onto `remix`/`mix`, following the
pattern established by `button_2` (`DsButton` wrapping `RemixButton`) and
`input_2` (`DsInput` wrapping `RemixTextField`). This spec covers `dialog_2`
(`DsDialog`), a thin wrapper around `remix`'s `RemixDialog`/`showRemixDialog`,
for modal-overlay use cases (confirmations, compact forms, custom modal
content). There is no legacy `dialog` component in this codebase — this is a
new component, not a migration.

## Remix version constraint

The docs at https://docs.page/btwld/remix/components/dialog also describe
`showRemixAlertDialog()`, a stricter variant (non-dismissible barrier,
required `semanticLabel`, escape/back dismiss with a null result) intended
for destructive-action confirmations. That function **does not exist** in
the `remix` version currently pinned by this repo (`remix: ^0.2.0`,
resolving to `0.2.0` — confirmed by grepping the installed package source).
It ships starting in `remix: 1.0.0-beta.1`, which:

- Requires Dart SDK `>=3.12.0` / Flutter `>=3.44.0`. This repo is currently
  pinned via `fvm` to Flutter `3.41.9` (Dart `3.11.5`), below that floor.
- Is a sweeping breaking release: every fluent style builder is renamed
  `RemixXStyle` → `RemixXStyler` (no deprecated aliases), plus unrelated
  breaking changes to `RemixSelect`, `RemixSlider`, `RemixButton.onPressed`
  nullability, `RemixAvatar`/`RemixBadge` field renames, and more. Adopting
  it would require migrating all 14 existing `_2` components, not just
  `dialog_2`.

Per discussion, that upgrade is out of scope here — it's a separate,
deliberate toolchain + migration project. **`dialog_2` ships on the current
`remix: 0.2.0` and covers only the base dialog** (`RemixDialog`/
`showRemixDialog`). Alert-dialog semantics are dropped from this pass;
revisit either as part of a future `remix` 1.0.0 migration or as a
hand-rolled addition once there's a concrete caller.

## File structure

Mirrors `button_2`/`input_2`, minus a variants file (no enum axis — see
below):

```
lib/src/components/dialog_2/
  dialog_2.dart                 — DsDialog widget + showDsDialog() + doc comments
  dialog_2_style_resolver.dart  — part of dialog_2.dart; resolveDsDialogStyle()
```

No `dialog_2_variants.dart` — there is no `DsDialogSize` or `DsDialogVariant`
enum. `RemixDialog` itself has no built-in size prop (only a `.size(width,
height)` style escape hatch), and there is no legacy `Dialog` component to
carry forward a variant axis from — same reasoning `input_2` used to skip a
variant enum. Callers needing fixed dimensions use `style`.

## `DsDialog` widget API

```dart
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
  }) : assert(
         child != null || title != null || description != null,
         'Either child, title, or description must be provided',
       );
}
```

- A thin wrapper delegating to `RemixDialog` for all overlay mechanics
  (focus, semantics, barrier) — same relationship `DsButton` has to
  `RemixButton`. Props are `RemixDialog`'s full set as-is (small surface,
  no need to curate a subset the way `DsInput` did for `RemixTextField`).
- `child`/`title`/`description`/`actions` and the constructor assert are
  forwarded/mirrored exactly as `RemixDialog` defines them: `child`
  overrides default title/description/actions composition; at least one of
  the three must be provided.
- `modal` and `semanticLabel` pass straight through.
- `style` is the escape hatch, same convention as `DsButton`/`DsInput`.
  Unlike `RemixButton`/`RemixTextField`, `RemixDialog` has no `styleSpec`
  parameter to bypass style resolution with, so `DsDialog` doesn't expose
  one either.

## `showDsDialog<T>()`

```dart
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
```

A pass-through wrapper around `showRemixDialog`, exported so callers reach
for one `ds`-prefixed entry point instead of mixing `remix` and `ui`
imports. `RemixDialog` only renders correctly inside `showRemixDialog`'s
`MixScope`-wrapped route builder, so without this helper there'd be no
ergonomic way to actually present a `DsDialog`. Lives in `dialog_2.dart`
(not a separate part file — it's a short function, not the container of
a widget's implementation the way `dialog_2_style_resolver.dart` is).

## Style resolver (`dialog_2_style_resolver.dart`)

One `resolveDsDialogStyle()` entry point, no parameters — there's no
size/variant axis to switch on, so this composes a single fixed style
(mirrors `resolveDsInputStyle`'s base-only composition, minus even the size
fragment):

```dart
// AppElevation.level3's concrete shadow, inlined as a literal — Mix's
// BoxDecorationMix.boxShadow (and RemixDialogStyle.shadow, which delegates
// to it) only accepts `List<BoxShadowMix>`/`BoxShadowMix`, with no way to
// feed in a `BoxShadowToken` (`MixToken<List<BoxShadow>>`) token reference
// directly. Same class of limitation button_2's resolver hit with
// Curve/Duration token refs — falls back to a literal matching
// `AppElevation.level3` until Mix supports resolving this token type
// outside of a theme lookup.
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

Notes:

- `$radius008` matches `DsButton`/`DsInput`'s corner radius for visual
  consistency across the DS.
- `title`/`description`/`actions` are passed as `RemixDialogStyle`
  constructor args (not fluent `.title()`/`.description()`/`.actions()`
  calls) — `RemixDialogStyle` only exposes those three fields via its
  constructor, mirroring how `resolveDsInputStyle` sets `text`/`hintText`/
  `helperText`/`label` on `RemixTextFieldStyle`.
- The dialog's shadow is meant to visually separate it from the barrier
  behind it, at the same visual weight as `AppElevation.level3`
  (`tokens/primitives/elevation.dart`) — but it's expressed as an inlined
  `BoxShadowMix` literal, not a `$elevationLevel3` token reference. Mix's
  `BoxDecorationMix.boxShadow` (which `RemixDialogStyle.shadow()` delegates
  into) only accepts `List<BoxShadowMix>`/`BoxShadowMix` values, with no
  path to resolve a `BoxShadowToken` (`MixToken<List<BoxShadow>>`) inline —
  the same class of limitation `button_2`'s resolver hit with `Curve`/
  `Duration` token refs (see that resolver's own comment). This remains
  `dialog_2`'s first (attempted) use of the elevation token set in a `_2`
  component; a true token reference can replace the literal once Mix
  supports resolving this token type outside of a theme lookup.
- `title`/`description` use the same `$labelLg`/`$bodyMd` typography tokens
  and `$contentPrimary`/`$contentSecondary` color tokens already used
  elsewhere in the DS (e.g. `button_2`'s `$labelLg` label styling,
  `input_2`'s `$contentSecondary`-adjacent muted content tokens).
- `actions` lays out as a trailing-aligned horizontal row (matches the
  Remix doc's example: cancel/confirm buttons right-aligned in the footer).
- No `disabled`/`error`/interactive state fragment — dialogs have no such
  states; `modal`/dismissal behavior is controlled by `showDsDialog`'s
  `barrierDismissible`, not by style.

## Catalog registration

Add `example/lib/catalog/specs/dialog_2_showcase_spec.dart`, mirroring
`button_2_showcase_spec.dart`/`input_2_showcase_spec.dart`'s structure, but
since a dialog only renders when shown (not as a static list of instances
like a button/input), its `statesBuilder` entries are `DsButton`s that call
`showDsDialog` on tap:

- `sizesBuilder`/`variantsBuilder`: omitted — no axes to enumerate.
- `statesBuilder`: one trigger button per scenario —
  - "title + description + actions" (the default composed layout, two
    `DsButton` actions: Cancel / Confirm)
  - "custom child" (a `DsDialog(child: ...)` with arbitrary content,
    bypassing title/description/actions composition)
  - "non-modal" (`modal: false`)
  - "non-dismissible" (`showDsDialog(barrierDismissible: false, ...)`,
    demonstrating the barrier-tap-to-dismiss opt-out that `DsAlertDialog`
    would otherwise encode by default, until that component exists)
- Focus/hover/barrier-tap behavior is transient and Naked-driven; verified
  interactively in the running catalog app, same caveat noted in the
  button/input specs.

Register the new spec in `example/lib/catalog/component_registry.dart`
(alphabetically, `'Dialog 2': buildDialog2ShowcaseSpec`), and export
`dialog_2/dialog_2.dart` from `lib/ui.dart` (single line — no variants file
to export), same pattern as `button_2`/`input_2`.

## Out of scope

- `DsAlertDialog`/`showDsAlertDialog` — blocked on the `remix` 1.0.0
  upgrade (or a hand-rolled implementation) per the version-constraint
  section above.
- `DsDialogSize`/`DsDialogVariant` enums — no precedent from a legacy
  `Dialog`, and `RemixDialog` itself has no size prop; single style only,
  `style` covers fixed-dimension cases.
