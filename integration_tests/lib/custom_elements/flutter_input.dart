import 'package:flutter/material.dart';
import 'package:webf/dom.dart';
import 'package:webf/webf.dart';
import 'flutter_form.dart';

class FlutterInputElement extends WidgetElement {
  FlutterInputElement(BindingContext? context) : super(context);

  TextEditingController controller = TextEditingController();

  @override
  getBindingProperty(String key) {
    switch(key) {
      case 'value':
        return controller.value.text;
    }
    return super.getBindingProperty(key);
  }

  @override
  void setBindingProperty(String key, value) {
    switch(key) {
      case 'value':
        controller.value = TextEditingValue(text: value);
        break;
    }
    super.setBindingProperty(key, value);
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    FlutterFormElementContext? formContext = context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    return TextField(
      controller: controller,
      style: TextStyle(
        fontFamily: renderStyle.fontFamily?.join(' '),
          fontSize: renderStyle.fontSize.computedValue),
      onChanged: (String newValue) {
        setState(() {
          InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
          dispatchEvent(inputEvent);
        });
      },
      onSubmitted: (String value) {
        dispatchEvent(Event('search'));
      },
      decoration: InputDecoration(

        border: OutlineInputBorder(),
        hintText: getAttribute('placeholder') ?? '',
        suffixIcon: controller.value.text.isNotEmpty ? IconButton(
          iconSize: 14,
          onPressed: () {
            setState(() {
              controller.clear();
              InputEvent inputEvent = InputEvent(inputType: '', data: '');
              dispatchEvent(inputEvent);
            });
          },
          icon: Icon(Icons.clear),
        ) : null,
      ),
    );
  }
}
