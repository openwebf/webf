/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/dom.dart';
import 'package:webf/widget.dart';
import 'package:webf/bridge.dart';

enum InputSize {
  small,
  medium,
  large,
}

const Map<String, dynamic> _inputDefaultStyle = {
  BORDER: '2px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
  WIDTH: '140px',
  HEIGHT: '25px'
};

const Map<String, dynamic> _checkboxDefaultStyle = {
  MARGIN: '3px 3px 3px 4px',
  PADDING: INITIAL,
  DISPLAY: INLINE_BLOCK,
  BORDER: '0'
};

class FlutterInputElement extends WidgetElement
    with
        BaseCheckedElement,
        BaseRadioElement,
        BaseCheckBoxElement,
        BaseButtonElement,
        BaseInputElement,
        BaseTimeElement {
  BindingContext? buildContext;

  FlutterInputElement(BindingContext? context) : super(context) {
    buildContext = context;
  }

  @override
  void initState() {
    super.initState();
    switch (type) {
      case 'radio':
        initRadioState();
        break;
      default:
        initBaseInputState();
        break;
    }
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    switch (type) {
      case 'radio':
        disposeRadio();
        break;
      default:
        disposeBaseInput();
        break;
    }
  }

  @override
  Map<String, dynamic> get defaultStyle {
    switch (type) {
      case 'text':
      case 'time':
        return _inputDefaultStyle;
      case 'radio':
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
  Widget build(BuildContext context, ChildNodeList childNodes) {
    switch (type) {
      case 'radio':
        return createRadio(context);
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

  void initBaseInputState() {
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
    properties['selectionStart'] = BindingObjectProperty(getter: () => selectionStart, setter: (value) {
      if (value == null) {
        selectionStart = null;
        return;
      }

      if (value is num) {
        selectionStart = value.toInt();
        return;
      }

      if (value is String) {
        selectionStart = int.tryParse(value);
        return;
      }

      selectionStart = null;
    });
    properties['selectionEnd'] = BindingObjectProperty(getter: () => selectionEnd, setter: (value) {
      if (value == null) {
        selectionEnd = null;
        return;
      }

      if (value is num) {
        selectionEnd = value.toInt();
        return;
      }

      if (value is String) {
        selectionEnd = int.tryParse(value);
        return;
      }

      selectionEnd = null;
    });
    properties['maxLength'] = BindingObjectProperty(
      getter: () => maxLength,
      setter: (value) {
        if (value == null) {
          maxLength = null;
          return;
        }

        if (value is num) {
          maxLength = value.toInt();
          return;
        }

        if (value is String) {
          maxLength = int.tryParse(value);
          return;
        }

        maxLength = null;
      });
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['value'] = ElementAttributeProperty(getter: () => value, setter: (value) => this.value = value);
    attributes['disabled'] =
        ElementAttributeProperty(getter: () => disabled.toString(), setter: (value) => disabled = value);
  }


  void _updateSelection() {
    int? start = selectionStart;
    int? end = selectionEnd;
    if (start != null && end != null) {
      controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    }
  }

  TextInputType? getKeyboardType() {
    if (this is FlutterTextAreaElement) {
      return TextInputType.multiline;
    }

    switch (type) {
      case 'text':
        if (inputMode != null) {
          switch (inputMode) {
            case 'numeric':
              return TextInputType.number;
            case 'tel':
              return TextInputType.phone;
            case 'decimal':
              return TextInputType.numberWithOptions(decimal: true);
            case 'email':
              return TextInputType.emailAddress;
            case 'url':
              return TextInputType.url;
            case 'text':
            case 'search':
              return TextInputType.text;
            case 'none':
              return TextInputType.none;
          }
        }
        return TextInputType.text;
      case 'number':
        String? step = getAttribute('step');
        if (step == 'any' || step != null && step.contains('.')) {
          return TextInputType.numberWithOptions(decimal: true);
        }
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'email':
        return TextInputType.emailAddress;
      case 'search':
        return TextInputType.text;
    }
    return TextInputType.text;
  }

  TextInputAction getTextInputAction() {
    if (enterKeyHint != null) {
      switch (enterKeyHint) {
        case 'next':
          return TextInputAction.next;
        case 'done':
          return TextInputAction.done;
        case 'search':
          return TextInputAction.search;
        case 'go':
          return TextInputAction.go;
        case 'previous':
          return TextInputAction.previous;
        case 'send':
          return TextInputAction.send;
        default:
          return TextInputAction.unspecified;
      }
    }
    switch (type) {
      case 'search':
        return TextInputAction.search;
      case 'email':
      case 'password':
      case 'tel':
      case 'url':
      case 'number':
        return TextInputAction.done;
      case 'text':
        return TextInputAction.newline;
      default:
        return TextInputAction.unspecified;
    }
  }

  String get type => getAttribute('type') ?? 'text';
  String? get inputMode => getAttribute('inputmode');
  String? get enterKeyHint => getAttribute('enterkeyhint');
  void set type(value) {
    internalSetAttribute('type', value?.toString() ?? '');
    resetInputDefaultStyle();
  }

  void resetInputDefaultStyle() {
    switch (type) {
      case 'radio':
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

    if (!ownerDocument.controller.shouldBlockingFlushingResolvedStyleProperties) {
      style.flushPendingProperties();
    }
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
      _disabled = true;
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
    String? value = getAttribute('maxlength');
    if (value != null) return int.parse(value);
    return null;
  }

  set maxLength(int? value) {
    internalSetAttribute('maxlength', value?.toString() ?? '');
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
        height: 1.0,
      );

  StrutStyle get _textStruct => StrutStyle(
    leading: leading,
  );

  final double _defaultPadding = 0;

  int? _selectionStart;
  int? _selectionEnd;
  int? get selectionStart => _selectionStart;
  int? get selectionEnd => _selectionEnd;

  set selectionStart(int? value) {
    if (value != null) {
      _selectionStart = value;
    }
  }

  set selectionEnd(int? value) {
    if (value != null) {
      _selectionEnd = value;
    }
  }

  Widget _createInputWidget(BuildContext context) {
    FlutterFormElementContext? formContext = context.dependOnInheritedWidgetOfExactType<FlutterFormElementContext>();
    onChanged(String newValue) {
      setState(() {

        _selectionStart = null;
        _selectionEnd = null;

        InputEvent inputEvent = InputEvent(inputType: '', data: newValue);
        dispatchEvent(inputEvent);
      });
      hasDirtyValue = true;
    }

    _updateSelection();

    InputDecoration decoration = InputDecoration(
        label: label != null ? Text(label!) : null,
        border: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.fromLTRB(0, _defaultPadding, 0, _defaultPadding),
        hintText: placeholder,
        counterText: '', // Hide counter to align with web
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
        textInputAction: getTextInputAction(),
        keyboardType: getKeyboardType(),
        inputFormatters: getInputFormatters(),
        cursorHeight: renderStyle.fontSize.computedValue,
        decoration: decoration,
      );
    } else {
      widget = TextField(
        controller: controller,
        cursorHeight: renderStyle.fontSize.computedValue,
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
        textInputAction: getTextInputAction(),
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
  void didDetachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) {
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

      HardwareKeyboard.instance.addHandler(_handleKey);
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

      HardwareKeyboard.instance.removeHandler(_handleKey);
    }
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      dispatchEvent(KeyboardEvent(EVENT_KEY_UP,
          code: event.physicalKey.debugName ?? '',
          key: event.logicalKey.keyLabel,
      ));
      return true;
    } else if (event is KeyDownEvent) {
      dispatchEvent(KeyboardEvent(EVENT_KEY_DOWN,
        code: event.physicalKey.debugName ?? '',
        key: event.logicalKey.keyLabel,
      ));
    }
    return false;
  }

  Future<void> disposeBaseInput() async {
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

mixin BaseCheckedElement on WidgetElement {
  bool _checked = false;

  bool _getChecked() {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      switch(input.type) {
        case 'radio':
          return _getRadioChecked();
        case 'checkbox':
          return _checked;
        default:
          return _checked;
      }
    }
    return _checked;
  }

  _setChecked(bool value) {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      switch (input.type) {
        case 'radio':
          _setRadioChecked(value);
          break;
        case 'checkbox':
          _checked = value;
          break;
        default:
          _checked = value;
      }
    }
  }

  bool _getRadioChecked() {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      return radio.groupValue == '${radio.name}-${radio.value}';
    }
    return false;
  }

  void _setRadioChecked(bool newValue) {
    if (this is BaseRadioElement && newValue) {
      BaseRadioElement radio = this as BaseRadioElement;
      String newGroupValue = '${radio.name}-${radio.value}';
      Map<String, String> map = <String, String>{};
      map[radio.name] = newGroupValue;

      BaseRadioElement._groupValues[radio.name] = newGroupValue;

      if (BaseRadioElement._streamController.hasListener) {
        BaseRadioElement._streamController.sink.add(map);
      }
    }
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['checked'] = BindingObjectProperty(
      getter: () => _getChecked(),
      setter: (value) {
        _setChecked(value == true);
      }
    );
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['checked'] = ElementAttributeProperty(
      getter: () => _getChecked().toString(),
      setter: (value) => _setChecked(value == 'true')
    );
  }
}

/// create a radio widget when input type='radio'

mixin BaseRadioElement on WidgetElement, BaseCheckedElement {
  static final Map<String, String> _groupValues = <String, String>{};

  static final StreamController<Map<String, String>> _streamController =
      StreamController<Map<String, String>>.broadcast();
  late StreamSubscription<Map<String, String>> _subscription;

  void initRadioState() {
    _subscription = _streamController.stream.listen((message) {
      setState(() {
        for (var entry in message.entries) {
          if (entry.key == name) {
            _groupValues[entry.key] = entry.value;
          }
        }
      });
    });

    if (_groupValues.containsKey(name)) {
      setState(() {});
    }
  }

  void disposeRadio() {
    _subscription.cancel();
    if (_groupValues.containsKey(name)) {
      _groupValues.remove(name);
    }
    if (_groupValues.isEmpty) {
      _streamController.close();
    }
  }

  String get groupValue => _groupValues[name] ?? name;
  set groupValue(String? gv) {
    internalSetAttribute('groupValue', gv ?? name);
    _groupValues[name] = gv ?? name;
  }

  bool get disabled => getAttribute('disabled') != null;

  String get value => getAttribute('value') ?? '';

  String _name = '';
  String get name => _name;
  set name(String? n) {
    if (_groupValues[_name] != null) {
      _groupValues.remove(_name);
    }
    _name = n?.toString() ?? '';
    _groupValues[_name] = _name;
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);

    properties['name'] = BindingObjectProperty(
        getter: () => name, setter: (value) => name = value);

    properties['value'] = BindingObjectProperty(
      getter: () => value,
      setter: (value) {
        internalSetAttribute('value', value?.toString() ?? '');
      }
    );
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['name'] = ElementAttributeProperty(
        getter: () => name, setter: (value) => name = value);

    attributes['value'] = ElementAttributeProperty(
      getter: () => value,
      setter: (value) => internalSetAttribute('value', value)
    );
  }

  double getRadioSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.computedValue / 18.0;
    }
    return 1.0;
  }

  Widget createRadio(BuildContext context) {
    String singleRadioValue = '$name-$value';
    return Transform.scale(
      child: Radio<String>(
          value: singleRadioValue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onChanged: disabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                    Map<String, String> map = <String, String>{};
                    map[name] = newValue;
                    _streamController.sink.add(map);

                    dispatchEvent(InputEvent(inputType: 'radio', data: newValue));
                    dispatchEvent(Event('change'));
                  });
                }
                },
          groupValue: groupValue),
      scale: getRadioSize(),
    );
  }
}

/// create a checkBox widget when input type='checkbox'
mixin BaseCheckBoxElement on WidgetElement, BaseCheckedElement {
  bool get disabled => getAttribute('disabled') != null;

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
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
        value: _getChecked(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        onChanged: disabled
            ? null
            : (bool? newValue) {
                setState(() {
                  _setChecked(newValue!);
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
