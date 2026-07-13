import 'component_showcase_spec.dart';
import 'specs/avatar_group_showcase_spec.dart';
import 'specs/avatar_showcase_spec.dart';
import 'specs/badge_showcase_spec.dart';
import 'specs/button_showcase_spec.dart';
import 'specs/checkbox_showcase_spec.dart';
import 'specs/label_showcase_spec.dart';
import 'specs/progress_showcase_spec.dart';
import 'specs/radio_showcase_spec.dart';
import 'specs/separator_showcase_spec.dart';
import 'specs/skeleton_showcase_spec.dart';
import 'specs/slider_showcase_spec.dart';
import 'specs/spinner_showcase_spec.dart';
import 'specs/switch_showcase_spec.dart';
import 'specs/toggle_showcase_spec.dart';

/// Maps a component's display name to a function building its
/// ComponentShowcaseSpec. Kept as a function (not a pre-built spec) so
/// specs are only constructed when their showcase page is opened.
/// New components are registered here, one line per component, keyed
/// alphabetically for readability (iteration order in CatalogHomePage
/// sorts explicitly, so registration order here does not matter).
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Avatar': buildAvatarShowcaseSpec,
  'Avatar Group': buildAvatarGroupShowcaseSpec,
  'Badge': buildBadgeShowcaseSpec,
  'Button': buildButtonShowcaseSpec,
  'Checkbox': buildCheckboxShowcaseSpec,
  'Label': buildLabelShowcaseSpec,
  'Progress': buildProgressShowcaseSpec,
  'Radio': buildRadioShowcaseSpec,
  'Separator': buildSeparatorShowcaseSpec,
  'Skeleton': buildSkeletonShowcaseSpec,
  'Slider': buildSliderShowcaseSpec,
  'Spinner': buildSpinnerShowcaseSpec,
  'Switch': buildSwitchShowcaseSpec,
  'Toggle': buildToggleShowcaseSpec,
};
