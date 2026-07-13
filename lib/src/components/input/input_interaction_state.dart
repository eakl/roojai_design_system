/// The state an [Input] is styled for at any given moment.
///
/// [disabled] and [invalid] are always driven by the widget's public
/// `disabled`/`invalid` constructor params — they are never inferred.
/// [focused] is the one state the widget derives itself, from a live
/// `FocusNode` signal (see `_InputState._isFocused`). [enabled] is the
/// default when none of the above apply.
///
/// The style resolvers in `input.dart` switch over every
/// [InputInteractionState] value explicitly, so this enum is the state
/// axis of that matrix. Order of precedence when resolving (see
/// `_InputState._interactionState`): disabled beats invalid beats the
/// live focused signal beats the enabled default.
enum InputInteractionState { enabled, focused, disabled, invalid }
