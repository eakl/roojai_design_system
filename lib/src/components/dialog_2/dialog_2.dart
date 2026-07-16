import 'package:flutter/widgets.dart';
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';

// The `resolveDsDialogStyle` function consumed by `build()` below lives in
// dialog_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsDialog while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart`.
part 'dialog_2_style_resolver.dart';

/// Shows a [DsDialog] (or any widget built by [builder]) as a modal route.
///
/// Thin wrapper around `remix`'s `showRemixDialog`, forwarding every param
/// unchanged. `RemixDialog` only renders correctly inside
/// `showRemixDialog`'s `MixScope`-wrapped route builder, so this is the
/// supported way to present a [DsDialog] — constructing one directly and
/// pushing it via `Navigator`/`showDialog` bypasses that scope.
Future<T?> showDsDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  Duration transitionDuration = const Duration(milliseconds: 400),
  RouteTransitionsBuilder? transitionBuilder,
  bool requestFocus = true,
  TraversalEdgeBehavior? traversalEdgeBehavior,
}) {
  return showRemixDialog<T>(
    context: context,
    builder: builder,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    transitionDuration: transitionDuration,
    transitionBuilder: transitionBuilder,
    requestFocus: requestFocus,
    traversalEdgeBehavior: traversalEdgeBehavior,
  );
}

/// A modal dialog built on top of the `remix` package's [RemixDialog],
/// styled through the design system's Mix semantic tokens.
///
/// Unlike [DsButton]/[DsInput], there is no legacy hand-rolled `Dialog` this
/// replaces — this is a new component. Must be shown via [showDsDialog] (or
/// `showRemixDialog` directly), not pushed as a standalone route — see
/// [showDsDialog]'s doc comment.
///
/// There is no `DsDialogSize`/`DsDialogVariant` — `RemixDialog` itself has
/// no size prop (only a `.size(width, height)` style escape hatch), and
/// there is no legacy component to carry a variant axis forward from. See
/// `docs/superpowers/specs/2026-07-16-dialog-2-component-design.md`.
class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    this.child,
    this.title,
    this.description,
    this.actions,
    this.modal = true,
    this.semanticLabel,
    this.style = const RemixDialogStyler.create(),
  }) : assert(
         child != null || title != null || description != null,
         'Either child, title, or description must be provided',
       );

  /// Custom content widget. When set, overrides the default
  /// [title]/[description]/[actions] composition entirely.
  final Widget? child;

  /// Dialog title text, rendered above [description].
  final String? title;

  /// Dialog description/body text, rendered below [title].
  final String? description;

  /// Action buttons rendered in a trailing-aligned row below
  /// [description]. Typically [DsButton]s.
  final List<Widget>? actions;

  /// Whether to block interaction with content behind the dialog.
  final bool modal;

  /// Overrides the semantic label read by screen readers. Defaults to
  /// [title] when null (same fallback [RemixDialog] applies).
  final String? semanticLabel;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsDialogStyle]'s output).
  final RemixDialogStyler style;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsDialogStyle().merge(style);

    return RemixDialog(
      title: title,
      description: description,
      actions: actions,
      modal: modal,
      semanticLabel: semanticLabel,
      style: resolvedStyle,
      child: child,
    );
  }
}
