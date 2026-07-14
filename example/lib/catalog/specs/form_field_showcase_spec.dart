import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildFormFieldShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Form Field',
    // AppFormField has no variant/size axis of its own — only the states
    // below, mirroring how the wrapped Input's own disabled/invalid state
    // must be passed by the caller in lockstep (see `child`'s doc).
    statesBuilder: () => const [
      AppFormField(
        label: 'Email',
        required: true,
        helperText: "We'll never share your email.",
        child: Input(placeholder: 'you@example.com'),
      ),
      AppFormField(
        label: 'Email',
        required: true,
        errorText: 'Enter a valid email address.',
        child: Input(placeholder: 'you@example.com', invalid: true),
      ),
      AppFormField(
        label: 'Email',
        disabled: true,
        child: Input(placeholder: 'you@example.com', disabled: true),
      ),
    ],
  );
}
