/// Visual treatment of an [Input]. Each variant renders a structurally
/// different control — see the layout branch in `_InputState.build` in
/// `input.dart`.
enum InputVariant {
  /// A standard text field with a solid border. [InputType] controls the
  /// underlying keyboard/obscuring behavior for this variant.
  text,

  /// An icon-only drop target with a dashed border, used to pick a file.
  /// Renders no text field at all. Actually invoking a native file picker
  /// is an app-level concern (this package has no file-picker dependency
  /// of its own) — [Input.onFilePick] is just a tap callback the caller
  /// wires up to whatever file-picking mechanism their app uses.
  file,
}
