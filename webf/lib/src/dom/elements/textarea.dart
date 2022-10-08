import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart';

const TEXTAREA = 'TEXTAREA';

class FlutterTextAreaElement extends WidgetElement {
  FlutterTextAreaElement(super.context);

  TextEditingController controller = TextEditingController();

  String get value => controller.value.text;
  set value(String? value) {
    if (value == null) return;
    controller.value = TextEditingValue(text: value);
  }

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'value':
        return value;
    }
    return super.getBindingProperty(key);
  }

  @override
  void setBindingProperty(String key, value) {
    switch(key) {
      case 'value':
        this.value = value;
        break;
    }
    super.setBindingProperty(key, value);
  }

  @override
  void setAttribute(String key, String value) {
    switch(key) {
      case 'value':
        this.value = value;
        break;
    }
    super.setAttribute(key, value);
  }

  int? get maxLength {
    String? value = getAttribute('maxLength');
    if (value != null) return int.parse(value);
    return null;
  }

  bool get disabled {
    return getAttribute('disabled') == 'disabled';
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
    }

    return Focus(
      child: TextField(
          enabled: !disabled,
          controller: controller,
          decoration: InputDecoration(border: InputBorder.none),
          onChanged: onChanged,
          minLines: 3,
          maxLines: 5,
          maxLength: maxLength,
          keyboardType: TextInputType.multiline),
      onFocusChange: (bool isFocus) {
        if (isFocus) {
          ownerDocument.focusedElement = this;
        } else {
          ownerDocument.focusedElement = null;
        }
      },
    );
  }
}
