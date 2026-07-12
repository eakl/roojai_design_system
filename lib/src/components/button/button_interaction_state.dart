/// The state a [Button] is styled for at any given moment.
///
/// [loading] and [disabled] are always driven by the widget's public
/// `loading`/`disabled` constructor params — they are never inferred.
/// [pressed] is the one state the widget derives itself, from a live
/// `GestureDetector` signal (see `_ButtonState._isPressed`). [enabled] is
/// the default when none of the above apply.
///
/// The style resolvers in `button.dart` switch over every [ButtonVariant]
/// x [ButtonInteractionState] pair explicitly, so this enum is the other
/// axis of that matrix.
enum ButtonInteractionState { enabled, pressed, loading, disabled }
