enum DsCalloutVariant { neutral, brand, positive, negative, warning }

enum DsCalloutSize { sm, md, lg }

/// Emphasis level: `soft` tints the background with the color's `*Surface`
/// token and colors text/icon with `*Text` (today's only look); `solid`
/// fills the background with the color's saturated `*Ui` token and switches
/// text/icon to `$contentOnBrand()` (white) — same soft/solid pairing
/// `DsAvatarVariant` already uses.
enum DsCalloutTone { soft, solid }
