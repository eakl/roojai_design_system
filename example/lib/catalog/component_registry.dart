import 'component_showcase_spec.dart';
import 'specs/avatar_2_showcase_spec.dart';
import 'specs/badge_2_showcase_spec.dart';
import 'specs/button_2_showcase_spec.dart';
import 'specs/dialog_2_showcase_spec.dart';
import 'specs/icon_2_showcase_spec.dart';
import 'specs/icon_container_2_showcase_spec.dart';
import 'specs/input_2_showcase_spec.dart';
import 'specs/progress_2_showcase_spec.dart';
import 'specs/select_2_showcase_spec.dart';
import 'specs/separator_2_showcase_spec.dart';
import 'specs/skeleton_2_showcase_spec.dart';
import 'specs/slider_2_showcase_spec.dart';
import 'specs/spinner_2_showcase_spec.dart';
import 'specs/switch_2_showcase_spec.dart';
import 'specs/tabs_2_showcase_spec.dart';
import 'specs/toggle_2_showcase_spec.dart';

/// Maps a component's display name to a function building its
/// ComponentShowcaseSpec. Kept as a function (not a pre-built spec) so
/// specs are only constructed when their showcase page is opened.
/// New components are registered here, one line per component, keyed
/// alphabetically for readability (iteration order in CatalogHomePage
/// sorts explicitly, so registration order here does not matter).
///
/// Only `*_2` components are registered — the legacy (non-`_2`) components
/// have their exports commented out in `ui.dart` during the migration, so
/// registering their specs here would fail the build.
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {
  'Avatar 2': buildAvatar2ShowcaseSpec,
  'Badge 2': buildBadge2ShowcaseSpec,
  'Button 2': buildButton2ShowcaseSpec,
  'Dialog 2': buildDialog2ShowcaseSpec,
  'Icon 2': buildIcon2ShowcaseSpec,
  'Icon Container 2': buildIconContainer2ShowcaseSpec,
  'Input 2': buildInput2ShowcaseSpec,
  'Progress 2': buildProgress2ShowcaseSpec,
  'Select 2': buildSelect2ShowcaseSpec,
  'Separator 2': buildSeparator2ShowcaseSpec,
  'Skeleton 2': buildSkeleton2ShowcaseSpec,
  'Slider 2': buildSlider2ShowcaseSpec,
  'Spinner 2': buildSpinner2ShowcaseSpec,
  'Switch 2': buildSwitch2ShowcaseSpec,
  'Tabs 2': buildTabs2ShowcaseSpec,
  'Toggle 2': buildToggle2ShowcaseSpec,
};
