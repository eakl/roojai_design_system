# `notification_2` (`DsNotification`) design

## Context

`TODO.md`'s "Callout" entry asks for three things `callout_2`'s current
`DsCallout` (built on `remix`'s `RemixCallout`) can't support: a leading
slot that accepts either a bare icon or an `IconContainer`, an optional
title, and an optional bottom-right-aligned button group — plus top
alignment between the leading slot and the text column.

`RemixCalloutSpec` only carries three fields (`container`, `text`, `icon`)
and `RemixCallout`'s own `build()` only ever renders a flat `Row` of
`[icon, text]` (see `remix-0.2.0/lib/src/components/callout/callout_widget.dart`).
There is no title slot, no actions slot, and its `icon` param is
`IconData?`, not `Widget?`. Extending it to cover the new requirements
means bypassing its built-in icon/text rendering entirely and driving the
whole layout by hand — at which point wrapping `RemixCallout` adds no
value over building directly on Mix's `Box`.

Per discussion, `callout_2`/`DsCallout` is left untouched (still
`RemixCallout`-backed, `icon: IconData?`, no title/actions). This spec
covers a new, separate component, `notification_2` (`DsNotification`),
that covers the leading-widget/title/mandatory-text/actions requirements.
It is not a replacement for `DsCallout` — both remain in the DS; callers
pick whichever fits their case.

## File structure

```
lib/src/components/notification_2/
  notification_2.dart                 — DsNotification widget + doc comments
  notification_2_style_resolver.dart  — part of; resolveDsNotificationStyle() + text/gap resolvers
  notification_2_variants.dart        — DsNotificationVariant, DsNotificationSize enums
```

Hand-rolled on Mix's `Box` + plain Flutter `Row`/`Column` — the same shape
`toggle_group_2`/`button_group` use for composite components with no
matching Remix/legacy primitive to wrap.

## `DsNotification` widget API

```dart
class DsNotification extends StatelessWidget {
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

  /// Leading visual — a caller-built [Icon] or [IconContainer], laid out
  /// top-aligned with the title/text column. No `IconData` prop: callers
  /// pass a fully-built widget so they control whether it renders as a
  /// bare glyph or a background-square icon container.
  final Widget? leading;

  /// Optional heading, rendered above [text].
  final String? title;

  /// Body message. Always required and always rendered — unlike
  /// [DsDialog], there is no `child` escape hatch that bypasses this.
  final String text;

  /// Optional action widgets (typically [DsButton]s), rendered in a
  /// trailing-aligned row below [text].
  final List<Widget>? actions;

  /// Semantic color treatment — see [DsNotificationVariant].
  final DsNotificationVariant variant;

  /// Physical size — see [DsNotificationSize].
  final DsNotificationSize size;

  /// Escape hatch merged onto the resolved container style.
  final BoxStyler? style;

  /// Escape hatch merged onto the resolved title text style.
  final TextStyler? titleStyle;

  /// Escape hatch merged onto the resolved body text style.
  final TextStyler? textStyle;
}
```

Three separate style escape hatches (`style`/`titleStyle`/`textStyle`)
rather than one composite style object — same reasoning `IconContainer`
uses for its `style`/`iconStyle` split (`icon_container_2/icon_container.dart`):
a `BoxStyler` has no way to carry nested `TextStyler`s for two independent
text slots, so the container and each text slot are necessarily separate
`Prop`s.

## Layout (`build()`)

```
Box(style: resolvedContainerStyle)
  └─ Row(crossAxisAlignment: CrossAxisAlignment.start)   // top-aligns leading with the column
       ├─ leading!                                        // if leading != null
       ├─ SizedBox(width: gap)                             // if leading != null
       └─ Expanded(
            Column(crossAxisAlignment: CrossAxisAlignment.start)
              ├─ StyledText(title!, style: resolvedTitleStyle)   // if title != null
              ├─ SizedBox(height: gap)                            // if title != null
              ├─ StyledText(text, style: resolvedTextStyle)
              ├─ SizedBox(height: gap)                             // if actions non-empty
              └─ Row(mainAxisAlignment: MainAxisAlignment.end,     // if actions non-empty
                     spacing: gap, children: actions!)
          )
```

- `crossAxisAlignment: start` on the outer `Row` is what satisfies "icon
  and text should be top aligned" — `RemixCallout`'s own container
  defaults to centered cross-axis alignment, which is the bug being
  fixed here (for this new component; `callout_2` keeps its existing
  behavior).
- The actions row uses `MainAxisAlignment.end` for bottom-right alignment
  and is only built when `actions` is non-null and non-empty.
- `gap` values are plain `double`s resolved via `$spacingXXX.resolve(context)`
  at build time — the same pattern `toggle_group_2_style_resolver.dart`'s
  `_resolveGap` uses, since a plain `Row`/`Column` (unlike a Mix `Styler`)
  can't consume a token lazily through a fluent `.spacing()` call.

## Variants (`notification_2_variants.dart`)

```dart
enum DsNotificationVariant { neutral, brand, positive, negative, warning }

enum DsNotificationSize { sm, md, lg }
```

Same five/three-value sets `callout_2` and `icon_container_2` use, for
vocabulary consistency across the DS's semantic-content components.

## Style resolver (`notification_2_style_resolver.dart`)

Three resolver functions (no single composite spec to build, unlike
`resolveDsCalloutStyle`):

```dart
BoxStyler resolveDsNotificationContainerStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing012())),
    DsNotificationSize.md =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing016())),
    DsNotificationSize.lg =>
      BoxStyler().padding(EdgeInsetsGeometryMix.all($spacing020())),
  };

  final variantStyle = switch (variant) {
    DsNotificationVariant.neutral => BoxStyler().color($neutralSurface()),
    DsNotificationVariant.brand => BoxStyler().color($brandSurface()),
    DsNotificationVariant.positive => BoxStyler().color($positiveSurface()),
    DsNotificationVariant.negative => BoxStyler().color($negativeSurface()),
    DsNotificationVariant.warning => BoxStyler().color($warningSurface()),
  };

  return BoxStyler()
      .borderRadiusAll($radius008())
      .merge(sizeStyle)
      .merge(variantStyle);
}

TextStyler resolveDsNotificationTitleStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $labelSm.mix()),
    DsNotificationSize.md => TextStyler(style: $labelMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $labelLg.mix()),
  };

  return sizeStyle.color(_resolveVariantTextColor(variant));
}

TextStyler resolveDsNotificationTextStyle({
  required DsNotificationVariant variant,
  required DsNotificationSize size,
}) {
  final sizeStyle = switch (size) {
    DsNotificationSize.sm => TextStyler(style: $bodySm.mix()),
    DsNotificationSize.md => TextStyler(style: $bodyMd.mix()),
    DsNotificationSize.lg => TextStyler(style: $bodyLg.mix()),
  };

  return sizeStyle.color(_resolveVariantTextColor(variant));
}

Color _resolveVariantTextColor(DsNotificationVariant variant) {
  return switch (variant) {
    DsNotificationVariant.neutral => $neutralText(),
    DsNotificationVariant.brand => $brandText(),
    DsNotificationVariant.positive => $positiveText(),
    DsNotificationVariant.negative => $negativeText(),
    DsNotificationVariant.warning => $warningText(),
  };
}

double resolveDsNotificationGap(BuildContext context, DsNotificationSize size) {
  return switch (size) {
    DsNotificationSize.sm => $spacing008.resolve(context),
    DsNotificationSize.md => $spacing012.resolve(context),
    DsNotificationSize.lg => $spacing016.resolve(context),
  };
}
```

Notes:

- `borderRadiusAll($radius008())` matches every other `_2` component's
  corner radius.
- Variant sets a `*Surface` background on the container and pairs it with
  the matching `*Text` foreground on both `titleStyle` and `textStyle` —
  same surface/text token pairing `callout_2`/`icon_container_2` use, so a
  `DsIcon`/`IconContainer` passed as `leading` with the matching
  `DsIconVariant`/`DsIconContainerVariant` reads as one coherent color
  unit alongside the title/text.
- `title` uses `$labelSm`/`$labelMd`/`$labelLg` (a heavier/label-weight
  token) while `text` uses `$bodySm`/`$bodyMd`/`$bodyLg` — same
  size-to-token mapping shape `callout_2` already uses for its single
  `text` slot, just split across two slots.
- `resolveDsNotificationGap` needs `BuildContext` (via `.resolve(context)`)
  where the other three don't, because it's consumed directly by plain
  `SizedBox`/`Row.spacing` in `build()` rather than by a `Styler`'s fluent
  chain — same reasoning `toggle_group_2_style_resolver.dart`'s
  `_resolveGap` documents.

## Catalog registration

Add `example/lib/catalog/specs/notification_2_showcase_spec.dart`,
mirroring `callout_2_showcase_spec.dart`'s structure:

- `variantsBuilder`: one `DsNotification` per `DsNotificationVariant`,
  each with `text: variant.name` and `leading: Icon(PhosphorIcons.info())`.
- `sizesBuilder`: one per `DsNotificationSize`, same shape.
- `statesBuilder`: scenario coverage —
  - text only (no `leading`/`title`/`actions`)
  - with `title`
  - with `leading` as a bare `Icon`
  - with `leading` as an `IconContainer`
  - with `actions` (two `DsButton`s), to verify bottom-right alignment

Register in `example/lib/catalog/component_registry.dart` (alphabetically,
`'Notification 2': buildNotification2ShowcaseSpec`), and export
`notification_2/notification_2.dart` + `notification_2/notification_2_variants.dart`
from `lib/ui.dart` (same two-line pattern `callout_2`/`card_2` use).

## Out of scope

- `callout_2`/`DsCallout` — untouched. Stays `RemixCallout`-backed with
  its existing `icon: IconData?` prop and no title/actions support.
- A `child` escape hatch on `DsNotification` — unlike `DsDialog`, `text`
  is always required and always rendered; there is no bypass mode for
  fully custom body content.
- Dismiss/close button, auto-dismiss timer, entrance/exit animation —
  this is a static, non-interactive content block, the same
  interaction-less contract `callout_2` has. A future dismissible
  `DsToast`-style wrapper (if ever needed) is a separate component built
  on top of this one, not an addition to it here.
