enum DsCardSize { sm, md, lg }

/// Visual treatment. `base`/`alternative`/`inverted` are filled surfaces
/// distinguished only by background color (no separate tone axis — flat,
/// same shape as `DsBadgeVariant`); `elevated` trades a background tint for
/// a shadow; `bordered` has no background, just an emphasized border.
enum DsCardVariant { base, alternative, inverted, elevated, bordered }
