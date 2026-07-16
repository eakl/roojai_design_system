/// The axis a [DsToggleGroup] arranges its items along. Mirrors the legacy
/// `ToggleGroupOrientation` and shadcn/ui's `ToggleGroup` `orientation` prop.
enum DsToggleGroupOrientation {
  /// Items laid out left-to-right, wrapping to a new row if they overflow
  /// the available width. The default.
  horizontal,

  /// Items laid out top-to-bottom, wrapping to a new column if they
  /// overflow the available height.
  vertical,
}
