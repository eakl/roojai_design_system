/// The state an [AppSelect] is styled for at any given moment.
///
/// [disabled] and [invalid] are always driven by the widget's public
/// `disabled`/`invalid` constructor params — they are never inferred.
/// [open] is the one state the widget derives itself, from its own
/// dropdown-menu-overlay lifecycle (see `_AppSelectState._isOpen`).
/// [closed] is the default when none of the above apply.
///
/// The style resolvers in `select.dart` switch over every
/// [SelectInteractionState] value explicitly, so this enum is the state
/// axis of that matrix. Order of precedence when resolving (see
/// `_AppSelectState._interactionState`): disabled beats invalid beats the
/// live open signal beats the closed default. Mirrors
/// `InputInteractionState`'s precedence order.
enum SelectInteractionState { closed, open, disabled, invalid }
