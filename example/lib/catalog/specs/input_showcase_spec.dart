import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInputShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input',
    // One entry per InputType (all InputVariant.text) plus the structurally
    // different InputVariant.file drop target — grouping type and variant
    // together here since both answer "what kind of input is this?" and
    // ComponentShowcaseSpec only has room for one variants-shaped section.
    variantsBuilder: () => [
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'Text', type: InputType.text),
      ),
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'Email', type: InputType.email),
      ),
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'Password', type: InputType.password),
      ),
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'Number', type: InputType.number),
      ),
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'Phone', type: InputType.phone),
      ),
      const SizedBox(
        width: 160,
        child: Input(placeholder: 'URL', type: InputType.url),
      ),
      const Input(variant: InputVariant.file),
    ],
    sizesBuilder: () => InputSize.values
        .map(
          (size) => SizedBox(
            width: 160,
            child: Input(placeholder: size.name, size: size),
          ),
        )
        .toList(),
    // The first entry is backed by local state (`_InteractiveInput` below)
    // so typing into it in the running app actually updates its text —
    // same rationale as Switch/Checkbox's interactive showcase entries.
    // "focused" uses `autofocus: true` to demonstrate the real live-focus
    // style rather than a fake showcase-only override (Input derives
    // focus from a real FocusNode, it has no showcase escape hatch).
    // disabled/invalid are explicit constructor flags, so a static
    // instance is enough to demonstrate them.
    statesBuilder: () => const [
      SizedBox(width: 160, child: _InteractiveInput()),
      SizedBox(
        width: 160,
        child: Input(placeholder: 'Focused', autofocus: true),
      ),
      SizedBox(
        width: 160,
        child: Input(placeholder: 'Disabled', disabled: true),
      ),
      SizedBox(
        width: 160,
        child: Input(placeholder: 'Invalid', invalid: true),
      ),
      Input(variant: InputVariant.file, disabled: true),
    ],
  );
}

class _InteractiveInput extends StatefulWidget {
  const _InteractiveInput();

  @override
  State<_InteractiveInput> createState() => _InteractiveInputState();
}

class _InteractiveInputState extends State<_InteractiveInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Input(
      controller: _controller,
      placeholder: 'Enabled — try typing',
      onChanged: (_) => setState(() {}),
    );
  }
}
