/// Physical size of a [DsBadge]. Drives padding, text style, and icon
/// gap/extent — see the `_resolve*`/`resolveDsBadgeStyle` functions in
/// `badge_2_style_resolver.dart` and `badge_2.dart`.
enum DsBadgeSize { sm, md, lg }

/// Visual treatment of a [DsBadge]. Each variant maps to its own
/// background/foreground color pair in `resolveDsBadgeStyle` — see
/// `badge_2_style_resolver.dart`.
///
/// Merges legacy `BadgeVariant`'s structural variants (`primary`,
/// `secondary`, `outline`, `ghost`) with the semantic status palette
/// available in `colors.dart` (`positive`, `negative`, `warning`, `info`,
/// `neutral`). Legacy `BadgeVariant.destructive` is not ported as its own
/// case — it resolved to the same tokens `negative` now uses.
enum DsBadgeVariant {
  /// Strongest visual weight — filled with the inverted surface.
  primary,

  /// Secondary emphasis — filled alternative surface.
  secondary,

  /// Outlined, transparent background — tertiary emphasis.
  outline,

  /// Transparent background, no border — lowest emphasis.
  ghost,

  /// Communicates a positive/success status.
  positive,

  /// Communicates a negative/error status (also covers legacy
  /// `destructive`'s use case).
  negative,

  /// Communicates a caution/warning status.
  warning,

  /// Communicates an informational status.
  info,

  /// Communicates a neutral/muted status.
  neutral,
}
