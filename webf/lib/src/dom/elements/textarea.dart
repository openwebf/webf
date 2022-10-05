import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

const TEXTAREA = 'TEXTAREA';

class FlutterTextAreaElement extends WidgetElement {
  FlutterTextAreaElement(super.context);

  TextEditingController controller = TextEditingController();

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'value':
        return controller.value.text;
    }
    return super.getBindingProperty(key);
  }

  @override
  void setBindingProperty(String key, value) {
    super.setBindingProperty(key, value);
  }

  @override
  void setAttribute(String key, String value) {
    super.setAttribute(key, value);
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    bool enabled = !(getAttribute('disabled') == 'disabled');

    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
    }

    return Focus(
      child: TextField(
          enabled: enabled,
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none),
          onChanged: onChanged,
          minLines: 1,
          maxLines: 3,
          maxLength: 50,
          keyboardType: TextInputType.multiline),
      onFocusChange: (bool isFocus) {
        if (isFocus) {
          ownerDocument.focusedElement = this;
          print('$this focused');
        } else {
          ownerDocument.focusedElement = null;
        }
      },
    );
  }
}
