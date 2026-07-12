/// The axis a [Separator] draws its dividing line along. Drives which
/// dimension [Separator.length] is applied to — see `separator.dart`.
enum SeparatorOrientation {
  /// A thin horizontal line, sized along the x-axis. The default — matches
  /// shadcn's `Separator`, which also defaults to horizontal.
  horizontal,

  /// A thin vertical line, sized along the y-axis. Typically used between
  /// inline items in a `Row` (e.g. toolbar actions), where it needs an
  /// explicit height from its parent — see the doc on [Separator.length].
  vertical,
}
