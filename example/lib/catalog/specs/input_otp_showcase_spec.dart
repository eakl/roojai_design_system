import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart';

import '../component_showcase_spec.dart';

ComponentShowcaseSpec buildInputOtpShowcaseSpec() {
  return ComponentShowcaseSpec(
    title: 'Input OTP',
    // The first entry is backed by local state (`_InteractiveInputOtp`
    // below) so typing digits into it in the running app actually fills
    // the boxes and pasting a full code fills them all at once — same
    // rationale as Input's interactive showcase entry. "focused" uses
    // `autofocus: true` to demonstrate the real live-focus ring rather
    // than a fake showcase-only override (InputOtp derives focus from a
    // real FocusNode, same as Input, so it has no showcase escape hatch).
    // disabled/invalid are explicit constructor flags, so a static
    // instance with pre-filled text is enough to demonstrate them.
    statesBuilder: () => [
      const _InteractiveInputOtp(),
      const _InputOtpWithControllerText(text: '123', autofocus: true),
      const _InputOtpWithControllerText(text: '123456', disabled: true),
      const _InputOtpWithControllerText(text: '12', invalid: true),
    ],
  );
}

class _InteractiveInputOtp extends StatefulWidget {
  const _InteractiveInputOtp();

  @override
  State<_InteractiveInputOtp> createState() => _InteractiveInputOtpState();
}

class _InteractiveInputOtpState extends State<_InteractiveInputOtp> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputOtp(
      length: 6,
      controller: _controller,
      onChanged: (_) => setState(() {}),
    );
  }
}

/// A non-interactive box row pre-filled to a fixed value, for the
/// "focused"/"disabled"/"invalid" showcase entries — none of those need
/// to actually respond to typing, just to display the state correctly.
class _InputOtpWithControllerText extends StatefulWidget {
  const _InputOtpWithControllerText({
    required this.text,
    this.autofocus = false,
    this.disabled = false,
    this.invalid = false,
  });

  final String text;
  final bool autofocus;
  final bool disabled;
  final bool invalid;

  @override
  State<_InputOtpWithControllerText> createState() =>
      _InputOtpWithControllerTextState();
}

class _InputOtpWithControllerTextState
    extends State<_InputOtpWithControllerText> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputOtp(
      length: 6,
      controller: _controller,
      autofocus: widget.autofocus,
      disabled: widget.disabled,
      invalid: widget.invalid,
    );
  }
}
