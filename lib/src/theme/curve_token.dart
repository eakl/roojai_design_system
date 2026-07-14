// lib/src/theme/curve_token.dart

import 'package:flutter/animation.dart';
import 'package:mix/mix.dart';

/// A [MixToken] for [Curve] values.
///
/// Mix ships no built-in curve token type because [Curve] isn't one of the
/// supported `MixToken.call()` reference types (see `getReferenceValue` in
/// the `mix` package). This token is therefore only usable via
/// [MixToken.resolve] — never via `call()` / inside a `Style` chain.
class CurveToken extends MixToken<Curve> {
  const CurveToken(super.name);
}
