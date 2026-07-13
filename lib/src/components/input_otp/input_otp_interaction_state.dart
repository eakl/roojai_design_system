/// The state an [InputOtp] is styled for at any given moment.
///
/// Mirrors `InputInteractionState` exactly — [disabled] and [invalid] are
/// always driven by the widget's public `disabled`/`invalid` constructor
/// params (never inferred), [focused] is derived from a live `FocusNode`
/// signal (see `_InputOtpState._isFocused`), and [enabled] is the default
/// when none of the above apply. Kept as its own enum (not a shared import
/// of `InputInteractionState`) so `InputOtp` doesn't take on a dependency
/// on `Input` just to reuse four enum values — same convention as
/// `ButtonInteractionState`/`ToggleInteractionState` each owning their own
/// state axis instead of sharing one.
enum InputOtpInteractionState { enabled, focused, disabled, invalid }
