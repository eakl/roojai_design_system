/// The kind of text content an [InputVariant.text] `Input` collects.
/// Ignored entirely when `Input.variant` is [InputVariant.file].
///
/// Mirrors the HTML `<input type="...">` vocabulary shadcn's `Input`
/// exposes: each value maps to a keyboard layout and, for [password], to
/// obscured entry — see `_resolveKeyboardType`/`_resolveObscureText` in
/// `input.dart`.
enum InputType {
  /// Plain text, no special keyboard or obscuring.
  text,

  /// Email keyboard layout (adds `@`/`.` affordances on most platforms).
  email,

  /// Obscures entered characters and requests the platform's password
  /// keyboard.
  password,

  /// Numeric keyboard layout.
  number,

  /// Telephone-number keyboard layout.
  phone,

  /// URL keyboard layout (adds `/`/`.com` affordances on most platforms).
  url,
}
