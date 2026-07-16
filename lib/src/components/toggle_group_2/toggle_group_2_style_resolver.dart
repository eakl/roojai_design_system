part of 'toggle_group_2.dart';

// Style resolvers for DsToggleGroup.
//
// Just the one property today (inter-item spacing) — still pulled out as a
// resolver function rather than a bare constant inline in `build()` so it
// follows the same one-resolver-per-property shape as every other
// component in this package, and has an obvious home if group-level
// spacing ever needs to vary by more than [DsToggleSize].
//
// Uses the Mix semantic spacing tokens (rather than the legacy resolver's
// `AppSpacing` primitives) — same token migration every other `_2`
// component follows, see
// `docs/superpowers/specs/2026-07-14-mix-token-migration-design.md`. `Wrap`
// is a plain Flutter widget, not a Mix `Style`, so the token can't be
// consumed lazily via a fluent `.paddingX($spacing004())`-style call —
// `.resolve(context)` is required to get a concrete `double`, the same
// pattern showcase pages use for tokens read outside Mix styling (see e.g.
// `component_showcase_page.dart`).

double _resolveGap(BuildContext context, DsToggleSize size) {
  switch (size) {
    case DsToggleSize.sm:
      return $spacing004.resolve(context);
    case DsToggleSize.md:
    case DsToggleSize.lg:
      return $spacing008.resolve(context);
  }
}
