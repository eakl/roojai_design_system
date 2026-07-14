/// Semantic color treatment of an [Icon]. Each variant maps to a color
/// token in `_resolveIconColor(variant)` in `icon_style_resolver.dart`.
enum IconVariant {
  /// Default — muted gray, no semantic meaning attached.
  neutral,

  /// Brand-colored, for icons tied to primary/brand actions or emphasis.
  brand,

  /// Communicates success/positive status (checkmarks, confirmations).
  positive,

  /// Communicates an error/destructive status.
  negative,

  /// Communicates a caution/warning status.
  warning,
}
