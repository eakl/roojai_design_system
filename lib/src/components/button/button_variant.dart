/// Visual treatment of a [Button]. Each variant maps to its own
/// background/foreground/border color combination in the resolver
/// functions in `button.dart` — see `_resolveBackgroundColor` etc.
enum ButtonVariant {
  /// Strongest visual weight — the single default call-to-action per screen.
  primary,

  /// Secondary emphasis — filled surface, no strong contrast.
  secondary,

  /// Outlined, transparent background — tertiary emphasis.
  outline,

  /// Transparent background, no border — lowest emphasis, e.g. inline actions.
  ghost,

  /// Communicates a destructive/irreversible action (delete, remove, etc.).
  destructive,
}
