import 'package:flutter/widgets.dart';

import '../tokens/semantic/semantic_colors.dart';
import '../tokens/semantic/semantic_typography.dart';

/// Exposes the active semantic token set to the widget tree. Components
/// read tokens exclusively through `AppTokens.of(context)` — never by
/// hardcoding values or importing primitives directly.
class AppTokens extends InheritedWidget {
  const AppTokens({
    super.key,
    required this.colors,
    required this.typography,
    required super.child,
  });

  final SemanticColors colors;
  final SemanticTypography typography;

  static AppTokens of(BuildContext context) {
    final tokens = context.dependOnInheritedWidgetOfExactType<AppTokens>();
    assert(
      tokens != null,
      'AppTokens.of() called with a context that has no AppTokensScope '
      'ancestor. Wrap the app root in AppTokensScope.',
    );
    return tokens!;
  }

  @override
  bool updateShouldNotify(AppTokens oldWidget) {
    return colors != oldWidget.colors || typography != oldWidget.typography;
  }
}
