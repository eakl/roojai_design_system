/// Visual treatment of a [Badge]. Each variant maps to its own
/// background/foreground/border color combination in the resolver
/// functions in `badge_style_resolvers.dart` — see `_resolveBackgroundColor`
/// etc. Mirrors [ButtonVariant]'s shape minus `link`, since Badge is
/// non-interactive and has no affordance for a link-style variant.
enum BadgeVariant {
  /// Strongest visual weight — filled with the brand surface.
  primary,

  /// Secondary emphasis — filled surface, no strong contrast.
  secondary,

  /// Outlined, transparent background — tertiary emphasis.
  outline,

  /// Transparent background, no border — lowest emphasis.
  ghost,

  /// Communicates a destructive/negative status (error, removed, etc.).
  destructive,
}
