import 'package:flutter/widgets.dart';

import '../button/button.dart';
import '../button/button_size.dart';
import '../button/button_variant.dart';

/// A [Button] pre-styled to sit inside an [InputGroup]'s addon area —
/// e.g. a trailing "Send"/"Copy"/"Clear" affordance — shadcn/ui's
/// `InputGroupButton`.
///
/// This is a thin composition over the real [Button] (the same "rebuild
/// the real component at shared props" approach `AvatarGroup` uses for
/// `Avatar` and `ToggleGroup` uses for `Toggle`), not a separate
/// implementation — every visual property still ultimately comes from
/// [Button]'s own token-driven resolvers. Only the *defaults* differ, so
/// it reads correctly as part of the group instead of as a second,
/// competing bordered control:
/// - [variant] defaults to [ButtonVariant.ghost] (chrome-free at rest).
/// - [size] defaults to [ButtonSize.sm] — [ButtonSize] has no size
///   smaller than `sm`, which is the closest match to shadcn/ui's
///   dedicated compact `InputGroupButton` size; both remain overridable.
class InputGroupButton extends StatelessWidget {
  const InputGroupButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.ghost,
    this.size = ButtonSize.sm,
    this.disabled = false,
    this.leading,
    this.trailing,
  });

  /// Forwarded to [Button.label].
  final String label;

  /// Forwarded to [Button.onPressed].
  final VoidCallback? onPressed;

  /// Forwarded to [Button.variant]. See the class doc for why this
  /// defaults to [ButtonVariant.ghost] here (unlike [Button] itself,
  /// which defaults to [ButtonVariant.primary]).
  final ButtonVariant variant;

  /// Forwarded to [Button.size]. See the class doc for why this defaults
  /// to [ButtonSize.sm] here (unlike [Button] itself, which defaults to
  /// [ButtonSize.md]).
  final ButtonSize size;

  /// Forwarded to [Button.disabled].
  final bool disabled;

  /// Forwarded to [Button.leading].
  final Widget? leading;

  /// Forwarded to [Button.trailing].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Button(
      label: label,
      onPressed: onPressed,
      variant: variant,
      size: size,
      disabled: disabled,
      leading: leading,
      trailing: trailing,
    );
  }
}
