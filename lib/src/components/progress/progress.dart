import 'package:flutter/widgets.dart';

import '../../theme/app_tokens.dart';
import '../../tokens/primitives/app_radius.dart';
import '../../tokens/primitives/app_spacing.dart';
import '../../tokens/semantic/semantic_colors.dart';
import '../../tokens/semantic/semantic_typography.dart';
import 'progress_size.dart';

/// A determinate progress bar built from low-level primitives (`Stack` +
/// `DecoratedBox`, no Material `LinearProgressIndicator`).
///
/// Structurally, [Progress] is always exactly two layers:
/// - the **track**, the full-width background rail ([_ProgressTrack]),
/// - the **indicator**, the filled portion drawn on top of it
///   ([_ProgressIndicator]), sized by [percent].
///
/// Both layers default to semantic tokens ([SemanticColors.surface]) but
/// each accepts an independent color override ([trackColor],
/// [indicatorColor]) as an escape hatch, the same pattern [Badge] uses for
/// its `backgroundColor`/`foregroundColor` overrides.
///
/// [Progress] also has two mutually exclusive, optional annotation modes
/// (see the assertion in the constructor — supplying fields from both at
/// once is a programming error, not a runtime fallback):
/// - **single label/value** ([label]/[value]): one line above the track,
///   [label] pinned to the left edge and [value] pinned to the right edge.
/// - **min/max label/value** ([minLabel]/[minValue]/[maxLabel]/[maxValue]):
///   a line of labels above the track ([minLabel] left, [maxLabel] right)
///   and a line of values below it ([minValue] left, [maxValue] right) —
///   e.g. annotating the scale's endpoints independently of the label
///   line, the way a range control's bounds are usually captioned.
///
/// Unlike [Button]/[Badge], [Progress] has no interactive or variant axis
/// — it is always non-interactive, so there is no `_style_resolvers.dart`
/// part file; the handful of single-axis resolvers below are kept inline,
/// the same convention [Spinner] and [Label] use for the same reason.
class Progress extends StatelessWidget {
  const Progress({
    super.key,
    required this.percent,
    this.size = ProgressSize.md,
    this.trackColor,
    this.indicatorColor,
    this.label,
    this.value,
    this.minLabel,
    this.minValue,
    this.maxLabel,
    this.maxValue,
    this.width = 200,
  })  : assert(
          percent >= 0 && percent <= 100,
          'percent must be within 0-100 (got $percent).',
        ),
        assert(
          !((label != null || value != null) &&
              (minLabel != null ||
                  minValue != null ||
                  maxLabel != null ||
                  maxValue != null)),
          'Progress supports either label/value or '
          'minLabel/minValue/maxLabel/maxValue — not both at once.',
        );

  /// How full the indicator is, from 0 to 100. Unlike [Button.loading] or
  /// [Badge]'s optional slots, this is the one value [Progress] cannot
  /// sensibly default — a progress bar with no progress to show isn't a
  /// meaningful default, so it's a required constructor param.
  final double percent;

  /// Physical size — see [ProgressSize].
  final ProgressSize size;

  /// Escape hatch overriding the track's fill color. When null, resolves
  /// to `colors.surface.alternative`.
  final Color? trackColor;

  /// Escape hatch overriding the indicator's fill color. When null,
  /// resolves to `colors.surface.inverted`.
  final Color? indicatorColor;

  /// Single-mode: text pinned to the left edge, on the line above the
  /// track. Mutually exclusive with the min/max fields below.
  final String? label;

  /// Single-mode: text pinned to the right edge, on the same line as
  /// [label] above the track. Mutually exclusive with the min/max fields
  /// below.
  final String? value;

  /// Min/max-mode: text pinned to the left edge, on the line above the
  /// track. Mutually exclusive with [label]/[value].
  final String? minLabel;

  /// Min/max-mode: text pinned to the left edge, on the line below the
  /// track. Mutually exclusive with [label]/[value].
  final String? minValue;

  /// Min/max-mode: text pinned to the right edge, on the line above the
  /// track. Mutually exclusive with [label]/[value].
  final String? maxLabel;

  /// Min/max-mode: text pinned to the right edge, on the line below the
  /// track. Mutually exclusive with [label]/[value].
  final String? maxValue;

  /// Fixed width of the whole bar (track plus any label/value rows).
  /// Unlike [Button]/[Badge], a progress bar has no natural intrinsic
  /// width derived from its content — it is meant to stretch to fill a
  /// slot in a layout — so, absent a surrounding constraint, it needs an
  /// explicit width rather than sizing to its (non-existent) children.
  final double width;

  @override
  Widget build(BuildContext context) {
    // --- Tokens -----------------------------------------------------------
    final colors = AppTokens.of(context).colors;
    final typography = AppTokens.of(context).typography;

    // --- Resolved properties ------------------------------------------------
    final trackHeight = _resolveTrackHeight(size);
    final textStyle = _resolveTextStyle(typography, size);
    final resolvedTrackColor = trackColor ?? colors.surface.alternative;
    final resolvedIndicatorColor = indicatorColor ?? colors.surface.inverted;
    // Labels read at a slightly stronger emphasis than the values they
    // annotate, mirroring how ShowcaseSection pairs an overline label with
    // muted body text — see component_showcase_page.dart.
    final labelStyle = textStyle.copyWith(color: colors.content.secondary);
    final valueStyle = textStyle.copyWith(color: colors.content.muted);
    final fillFraction = (percent / 100).clamp(0.0, 1.0);

    // --- Layout ---------------------------------------------------------------
    final hasSingleRow = label != null || value != null;
    final hasMinMaxLabelRow = minLabel != null || maxLabel != null;
    final hasMinMaxValueRow = minValue != null || maxValue != null;

    final track = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radiusFull),
      child: SizedBox(
        height: trackHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ProgressTrack(color: resolvedTrackColor),
            _ProgressIndicator(
              color: resolvedIndicatorColor,
              fraction: fillFraction,
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasSingleRow) ...[
            _ProgressEdgeRow(
              leftText: label,
              leftStyle: labelStyle,
              rightText: value,
              rightStyle: valueStyle,
            ),
            const SizedBox(height: AppSpacing.spacing4),
          ],
          if (hasMinMaxLabelRow) ...[
            _ProgressEdgeRow(
              leftText: minLabel,
              leftStyle: labelStyle,
              rightText: maxLabel,
              rightStyle: labelStyle,
            ),
            const SizedBox(height: AppSpacing.spacing4),
          ],
          track,
          if (hasMinMaxValueRow) ...[
            const SizedBox(height: AppSpacing.spacing4),
            _ProgressEdgeRow(
              leftText: minValue,
              leftStyle: valueStyle,
              rightText: maxValue,
              rightStyle: valueStyle,
            ),
          ],
        ],
      ),
    );
  }
}

/// The track layer: a plain, full-bleed fill. Rounding/clipping is the
/// parent [ClipRRect]'s job (shared with [_ProgressIndicator]), so this
/// widget only ever paints a flat rectangle of color.
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => ColoredBox(color: color);
}

/// The indicator layer: a left-aligned fill sized to [fraction] (0.0-1.0)
/// of the track's width, stacked on top of [_ProgressTrack].
class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.color, required this.fraction});

  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: fraction,
      child: ColoredBox(color: color),
    );
  }
}

/// One line of text pinned to each edge — the shared shape behind the
/// single label/value row and both min/max rows. Either side may be null,
/// in which case that edge is simply left blank rather than the row
/// re-centering the remaining text, so label/value rows always line up
/// with the min/max rows above/below them regardless of which sides are
/// populated.
class _ProgressEdgeRow extends StatelessWidget {
  const _ProgressEdgeRow({
    required this.leftText,
    required this.leftStyle,
    required this.rightText,
    required this.rightStyle,
  });

  final String? leftText;
  final TextStyle leftStyle;
  final String? rightText;
  final TextStyle rightStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: leftText != null
                ? Text(leftText!, style: leftStyle)
                : const SizedBox.shrink(),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: rightText != null
                ? Text(rightText!, style: rightStyle)
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// Style/layout resolvers for Progress. One pure function per resolved
// property, same convention as Button/Badge's `_resolve*` split — kept
// inline here (no separate `_style_resolvers.dart` part file) since
// Progress has no variant x state matrix, just two small, single-axis
// resolvers, the same shape as Spinner's/Label's inline resolvers.

double _resolveTrackHeight(ProgressSize size) {
  switch (size) {
    case ProgressSize.sm:
      return 6;
    case ProgressSize.md:
      return 8;
    case ProgressSize.lg:
      return 10;
  }
}

TextStyle _resolveTextStyle(SemanticTypography typography, ProgressSize size) {
  switch (size) {
    case ProgressSize.sm:
      return typography.captionSm;
    case ProgressSize.md:
      return typography.captionMd;
    case ProgressSize.lg:
      return typography.labelSm;
  }
}
