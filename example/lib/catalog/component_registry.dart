import 'component_showcase_spec.dart';

/// Maps a component's display name to a function building its
/// ComponentShowcaseSpec. Kept as a function (not a pre-built spec) so
/// specs are only constructed when their showcase page is opened.
/// New components are registered here, one line per component, keyed
/// alphabetically for readability (iteration order in CatalogHomePage
/// sorts explicitly, so registration order here does not matter).
final Map<String, ComponentShowcaseSpec Function()> componentRegistry = {};
