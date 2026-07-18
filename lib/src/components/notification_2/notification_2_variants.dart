enum DsNotificationVariant { neutral, brand, positive, negative, warning }

enum DsNotificationSize { sm, md, lg }

/// Emphasis level — same soft/solid meaning as [DsCalloutTone]: `soft`
/// tints the container with the color's `*Surface` token and colors
/// title/text/leading-icon with `*Text` (today's only look); `solid` fills
/// the container with the color's saturated `*Ui` token and switches
/// title/text/leading-icon to `$contentOnBrand()` (white).
enum DsNotificationTone { soft, solid }
