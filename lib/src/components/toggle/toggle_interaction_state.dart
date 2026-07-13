/// The interaction state a [Toggle] is styled for at any given moment.
///
/// This is deliberately a separate axis from [Toggle.pressed] (whether the
/// toggle is currently "on"): a toggle can be tapped-down while on or off,
/// and disabled while on or off. The style resolvers in
/// `toggle_style_resolvers.dart` take both this state and the `pressed`
/// flag as independent parameters rather than folding them into one enum.
///
/// [disabled] is always driven by the widget's public `disabled`
/// constructor param — it is never inferred. [tapped] is the one state the
/// widget derives itself, from a live `GestureDetector` signal (see
/// `_ToggleState._isTapped`). [enabled] is the default when neither
/// applies. Mirrors `ButtonInteractionState`, minus `loading` — a toggle
/// has no async operation to represent.
enum ToggleInteractionState { enabled, tapped, disabled }
