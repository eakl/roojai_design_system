import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../tokens/semantic/colors.dart';
import '../../tokens/semantic/radius.dart';
import '../../tokens/semantic/spacing.dart';
import '../../tokens/semantic/typography.dart';
import 'avatar_2_variants.dart';

// The `resolveDsAvatarStyle` function consumed by `build()` below lives in
// avatar_2_style_resolver.dart, split out as `part of` this library (not a
// separate import) so it stays private to DsAvatar while living in its own
// file — same split as `DsButton`'s `button_2_style_resolver.dart` and
// `DsBadge`'s `badge_2_style_resolver.dart`.
part 'avatar_2_style_resolver.dart';

/// Normalizes [label] to at most two uppercase characters, so a caller
/// passing a full name or lowercase text still lays out as a compact
/// two-glyph initials circle instead of overflowing or looking
/// inconsistent with the rest of the design system. Ported from legacy
/// `Avatar`'s `_resolveFallbackText`.
String _resolveDsAvatarLabelText(String label) {
  final normalized = label.trim().toUpperCase();
  return normalized.length <= 2 ? normalized : normalized.substring(0, 2);
}

/// A circular or rounded-square photo avatar with a text/icon fallback,
/// built on top of the `remix` package's [RemixAvatar], styled through the
/// design system's Mix semantic tokens.
///
/// Unlike every other `_2` component, [DsAvatar] is a [StatefulWidget]:
/// [RemixAvatar] does not automatically swap to fallback content when
/// [image] fails to load — it only exposes an
/// `onBackgroundImageError`/[onImageError]-style *callback*, leaving state
/// management to the caller. [DsAvatar] tracks that failure itself
/// (mirroring legacy `Avatar`'s `Image.errorBuilder` behavior) so callers
/// get automatic fallback-on-error without wiring anything themselves. See
/// `docs/superpowers/specs/2026-07-16-avatar-2-component-design.md`.
class DsAvatar extends StatefulWidget {
  const DsAvatar({
    super.key,
    this.image,
    this.onImageError,
    this.label,
    this.icon,
    this.variant = DsAvatarVariant.soft,
    this.size = DsAvatarSize.md,
    this.shape = DsAvatarShape.circle,
    this.style = const RemixAvatarStyle.create(),
    this.styleSpec,
  });

  /// The avatar's photo, from any source Flutter supports —
  /// `NetworkImage`, `AssetImage`, `MemoryImage`, `FileImage`, etc. When
  /// null, or when it fails to load, [label]/[icon] are shown instead.
  final ImageProvider? image;

  /// Optional passthrough so callers can also observe image-load
  /// failures (e.g. for logging), independent of the automatic fallback
  /// this widget performs on failure.
  final ImageErrorListener? onImageError;

  /// Fallback text shown when [image] is null or fails to load, and no
  /// [icon] fallback takes priority. Expected to be two-letter initials
  /// (e.g. "JD"), but defensively uppercased and truncated to two
  /// characters — see [_resolveDsAvatarLabelText].
  final String? label;

  /// Fallback icon shown when [image] is null or fails to load and
  /// [label] is null. Ignored when [label] is non-null — same
  /// content-priority chain as [RemixAvatar] itself.
  final IconData? icon;

  /// Visual treatment of the fallback content — see [DsAvatarVariant].
  /// A rendered [image] visually hides this.
  final DsAvatarVariant variant;

  /// Physical size — see [DsAvatarSize].
  final DsAvatarSize size;

  /// Corner shape — see [DsAvatarShape].
  final DsAvatarShape shape;

  /// Escape hatch for callers that need to further customize the resolved
  /// style (merged on top of [resolveDsAvatarStyle]'s output). Same
  /// convention as [DsButton.style]/[DsBadge.style].
  final RemixAvatarStyle style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixAvatarSpec] directly, bypassing style resolution entirely.
  final StyleSpec<RemixAvatarSpec>? styleSpec;

  @override
  State<DsAvatar> createState() => _DsAvatarState();
}

class _DsAvatarState extends State<DsAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(DsAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A newly-assigned image gets a fresh load attempt instead of staying
    // stuck on a previous image's failure.
    if (widget.image != oldWidget.image) {
      _imageFailed = false;
    }
  }

  void _handleImageError(Object error, StackTrace? stackTrace) {
    widget.onImageError?.call(error, stackTrace);
    if (!_imageFailed) {
      setState(() => _imageFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsAvatarStyle(
      variant: widget.variant,
      size: widget.size,
      shape: widget.shape,
    ).merge(widget.style);

    final showImage = widget.image != null && !_imageFailed;

    return RemixAvatar(
      backgroundImage: showImage ? widget.image : null,
      onBackgroundImageError: showImage ? _handleImageError : null,
      label: showImage || widget.label == null
          ? null
          : _resolveDsAvatarLabelText(widget.label!),
      icon: showImage || widget.label != null ? null : widget.icon,
      style: resolvedStyle,
      styleSpec: widget.styleSpec,
    );
  }
}
