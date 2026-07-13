import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';

// The `_resolve*` functions consumed by `build()` below live in
// input_group_style_resolvers.dart, split out as `part of` this library
// (not a separate import) so they stay private to InputGroup while living
// in their own file — same convention as Button/Input's own
// `_style_resolvers.dart` files.
part 'input_group_style_resolvers.dart';

/// Wraps one or more addon slots — [InputGroupAddon] (icon/text) or
/// [InputGroupButton] — around a single [InputGroupInput] or
/// [InputGroupTextarea] inside one shared bordered container, so the
/// whole group reads as a single control with one border rather than
/// several stacked ones. Flutter's counterpart to shadcn/ui's
/// `InputGroup`.
///
/// This only works because [InputGroupInput]/[InputGroupTextarea] paint
/// **no border or background of their own** — unlike embedding a plain
/// [Input] (see `Input` in `../input/input.dart`), which always paints
/// its own chrome and would show a redundant inner border next to this
/// container's outer one.
///
/// [children] are laid out left-to-right in a [Row], in the order given:
/// a leading [InputGroupAddon] comes first, the field goes in the middle,
/// a trailing [InputGroupAddon]/[InputGroupButton] comes last. There is
/// no dedicated `leading`/`trailing` constructor param — ordering *is*
/// the API, mirroring how shadcn/ui's `InputGroup` reads its children in
/// DOM order.
class InputGroup extends StatelessWidget {
  const InputGroup({
    super.key,
    required this.children,
    this.disabled = false,
    this.invalid = false,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  /// The addon(s)/button(s) and exactly one field
  /// ([InputGroupInput]/[InputGroupTextarea]), in display order. Kept as
  /// a flat `List<Widget>` rather than separate `leading`/`field`/
  /// `trailing` params — a group may have zero, one, or two addons, and a
  /// flat ordered list matches shadcn/ui's own children-based API more
  /// directly than a fixed three-slot shape would.
  final List<Widget> children;

  /// Public state: dims the shared border/background and wraps the whole
  /// group in an [IgnorePointer] so no addon, button, or field inside it
  /// can be interacted with. Never inferred — mirrors [Input.disabled].
  /// The caller is still responsible for also passing `disabled: true` to
  /// the inner field/button so *their* own resolved colors (text,
  /// placeholder) match; this only governs the shared chrome and blocks
  /// pointer events at the group level.
  final bool disabled;

  /// Public state: renders the negative/error border color. Mirrors
  /// [Input.invalid] — this widget doesn't validate its own content, the
  /// caller decides when the group's value is invalid.
  final bool invalid;

  /// Cross-axis alignment inside the [Row]. Defaults to centering every
  /// child on the field's line height, which is correct for a
  /// single-line [InputGroupInput]. Pass [CrossAxisAlignment.start] when
  /// composing with a multi-line [InputGroupTextarea] so a short addon
  /// aligns to the first line instead of stretching to the textarea's
  /// full height.
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties ------------------------------------------------
    final borderColor =
        _resolveBorderColor(colors, disabled: disabled, invalid: invalid);
    final backgroundColor = _resolveBackgroundColor(colors, disabled: disabled);

    // --- Layout ---------------------------------------------------------
    final content = AnimatedContainer(
      duration: AppMotion.durationFast,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.radius8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: _interleaveGaps(children),
      ),
    );

    return disabled ? IgnorePointer(child: content) : content;
  }
}

/// Inserts an [AppSpacing.spacing8]-wide gap between every pair of
/// adjacent [children], without touching the children themselves.
///
/// Deliberately does *not* wrap the field child in `Expanded`/`Flexible`
/// here — [InputGroupInput]/[InputGroupTextarea] already return an
/// `Expanded` as the root of their own `build()`. `Expanded`/`Flexible`
/// only need to sit somewhere between the enclosing `Row` and the
/// `RenderBox` they size, with nothing but `StatelessWidget`/
/// `StatefulWidget`s in between — so it still works even though the
/// direct entry in this `Row`'s `children` list is the field widget
/// itself, not an `Expanded`. Wrapping again here would just double-wrap
/// it. Addons/buttons, meanwhile, have no flex `RenderObjectWidget`
/// inside them, so they correctly size to their own content's width as a
/// plain (non-flex) `Row` child.
List<Widget> _interleaveGaps(List<Widget> children) {
  if (children.isEmpty) return children;
  final result = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    if (i > 0) result.add(const SizedBox(width: AppSpacing.spacing8));
    result.add(children[i]);
  }
  return result;
}
