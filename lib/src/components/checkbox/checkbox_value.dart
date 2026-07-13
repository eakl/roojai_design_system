/// The tri-state value of an [AppCheckbox].
///
/// [indeterminate] represents a "mixed" state (e.g. a parent checkbox
/// whose children are partially selected) — it renders a dash instead of
/// a checkmark, and like [checked] it is visually "filled" rather than
/// empty. Tapping either [checked] or [indeterminate] resolves to
/// [unchecked]; tapping [unchecked] resolves to [checked] — see
/// `_AppCheckboxState._handleTap` in `checkbox.dart`.
enum CheckboxValue { unchecked, checked, indeterminate }
