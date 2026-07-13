/// Visual treatment of a [Toggle]. Each variant maps to its own
/// background/foreground/border color combination in the resolver
/// functions in `toggle_style_resolvers.dart` — see `_resolveBackgroundColor`
/// etc.
enum ToggleVariant {
  /// Transparent at rest, filled when [Toggle.pressed] is true — no
  /// border. Named `standard` rather than `default` (a reserved Dart
  /// keyword) to mirror shadcn/ui's "default" toggle variant.
  standard,

  /// Same fill behavior as [standard], but always outlined with a border,
  /// giving it a visible resting silhouette even when unpressed.
  outline,
}
