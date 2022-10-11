import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';

enum InputSize { small, medium, large }

class FlutterInputElement extends WidgetElement {
  FlutterInputElement(BindingContext? context) : super(context);

  TextEditingController controller = TextEditingController();

  String inputSize = 'medium';

  bool checked = false;

  String get value => controller.value.text;

  set value(String? value) {
    if (value == null) return;
    controller.value = TextEditingValue(text: value);
  }

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'value':
        return controller.value.text;
      case 'checked':
        return checked;
    }
    return super.getBindingProperty(key);
  }

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'checked':
        checked = value;
        break;
      case 'value':
        this.value = value;
        break;
    }
    super.setBindingProperty(key, value);
  }

  @override
  void setAttribute(String key, String value) {
    switch (key) {
      case 'size':
        inputSize = value;
        break;
      case 'checked':
        print('value:');
        checked = value == 'true';
        break;
      case 'value':
        this.value = value;
        break;
    }
    super.setAttribute(key, value);
  }

  double getFontSize() {
    switch (inputSize) {
      case 'small':
        return 14;
      case 'large':
        return 18;
      case 'medium':
      default:
        return 16;
    }
  }

  TextInputType? getKeyboardType() {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
    }
    return TextInputType.text;
  }

  String get type => getAttribute('type') ?? 'text';

  String get placeholder => getAttribute('placeholder') ?? '';

  String? get label => getAttribute('label');

  bool get disabled => getAttribute('disabled') == 'disabled';

  List<TextInputFormatter>? getInputFormatters() {
    switch (type) {
      case 'number':
        return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  Widget createInput(BuildContext context) {
    FlutterFormElementContext? formContext = context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
    }

    InputDecoration decoration = InputDecoration(
      label: label != null ? Text(label!) : null,
      border: null,
      hintText: placeholder,
      suffixIcon: controller.value.text.isNotEmpty
          ? IconButton(
              iconSize: 14,
              onPressed: () {
                setState(() {
                  controller.clear();
                  InputEvent inputEvent = InputEvent(inputType: '', data: '');
                  dispatchEvent(inputEvent);
                });
              },
              icon: Icon(Icons.clear),
            )
          : null,
    );

    if (formContext != null) {
      return TextFormField(
        controller: controller,
        enabled: !disabled,
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        style: TextStyle(fontFamily: renderStyle.fontFamily?.join(' '), fontSize: getFontSize()),
        onChanged: onChanged,
        decoration: decoration,
      );
    }

    return TextField(
      controller: controller,
      enabled: !disabled,
      style: TextStyle(fontFamily: renderStyle.fontFamily?.join(' '), fontSize: getFontSize()),
      onChanged: onChanged,
      keyboardType: getKeyboardType(),
      inputFormatters: getInputFormatters(),
      onSubmitted: (String value) {
        if (type == 'search') {
          dispatchEvent(Event('search'));
        }
      },
      decoration: decoration,
    );
  }

  double getCheckboxSize() {
    switch (inputSize) {
      case 'small':
        return 0.7;
      case 'large':
        return 1.4;
      case 'medium':
      default:
        return 1;
    }
  }

  Widget createCheckBox(BuildContext context) {
    return Transform.scale(
      child: Checkbox(
          value: checked,
          onChanged: disabled
              ? null
              : (bool? newValue) {
                  setState(() {
                    checked = newValue!;
                    dispatchEvent(Event('change'));
                  });
                }),
      scale: getCheckboxSize(),
    );
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    if (type == 'checkbox') {
      return createCheckBox(context);
    }
    return Focus(
      onFocusChange: (bool isFocus) {
        if (isFocus) {
          ownerDocument.focusedElement = this;
        } else if (ownerDocument.focusedElement == this) {
          ownerDocument.focusedElement = null;
        }
      },
      child: createInput(context),
    );
  }
}
