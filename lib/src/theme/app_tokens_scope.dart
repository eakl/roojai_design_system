import 'package:flutter/widgets.dart';

import '../tokens/semantic/semantic_colors.dart';
import '../tokens/semantic/semantic_typography.dart';
import 'app_tokens.dart';

/// Installs [AppTokens] at the app root. Defaults to the package's built-in
/// token values; a consuming app may pass its own brand tokens to retheme
/// every component without touching component code.
class AppTokensScope extends StatelessWidget {
  const AppTokensScope({
    super.key,
    this.colors = SemanticColors.defaultLight,
    this.typography = SemanticTypography.defaultScale,
    required this.child,
  });

  final SemanticColors colors;
  final SemanticTypography typography;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppTokens(
      colors: colors,
      typography: typography,
      child: child,
    );
  }
}
