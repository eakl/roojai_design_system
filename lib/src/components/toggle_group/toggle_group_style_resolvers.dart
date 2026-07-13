part of 'toggle_group.dart';

// Style resolvers for ToggleGroup.
//
// Just the one property today (inter-item spacing) — still pulled out as a
// resolver function rather than a bare constant inline in `build()` so it
// follows the same one-resolver-per-property shape as every other
// component in this package, and has an obvious home if group-level
// spacing ever needs to vary by more than [ToggleSize].

double _resolveGap(ToggleSize size) {
  switch (size) {
    case ToggleSize.sm:
      return AppSpacing.spacing4;
    case ToggleSize.md:
    case ToggleSize.lg:
      return AppSpacing.spacing8;
  }
}
