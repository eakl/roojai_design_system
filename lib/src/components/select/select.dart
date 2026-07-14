import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_elevation.dart';
import '../../tokens/primitives/app_motion.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import 'select_interaction_state.dart';

// The `_resolve*` functions consumed by `build()` below live in
// select_style_resolvers.dart, split out as `part of` this library (not a
// separate import) so they stay private to AppSelect while living in
// their own file — same convention as Button/Input's `_style_resolvers`
// part files.
part 'select_style_resolvers.dart';

/// A single-select dropdown built from low-level primitives
/// (`CompositedTransformTarget`/`CompositedTransformFollower` anchoring an
/// `OverlayEntry`, no Material `DropdownButton`/`PopupMenuButton`).
///
/// Named `AppSelect` (not `Select`) for consistency with `AppSwitch`/
/// `AppCheckbox`/`AppRadio` — every control that models a value rather than
/// an action gets the `App` prefix in this package.
///
/// [selected] and [disabled] are both explicit constructor params — like
/// [Button], public state is never inferred from other props. The one
/// state the widget derives itself is "open", from its own overlay
/// lifecycle (see [_AppSelectState._isOpen]). This widget is fully
/// controlled: it holds no notion of its own value, only whether its menu
/// is currently showing — the caller owns [selected] and updates it from
/// [onChanged], mirroring [AppCheckbox]/[AppSwitch].
class AppSelect extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.options,
    this.selected,
    required this.onChanged,
    this.placeholder = 'Select…',
    this.disabled = false,
    this.invalid = false,
    this.focusNode,
    this.autofocus = false,
  });

  /// The full list of choices shown in the dropdown menu, in display order.
  final List<String> options;

  /// The currently chosen option, or null when nothing is selected yet.
  /// This widget holds no selection state of its own — it always reflects
  /// this value, the same "fully controlled" convention as
  /// [AppCheckbox.value]/[AppSwitch.value].
  final String? selected;

  /// Called with the tapped option when the caller picks one from the
  /// open menu. Ignored (and the trigger rendered non-interactive) while
  /// [disabled] is true, or when null.
  final ValueChanged<String>? onChanged;

  /// Shown in place of [selected] when it is null.
  final String placeholder;

  /// Public state: renders muted colors and suppresses taps, focus, and
  /// the menu entirely. Takes precedence over [invalid] when both are
  /// true — mirrors [Input.disabled]'s precedence over [Input.invalid].
  final bool disabled;

  /// Public state: renders the negative/error border color. Mirrors
  /// [Input.invalid] — this widget doesn't validate [selected] itself, the
  /// caller decides when a value is invalid and passes this flag
  /// explicitly.
  final bool invalid;

  /// Optional external focus node. When null, the widget owns and
  /// disposes an internal one — see [_AppSelectState._focusNode].
  final FocusNode? focusNode;

  /// Whether this trigger should request focus when first built.
  final bool autofocus;

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  // Anchors the overlay menu to the trigger's position/size — the
  // low-level primitive `CompositedTransformTarget`/`Follower` pair uses
  // to keep a floating widget pinned to another widget without either one
  // needing to know the other's absolute screen position.
  final LayerLink _layerLink = LayerLink();

  // Lets `_openMenu` read the trigger's current size (so the menu can
  // match its width) without a separate `LayoutBuilder`.
  final GlobalKey _triggerKey = GlobalKey();

  // Non-null exactly while the menu is showing. Owned by this State so it
  // can always be removed on close or dispose, even if the widget is torn
  // down mid-interaction.
  OverlayEntry? _overlayEntry;

  // Internal interaction state — the only one the widget derives itself
  // rather than taking as a constructor param, driven purely by the
  // overlay's own insert/remove lifecycle. Same convention as
  // `_ButtonState._isPressed`/`_InputState._isFocused`.
  bool _isOpen = false;

  // Owned only when the caller doesn't supply their own FocusNode, so we
  // know whether we're responsible for disposing it. Same pattern as
  // Button/Input/AppCheckbox.
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSelect');
    }
  }

  @override
  void didUpdateWidget(AppSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller started/stopped supplying their own FocusNode: swap our
    // internally-owned node in or out accordingly.
    if (oldWidget.focusNode == null && widget.focusNode != null) {
      _internalFocusNode?.dispose();
      _internalFocusNode = null;
    } else if (oldWidget.focusNode != null && widget.focusNode == null) {
      _internalFocusNode = FocusNode(debugLabel: 'AppSelect');
    }
  }

  @override
  void dispose() {
    // Removed directly (no `setState`) rather than via `_closeMenu` —
    // calling `setState` from `dispose` is illegal, and there is no tree
    // left to rebuild anyway.
    _overlayEntry?.remove();
    _overlayEntry = null;
    _internalFocusNode?.dispose();
    super.dispose();
  }

  /// True when the trigger accepts taps at all. [disabled] always wins,
  /// and a null [AppSelect.onChanged] makes it inert even when not
  /// disabled — mirrors [Button]/[AppCheckbox]'s `_interactive` getter.
  bool get _interactive => !widget.disabled && widget.onChanged != null;

  /// Resolves the single [SelectInteractionState] this frame is styled
  /// for. Order matters: disabled beats invalid beats the live open
  /// signal beats the closed default — see `select_interaction_state.dart`.
  SelectInteractionState get _interactionState {
    if (widget.disabled) return SelectInteractionState.disabled;
    if (widget.invalid) return SelectInteractionState.invalid;
    if (_isOpen) return SelectInteractionState.open;
    return SelectInteractionState.closed;
  }

  void _handleTap() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final triggerBox =
        _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final triggerSize = triggerBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _SelectMenu(
        link: _layerLink,
        triggerWidth: triggerSize.width,
        options: widget.options,
        selected: widget.selected,
        onDismiss: _closeMenu,
        onSelect: (option) {
          _closeMenu();
          widget.onChanged!(option);
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeMenu() {
    if (_overlayEntry == null) return;
    _overlayEntry!.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    // --- Tokens ---------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ---------------------------------------------
    final state = _interactionState;
    final borderColor = _resolveBorderColor(colors, state);
    final ringColor = _resolveRingColor(colors, state);
    final backgroundColor = _resolveBackgroundColor(colors, state);
    final textColor = _resolveTextColor(colors, state, widget.selected != null);
    final chevronColor = _resolveChevronColor(colors, state);

    // --- Layout ---------------------------------------------------------
    return CompositedTransformTarget(
      key: _triggerKey,
      link: _layerLink,
      child: MouseRegion(
        cursor: _interactive
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: _interactive,
          child: GestureDetector(
            onTap: _interactive ? _handleTap : null,
            child: AnimatedContainer(
              duration: AppMotion.durationFast,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing12,
                vertical: AppSpacing.spacing8,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppRadius.radius8),
                border: Border.all(color: borderColor),
                // Painted outside the box bounds and therefore never
                // affects layout size — same rationale as
                // `Input._resolveRingColor`.
                boxShadow: ringColor != null
                    ? [BoxShadow(color: ringColor, spreadRadius: 2)]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.selected ?? widget.placeholder,
                      overflow: TextOverflow.ellipsis,
                      style: typography.bodyMd.copyWith(color: textColor),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing8),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CustomPaint(
                      painter: _ChevronPainter(color: chevronColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The floating options panel inserted into the `Overlay` while
/// [_AppSelectState._isOpen] is true. Kept as a separate widget (rather
/// than built inline in `_openMenu`) so it can read [AppTokens] itself —
/// `OverlayEntry.builder` runs with the `Overlay`'s own `BuildContext`,
/// not `_AppSelectState`'s.
class _SelectMenu extends StatelessWidget {
  const _SelectMenu({
    required this.link,
    required this.triggerWidth,
    required this.options,
    required this.selected,
    required this.onDismiss,
    required this.onSelect,
  });

  final LayerLink link;
  final double triggerWidth;
  final List<String> options;
  final String? selected;
  final VoidCallback onDismiss;
  final ValueChanged<String> onSelect;

  /// Caps the panel's height so a long option list scrolls instead of
  /// growing past the screen.
  static const double _maxMenuHeight = 240;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;

    return Stack(
      children: [
        // Invisible full-screen barrier: a tap anywhere outside the panel
        // closes the menu. Built from a plain `GestureDetector` rather
        // than Material's `ModalBarrier`, which backs `showMenu`'s own
        // dismiss behavior.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, AppSpacing.spacing4),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: triggerWidth,
                maxWidth: triggerWidth,
                maxHeight: _maxMenuHeight,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.base,
                  borderRadius: BorderRadius.circular(AppRadius.radius8),
                  border: Border.all(color: colors.border.base),
                  // The one place this component reaches for `AppElevation`
                  // directly rather than through a semantic re-alias — like
                  // `AppSpacing`/`AppRadius`, elevation has no semantic
                  // layer in this token set (see Task 2/3 of the plan).
                  boxShadow: AppElevation.level2,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.spacing4,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return _SelectOptionRow(
                      label: option,
                      isSelected: option == selected,
                      onTap: () => onSelect(option),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A single tappable row inside [_SelectMenu]. Kept as its own widget
/// (rather than built inline in `ListView.builder`) so the selected-row
/// highlight and tap target are defined once and read clearly at the call
/// site above.
class _SelectOptionRow extends StatelessWidget {
  const _SelectOptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Null (rather than transparent) when not selected, so this row
          // never paints over the panel's own background — matters for
          // the panel's rounded corners at the first/last row.
          color: isSelected ? colors.surface.alternative : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing12,
            vertical: AppSpacing.spacing8,
          ),
          child: Text(
            label,
            style: typography.bodyMd.copyWith(color: colors.content.primary),
          ),
        ),
      ),
    );
  }
}

/// Minimal downward chevron used as the trigger's affordance glyph. Built
/// from `CustomPaint` since no icon set ships with this package — same
/// precedent as `Button`'s `_ButtonSpinner` and `Input`'s `_UploadIcon`.
///
/// Unlike an accordion/collapsible's chevron, this one does not rotate
/// between open/closed — shadcn's own `Select` trigger keeps a static
/// downward chevron regardless of menu state, and mirroring that avoids
/// implying the menu opens "upward" when it always opens below the
/// trigger.
class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.75)
      ..lineTo(size.width * 0.9, size.height * 0.3);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
