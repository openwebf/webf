import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/widget.dart';
import 'package:webf/foundation.dart';

enum InputSize {
  small,
  medium,
  large,
}

class FlutterInputElement extends WidgetElement
    with BaseCheckBoxElement, BaseButtonElement, BaseInputElement, BaseTimeElement {
  BindingContext? buildContext;

  FlutterInputElement(BindingContext? context) : super(context) {
    buildContext = context;
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    switch (type) {
      case 'checkbox':
        return createCheckBox(context);
      case 'button':
      case 'submit':
        return createButton(context);
      case 'date':
      // case 'month':
      // case 'week':
      case 'time':
        return createTime(context);
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

  set value(value) {
    if (value == null) {
      controller.value = TextEditingValue.empty;
    } else {
      value = value.toString();
      if (controller.value.text != value) {
        controller.value = TextEditingValue(text: value.toString());
      }
    }
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['value'] = BindingObjectProperty(getter: () => value, setter: (value) => this.value = value);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['value'] = ElementAttributeProperty(getter: () => value, setter: (value) => this.value = value);
  }

  TextInputType? getKeyboardType() {
    if (this is FlutterTextAreaElement) {
      return TextInputType.multiline;
    }

    switch (type) {
      case 'number':
      case 'tel':
        return TextInputType.number;
      case 'url':
        return TextInputType.url;
      case 'email':
        return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }

  String get type => getAttribute('type') ?? 'text';

  String get placeholder => getAttribute('placeholder') ?? '';

  String? get label => getAttribute('label');

  bool get disabled => getAttribute('disabled') != null;

  bool get autofocus => getAttribute('autofocus') != null;

  bool get readonly => getAttribute('readonly') != null;

  List<BorderSide>? get borderSides => renderStyle.borderSides;

  // for type
  bool get isSearch => type == 'search';

  bool get isPassWord => type == 'password';

  bool _isFocus = false;

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

  double? get height => renderStyle.height.value;

  double? get width => renderStyle.width.value;

  TextStyle get _style => TextStyle(
        color: renderStyle.color,
        fontSize: renderStyle.fontSize.computedValue,
        fontWeight: renderStyle.fontWeight,
        fontFamily: renderStyle.fontFamily?.join(' '),
      );

  Widget _createInputWidget(BuildContext context, int minLines, int maxLines) {
    FlutterFormElementContext? formContext = context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
    }

    bool isInput = this is FlutterInputElement;

    InputDecoration decoration = InputDecoration(
        label: label != null ? Text(label!) : null,
        border: isInput && borderSides == null ? UnderlineInputBorder() : InputBorder.none,
        isDense: true,
        hintText: placeholder,
        suffix: isSearch && value.isNotEmpty && _isFocus
            ? SizedBox(
                width: 14,
                height: 14,
                child: IconButton(
                  iconSize: 14,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      InputEvent inputEvent = InputEvent(inputType: '', data: '');
                      dispatchEvent(inputEvent);
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              )
            : null);
    late Widget widget;
    if (formContext != null) {
      widget = TextFormField(
        controller: controller,
        enabled: !disabled && !readonly,
        style: _style,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        obscureText: isPassWord,
        cursorColor: renderStyle.caretColor,
        textInputAction: isSearch ? TextInputAction.search : TextInputAction.newline,
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        decoration: decoration,
      );
    } else {
      widget = TextField(
        controller: controller,
        enabled: !disabled && !readonly,
        style: _style,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        obscureText: isPassWord,
        cursorColor: renderStyle.caretColor,
        textInputAction: isSearch ? TextInputAction.search : TextInputAction.newline,
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        onSubmitted: (String value) {
          if (isSearch) {
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
    return Container(
      alignment: height != null ? Alignment.center : null,
      child: child,
    );
  }

  Widget createInput(BuildContext context, {int minLines = 1, int maxLines = 1}) {
    switch (type) {
      case 'hidden':
        return SizedBox(width: 0, height: 0);
    }
    return Focus(
      onFocusChange: (bool isFocus) {
        if (isSearch) {
          setState(() {
            _isFocus = isFocus;
          });
        }
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
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['checked'] = BindingObjectProperty(getter: () => checked, setter: (value) => checked = value);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['checked'] = ElementAttributeProperty(getter: () => checked.toString(), setter: (value) => checked = value == 'true');
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
              },
      ),
      scale: getCheckboxSize(),
    );
  }
}

/// create a button widget when input type is button or submit
mixin BaseButtonElement on WidgetElement {
  bool checked = false;
  String _value = '';

  bool get disabled => getAttribute('disabled') != null;

  @override
  void propertyDidUpdate(String key, value) {
    _setValue(key, value == null ? '' : value.toString());
    super.propertyDidUpdate(key, value);
  }

  @override
  void attributeDidUpdate(String key, String value) {
    _setValue(key, value);
    super.attributeDidUpdate(key, value);
  }

  void _setValue(String key, String value) {
    switch (key) {
      case 'value':
        if (_value != value) {
          _value = value;
        }
        break;
    }
  }

  TextStyle get _style => TextStyle(
        color: renderStyle.color,
        fontSize: renderStyle.fontSize.computedValue,
        fontWeight: renderStyle.fontWeight,
        fontFamily: renderStyle.fontFamily?.join(' '),
      );

  Widget createButton(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => renderStyle.backgroundColor),
        ),
        onPressed: () {
          var box = context.findRenderObject() as RenderBox;
          Offset globalOffset =
              box.globalToLocal(Offset(Offset.zero.dx, Offset.zero.dy));
          double clientX = globalOffset.dx;
          double clientY = globalOffset.dy;
          Event event = MouseEvent(EVENT_CLICK,
              clientX: clientX,
              clientY: clientY,
              view: ownerDocument.defaultView);
          dispatchEvent(event);
        },
        child: Text(_value, style: _style));
  }
}

/// create a time widget when input type is date,time,month,week
mixin BaseTimeElement on BaseInputElement {
  bool checked = false;

  Future<DateTime?> _showDialog(BuildContext context,
      {CupertinoDatePickerMode mode = CupertinoDatePickerMode.date}) async {
    DateTime? time;
    await showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              color: CupertinoColors.systemBackground.resolveFrom(context),
              child: SafeArea(
                top: false,
                child: CupertinoDatePicker(
                  initialDateTime: DateTime.now(),
                  mode: mode,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDate) {
                    time = newDate;
                  },
                ),
              ),
            ));
    return time;
  }

  Future<String?> _showPicker(BuildContext context) async {
    switch (type) {
      case 'date':
        DateTime? time;
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.iOS:
          case TargetPlatform.fuchsia:
            time = await _showDialog(context);
            break;
          default:
            time = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.parse('19700101'),
              lastDate: DateTime.parse('30000101'),
            );
        }
        return time != null ? DateFormat('yyyy-MM-dd').format(time) : null;
      case 'time':
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
          case TargetPlatform.iOS:
          case TargetPlatform.fuchsia:
            var time = await _showDialog(context, mode: CupertinoDatePickerMode.time);
            if (time != null) {
              var minute = time.minute.toString().padLeft(2, '0');
              var hour = time.hour.toString().padLeft(2, '0');
              return '$hour:$minute';
            }
            break;
          default:
            var time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (time != null) {
              var minute = time.minute.toString().padLeft(2, '0');
              var hour = time.hour.toString().padLeft(2, '0');
              return '$hour:$minute';
            }
        }
    }
    return null;
  }

  Widget createTime(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var time = await _showPicker(context);
        if (time != null)
          setState(() {
            value = time;
          });
      },
      child: AbsorbPointer(child: createInput(context)),
    );
  }
}
