import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../button/button.dart';

/// Lays out a row of [Button]s edge-to-edge so they read as one connected
/// control, shadcn's `ButtonGroup` — square inner corners, rounded outer
/// corners, and a single 1px divider between adjacent buttons.
///
/// [ButtonGroup] only arranges pre-built [Button]s; it does not own
/// selection state or restyle its children (each [Button] keeps whatever
/// `variant`/`size`/`onPressed` it was constructed with). Callers that need
/// a segmented single/multi-select control should reach for `ToggleGroup`
/// instead — this widget is purely a layout wrapper.
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({super.key, required this.buttons});

  /// The buttons to lay out, left to right. Must contain at least one
  /// button — an empty group renders nothing but is not a supported case.
  final List<Button> buttons;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -------------------------------------------------------
    final colors = AppTokens.of(context).colors;

    // --- Resolved properties --------------------------------------------
    // Radius is shared with Button's own `md`/`lg` corner radius so the
    // group's outer corners visually match a standalone button's corners.
    final radius = _resolveRadius();
    final dividerColor = _resolveDividerColor(colors);

    // --- Layout ---------------------------------------------------------
    // ClipRRect rounds only the group's outer edge; the buttons themselves
    // keep their own (square, since Button always paints its own radius)
    // corners underneath, so only the two ends of the row appear rounded.
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            // A divider is inserted only *between* buttons, never before
            // the first or after the last, so the group's outer edges stay
            // clean.
            if (i > 0) Container(width: 1, color: dividerColor),
            buttons[i],
          ],
        ],
      ),
    );
  }
}

/// Corner radius for the group's outer edge. Kept as its own resolver
/// (rather than a bare constant used directly in `build()`) so it follows
/// the same one-resolver-per-property shape as every other component in
/// this package, and so a future size-dependent radius is a one-line
/// change instead of a new function.
double _resolveRadius() => AppRadius.radius8;

Color _resolveDividerColor(SemanticColors colors) => colors.border.base;
