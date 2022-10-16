import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webf/webf.dart';

enum InputSize {
  small,
  medium,
  large,
}

class FlutterInputElement extends WidgetElement
    with BaseInputElement, BaseCheckBoxElement {
  BindingContext? buildContext;
  FlutterInputElement(BindingContext? context) : super(context) {
    buildContext = context;
  }
  @override
  Widget build(BuildContext context, List<Widget> children) {
    switch (type) {
      case 'checkbox':
        return createCheckBox(context);
      // TODO support more type
      default:
        return createInput(context);
    }
  }
}

/// create a base input widget containing input and textarea
mixin BaseInputElement on WidgetElement {
  TextEditingController controller = TextEditingController();
  String? oldValue;

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
    }
    return super.getBindingProperty(key);
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
  bool get disabled => getAttribute('disabled') != null;
  bool get autofocus => getAttribute('autofocus') != null;
  bool get readonly => getAttribute('readonly') != null;
  int? get maxLength {
    String? value = getAttribute('maxLength');
    if (value != null) return int.parse(value);
    return null;
  }

  List<TextInputFormatter>? getInputFormatters() {
    switch (type) {
      case 'number':
        return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  Color get color => renderStyle.color;
  double? get height => renderStyle.height.value;
  double? get width => renderStyle.width.value;

  Widget _createInputWidget(BuildContext context, int minLines, int maxLines) {
    FlutterFormElementContext? formContext =
        context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
    }

    InputDecoration decoration = InputDecoration(
      label: label != null ? Text(label!) : null,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      isDense: true,
      hintText: placeholder,
    );
    late Widget widget;
    if (formContext != null) {
      widget = TextFormField(
        controller: controller,
        enabled: !disabled && !readonly,
        style: TextStyle(
          fontFamily: renderStyle.fontFamily?.join(' '),
          color: color,
          fontSize: renderStyle.fontSize.value,
        ),
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        cursorColor: color,
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        decoration: decoration,
      );
    } else {
      widget = TextField(
        controller: controller,
        enabled: !disabled && !readonly,
        style: TextStyle(
          fontFamily: renderStyle.fontFamily?.join(' '),
          color: color,
          fontSize: renderStyle.fontSize.value,
        ),
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        cursorColor: color,
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
    return _wrapperBorder(widget);
  }

  // set default border and border radius
  Widget _wrapperBorder(Widget child) {
    List<BorderSide>? borderSides = renderStyle.borderSides;
    List<Radius>? radius = renderStyle.borderRadius;
    return Container(
      alignment: height != null ? Alignment.center : null,
      decoration: BoxDecoration(
        border: borderSides == null
            ? Border.all(
                width: 1,
                color: Color.fromRGBO(118, 118, 118, 1),
              )
            : null,
        borderRadius: borderSides == null && radius == null
            ? BorderRadius.circular(4)
            : null,
      ),
      child: child,
    );
  }

  Widget createInput(BuildContext context,
      {int minLines = 1, int maxLines = 1}) {
    return Focus(
      onFocusChange: (bool isFocus) {
        if (isFocus) {
          ownerDocument.focusedElement = this;
          oldValue = value;
        } else {
          if (ownerDocument.focusedElement == this) {
            ownerDocument.focusedElement = null;
          }
          if (oldValue != value) {
            dispatchEvent(Event('change'));
          }
        }
      },
      child: _createInputWidget(context, minLines, maxLines),
    );
  }
}

/// create a checkBox widget when input type='checkbox'
mixin BaseCheckBoxElement on WidgetElement {
  bool checked = false;
  bool get disabled => getAttribute('disabled') != null;

  @override
  void setBindingProperty(String key, value) {
    switch (key) {
      case 'checked':
        checked = value;
        break;
    }
    super.setBindingProperty(key, value);
  }

  @override
  void setAttribute(String key, String value) {
    switch (key) {
      case 'checked':
        checked = value == 'true';
    }
    super.setAttribute(key, value);
  }

  @override
  getBindingProperty(String key) {
    switch (key) {
      case 'checked':
        return checked;
    }
    return super.getBindingProperty(key);
  }

  double getCheckboxSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.value! / 18.0;
    }
    return 1.0;
  }

  Widget createCheckBox(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: renderStyle.width.value,
        height: renderStyle.height.value,
        child: Transform.scale(
          child: Checkbox(
            value: checked,
            onChanged: disabled
                ? null
                : (bool? newValue) {
                    setState(() {
                      checked = newValue!;
                      dispatchEvent(Event('change'));
                    });
                  },
          ),
          scale: getCheckboxSize(),
        ),
      ),
    );
  }
}
