/// The axis a [ToggleGroup] arranges its items along. Mirrors
/// `SeparatorOrientation` and shadcn/ui's `ToggleGroup` `orientation` prop.
enum ToggleGroupOrientation {
  /// Items laid out left-to-right, wrapping to a new row if they overflow
  /// the available width. The default.
  horizontal,

  /// Items laid out top-to-bottom, wrapping to a new column if they
  /// overflow the available height.
  vertical,
}
