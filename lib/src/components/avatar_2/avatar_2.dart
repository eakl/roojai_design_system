import 'package:flutter/widgets.dart' hide Icon;
import 'package:remix/remix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../../theme/light/typography.dart';
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
/// get automatic fallback-on-error without wiring anything themselves.
/// [DsAvatar] also resolves [image] through its own [ImageStream] so the
/// fallback stays visible while the image is still loading, instead of
/// popping in only once fully decoded. See
/// `docs/superpowers/specs/2026-07-16-avatar-2-component-design.md`.
class DsAvatar extends StatefulWidget {
  const DsAvatar({
    super.key,
    this.image,
    this.onImageError,
    this.label,
    this.icon,
    this.shape = DsAvatarShape.circle,
    this.variant = DsAvatarVariant.soft,
    this.size = DsAvatarSize.md,
    this.style = const RemixAvatarStyler.create(),
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
  final RemixAvatarStyler style;

  /// Escape hatch for callers that need to supply an already-resolved
  /// [RemixAvatarSpec] directly, bypassing style resolution entirely.
  final RemixAvatarSpec? styleSpec;

  @override
  State<DsAvatar> createState() => _DsAvatarState();
}

class _DsAvatarState extends State<DsAvatar> {
  bool _imageFailed = false;
  bool _imageLoaded = false;

  ImageStream? _imageStream;
  late final ImageStreamListener _imageStreamListener = ImageStreamListener(
    _handleImageLoaded,
    onError: _handleImageError,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `createLocalImageConfiguration` needs an inherited `MediaQuery`, only
    // available once dependencies are attached, so image resolution starts
    // here rather than in `initState`.
    _resolveImage();
  }

  @override
  void didUpdateWidget(DsAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A newly-assigned image gets a fresh load attempt instead of staying
    // stuck on a previous image's failure/loaded state.
    if (widget.image != oldWidget.image) {
      _imageFailed = false;
      _imageLoaded = false;
      _resolveImage();
    }
  }

  /// Resolves [widget.image] through Flutter's [ImageStream] so [_imageLoaded]
  /// tracks completion independently of [RemixAvatar] (which has no
  /// load-complete callback of its own — only `onBackgroundImageError`).
  /// This is what lets [build] keep the fallback content visible until the
  /// image has actually finished decoding, instead of swapping away from it
  /// the instant an [image] is supplied.
  void _resolveImage() {
    final oldStream = _imageStream;
    final image = widget.image;
    if (image == null) {
      oldStream?.removeListener(_imageStreamListener);
      _imageStream = null;
      return;
    }

    final newStream = image.resolve(createLocalImageConfiguration(context));
    if (newStream.key == oldStream?.key) {
      return;
    }
    oldStream?.removeListener(_imageStreamListener);
    _imageStream = newStream..addListener(_imageStreamListener);
  }

  void _handleImageLoaded(ImageInfo image, bool synchronousCall) {
    if (_imageLoaded) return;
    // Cached images resolve synchronously during `build`'s call stack —
    // `setState` isn't safe there, but the flag still needs to flip so the
    // very first `build` already renders the (already-available) image
    // instead of waiting for a frame that never invalidates it.
    if (synchronousCall) {
      _imageLoaded = true;
    } else {
      setState(() => _imageLoaded = true);
    }
  }

  void _handleImageError(Object error, StackTrace? stackTrace) {
    widget.onImageError?.call(error, stackTrace);
    if (!_imageFailed) {
      setState(() => _imageFailed = true);
    }
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = resolveDsAvatarStyle(
      shape: widget.shape,
      variant: widget.variant,
      size: widget.size,
    ).merge(widget.style);

    // An `image` is handed to `RemixAvatar` as soon as it's supplied (and
    // hasn't failed) so it can start loading — but fallback content only
    // hides once it's actually finished decoding, so callers see the
    // fallback while a photo is in flight instead of a blank avatar.
    final hasUsableImage = widget.image != null && !_imageFailed;
    final showImage = hasUsableImage && _imageLoaded;

    return RemixAvatar(
      backgroundImage: hasUsableImage ? widget.image : null,
      onBackgroundImageError: hasUsableImage ? _handleImageError : null,
      label: showImage || widget.label == null
          ? null
          : _resolveDsAvatarLabelText(widget.label!),
      icon: showImage || widget.label != null ? null : widget.icon,
      style: resolvedStyle,
      styleSpec: widget.styleSpec,
    );
  }
}
