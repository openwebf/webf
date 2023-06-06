/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/widget.dart';
import 'package:webf/foundation.dart';

enum InputSize {
  small,
  medium,
  large,
}

const Map<String, dynamic> _inputDefaultStyle = {
  BORDER: '2px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
  WIDTH: '140px',
};

const Map<String, dynamic> _checkboxDefaultStyle = {
  MARGIN: '3px 3px 3px 4px',
  PADDING: INITIAL,
  DISPLAY: INLINE_BLOCK,
  BORDER: '0'
};

class FlutterInputElement extends WidgetElement
    with BaseCheckBoxElement, BaseButtonElement, BaseInputElement, BaseTimeElement {
  BindingContext? buildContext;

  FlutterInputElement(BindingContext? context) : super(context) {
    buildContext = context;
  }

  @override
  Map<String, dynamic> get defaultStyle {
    switch (type) {
      case 'text':
      case 'time':
        return _inputDefaultStyle;
      case 'checkbox':
        return _checkboxDefaultStyle;
    }
    return super.defaultStyle;
  }

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      blur();
    });
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      focus();
    });
  }

  @override
  void blur() {
    _focusNode?.unfocus();
  }

  @override
  void focus() {
    _focusNode?.requestFocus();
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

  // Whether value has been changed by user.
  // https://www.w3.org/TR/2010/WD-html5-20101019/the-input-element.html#concept-input-value-dirty-flag
  bool hasDirtyValue = false;

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
    hasDirtyValue = true;
  }

  @override
  void initState() {
    _focusNode ??= FocusNode();
    _focusNode!.addListener(handleFocusChange);
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['value'] = BindingObjectProperty(getter: () => value, setter: (value) => this.value = value);
    properties['type'] = BindingObjectProperty(getter: () => type, setter: (value) => type = value);
    properties['disabled'] = BindingObjectProperty(getter: () => disabled, setter: (value) => disabled = value);
    properties['placeholder'] =
        BindingObjectProperty(getter: () => placeholder, setter: (value) => placeholder = value);
    properties['label'] = BindingObjectProperty(getter: () => label, setter: (value) => label = value);
    properties['readonly'] = BindingObjectProperty(getter: () => readonly, setter: (value) => readonly = value);
    properties['autofocus'] = BindingObjectProperty(getter: () => autofocus, setter: (value) => autofocus = value);
    properties['defaultValue'] =
        BindingObjectProperty(getter: () => defaultValue, setter: (value) => defaultValue = value);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['value'] = ElementAttributeProperty(getter: () => value, setter: (value) => this.value = value);
    attributes['disabled'] =
        ElementAttributeProperty(getter: () => disabled.toString(), setter: (value) => disabled = value);
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
  void set type(value) {
    internalSetAttribute('type', value?.toString() ?? '');
    resetInputDefaultStyle();
  }

  void resetInputDefaultStyle() {
    switch (type) {
      case 'checkbox':
        {
          _checkboxDefaultStyle.forEach((key, value) {
            style.setProperty(key, value);
          });
          break;
        }
      default:
        _inputDefaultStyle.forEach((key, value) {
          style.setProperty(key, value);
        });
        break;
    }
    style.flushPendingProperties();
  }

  String get placeholder => getAttribute('placeholder') ?? '';
  set placeholder(value) {
    internalSetAttribute('placeholder', value?.toString() ?? '');
  }

  String? get label => getAttribute('label');
  set label(value) {
    internalSetAttribute('label', value?.toString() ?? '');
  }

  String? get defaultValue => getAttribute('defaultValue') ?? getAttribute('value') ?? '';
  set defaultValue(String? text) {
    internalSetAttribute('defaultValue', text?.toString() ?? '');
    // Only set value when dirty flag is false.
    if (!hasDirtyValue) {
      value = text;
    }
  }

  bool _disabled = false;
  bool get disabled => _disabled;
  set disabled(value) {
    if (value is String) {
      _disabled = value == 'true';
      return;
    }
    _disabled = value == true;
  }

  bool get autofocus => getAttribute('autofocus') != null;
  set autofocus(value) {
    internalSetAttribute('autofocus', value?.toString() ?? '');
  }

  bool get readonly => getAttribute('readonly') != null;
  set readonly(value) {
    internalSetAttribute('readonly', value?.toString() ?? '');
  }

  List<BorderSide>? get borderSides => renderStyle.borderSides;

  // for type
  bool get isSearch => type == 'search';

  bool get isPassWord => type == 'password';

  bool get _isFocus => _focusNode?.hasFocus ?? false;

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

  double get fontSize => renderStyle.fontSize.computedValue;

  double get lineHeight => renderStyle.lineHeight.computedValue;

  /// input is 1 and textarea is 3
  int minLines = 1;

  /// input is 1 and textarea is 5
  int maxLines = 1;

  /// Use leading to support line height.
  /// 1. LineHeight must greater than fontSize
  /// 2. LineHeight must less than height in input but textarea
  double get leading => lineHeight > fontSize &&
          (maxLines != 1 || height == null || lineHeight < renderStyle.height.computedValue)
      ? (lineHeight - fontSize - _defaultPadding * 2) / fontSize
      : 0;

  TextStyle get _textStyle => TextStyle(
        color: renderStyle.color.value,
        fontSize: fontSize,
        fontWeight: renderStyle.fontWeight,
        fontFamily: renderStyle.fontFamily?.join(' '),
      );

  StrutStyle get _textStruct => StrutStyle(
    leading: leading,
  );

  final double _defaultPadding = 0;

  Widget _createInputWidget(BuildContext context) {
    FlutterFormElementContext? formContext = context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    onChanged(String newValue) {
      setState(() {
        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
      hasDirtyValue = true;
    }

    InputDecoration decoration = InputDecoration(
        label: label != null ? Text(label!) : null,
        border: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.fromLTRB(0, _defaultPadding, 0, _defaultPadding),
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
        style: _textStyle,
        strutStyle: _textStruct,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        textAlign: renderStyle.textAlign,
        focusNode: _focusNode,
        obscureText: isPassWord,
        cursorColor: renderStyle.caretColor ?? renderStyle.color.value,
        textInputAction: isSearch ? TextInputAction.search : TextInputAction.newline,
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        decoration: decoration,
      );
    } else {
      widget = TextField(
        controller: controller,
        enabled: !disabled && !readonly,
        style: _textStyle,
        strutStyle: _textStruct,
        autofocus: autofocus,
        minLines: minLines,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        textAlign: renderStyle.textAlign,
        focusNode: _focusNode,
        obscureText: isPassWord,
        cursorColor: renderStyle.caretColor ?? renderStyle.color.value,
        cursorRadius: Radius.circular(4),
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
    return widget;
  }

  @override
  void didDetachRenderer() {
    super.didDetachRenderer();
    _focusNode?.removeListener(handleFocusChange);
    _focusNode?.unfocus();
  }

  FocusNode? _focusNode;

  void handleFocusChange() {
    if (_isFocus) {
      ownerDocument.focusedElement = this;
      oldValue = value;
      scheduleMicrotask(() {
        dispatchEvent(FocusEvent(EVENT_FOCUS, relatedTarget: this));
      });
    } else {
      if (ownerDocument.focusedElement == this) {
        ownerDocument.focusedElement = null;
      }
      if (oldValue != value) {
        scheduleMicrotask(() {
          dispatchEvent(Event('change'));
        });
      }
      scheduleMicrotask(() {
        dispatchEvent(FocusEvent(EVENT_BLUR, relatedTarget: this));
      });
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    _focusNode?.dispose();
  }

  Widget _wrapInputHeight(Widget widget) {
    double? heightValue = renderStyle.height.value;

    if (heightValue == null) return widget;

    return SizedBox(
        child: Center(
          child: widget,
        ),
        height: renderStyle.height.computedValue);
  }

  Widget createInput(BuildContext context, {int minLines = 1, int maxLines = 1}) {
    this.minLines = minLines;
    this.maxLines = maxLines;
    switch (type) {
      case 'hidden':
        return SizedBox(width: 0, height: 0);
    }
    return _wrapInputHeight(_createInputWidget(context));
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

    attributes['checked'] =
        ElementAttributeProperty(getter: () => checked.toString(), setter: (value) => checked = value == 'true');
  }

  double getCheckboxSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.computedValue / 18.0;
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
        color: renderStyle.color.value,
        fontSize: renderStyle.fontSize.computedValue,
        fontWeight: renderStyle.fontWeight,
        fontFamily: renderStyle.fontFamily?.join(' '),
      );

  Widget createButton(BuildContext context) {
    return TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) => renderStyle.backgroundColor?.value),
        ),
        onPressed: () {
          var box = context.findRenderObject() as RenderBox;
          Offset globalOffset = box.globalToLocal(Offset(Offset.zero.dx, Offset.zero.dy));
          double clientX = globalOffset.dx;
          double clientY = globalOffset.dy;
          Event event = MouseEvent(EVENT_CLICK, clientX: clientX, clientY: clientY, view: ownerDocument.defaultView);
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
