import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildTextareaShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Textarea',
    // The first entry is backed by local state (`_InteractiveTextarea`
    // below) so typing into it in the running app actually updates its
    // text — same rationale as Input's interactive showcase entry.
    // "focused" uses `autofocus: true` to demonstrate the real live-focus
    // style rather than a fake showcase-only override (Textarea derives
    // focus from a real FocusNode, same as Input, with no showcase escape
    // hatch). disabled/invalid are explicit constructor flags, so a
    // static instance is enough to demonstrate them.
    statesBuilder: () => const [
      SizedBox(width: 220, child: _InteractiveTextarea()),
      SizedBox(
        width: 220,
        child: Textarea(placeholder: 'Focused', autofocus: true),
      ),
      SizedBox(
        width: 220,
        child: Textarea(placeholder: 'Disabled', disabled: true),
      ),
      SizedBox(
        width: 220,
        child: Textarea(placeholder: 'Invalid', invalid: true),
      ),
    ],
  );
}

class _InteractiveTextarea extends StatefulWidget {
  const _InteractiveTextarea();

  @override
  State<_InteractiveTextarea> createState() => _InteractiveTextareaState();
}

class _InteractiveTextareaState extends State<_InteractiveTextarea> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Textarea(
      controller: _controller,
      placeholder: 'Enabled — try typing',
      onChanged: (_) => setState(() {}),
    );
  }
}
