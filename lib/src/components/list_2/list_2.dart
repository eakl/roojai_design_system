import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

import '../../theme/light/colors.dart';
import '../../theme/light/radius.dart';
import '../../theme/light/spacing.dart';
import '../separator_2/separator_2.dart';
import 'list_2_variants.dart';
import 'list_item_2.dart';

part 'list_2_style_resolver.dart';

class DsList extends StatelessWidget {
  const DsList({
    super.key,
    required this.children,
    this.header,
    this.bordered = false,
    this.separated = false,
    this.size = DsListSize.md,
  });

  /// The rows shown in the list body, in order.
  final List<DsListItem> children;

  /// Optional row shown above the body, visually set apart by an
  /// unconditional separator — independent of [separated].
  final DsListItem? header;

  /// Outer border treatment. `true` draws a `$radius008`/`$borderStrong`
  /// border around the whole container (background stays transparent),
  /// same tokens `card_2`'s `bordered` variant uses. `false` draws
  /// neither — the list sits flush in its parent's surface.
  final bool bordered;

  /// Whether consecutive body rows are separated by a `DsSeparator`
  /// (`separator_2`). Does not affect the header/body divider, which is
  /// always drawn when [header] is set.
  final bool separated;

  /// Physical size — see [DsListSize]. Controls the body's outer padding
  /// and the gap between rows.
  final DsListSize size;

  @override
  Widget build(BuildContext context) {
    final containerStyle = resolveDsListStyle(bordered: bordered, size: size);
    final gap = switch (size) {
      DsListSize.none => $spacing000.resolve(context),
      DsListSize.sm => $spacing008.resolve(context),
      DsListSize.md => $spacing012.resolve(context),
      DsListSize.lg => $spacing016.resolve(context),
    };

    final rows = <Widget>[];
    if (header != null) {
      rows.add(header!);
      rows.add(const DsSeparator());
    }
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        if (separated) {
          rows.add(SizedBox(height: gap / 2));
          rows.add(const DsSeparator());
          rows.add(SizedBox(height: gap / 2));
        } else {
          rows.add(SizedBox(height: gap));
        }
      }
      rows.add(children[i]);
    }

    return Box(
      style: containerStyle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }
}
