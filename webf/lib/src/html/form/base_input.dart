/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/html.dart';
import 'package:webf/widget.dart';

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
  WIDTH: 'auto',
  HEIGHT: 'auto',
  BORDER: '0'
};

/// create a base input widget containing input and textarea
mixin BaseInputElement on WidgetElement {
  String? oldValue;

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
  FlutterInputElementState? get state => super.state as FlutterInputElementState?;

  String get value => state?.controller.value.text ?? '';

  set value(value) {
    if (value == null) {
      state?.controller.value = TextEditingValue.empty;
    } else {
      value = value.toString();
      if (state?.controller.value.text != value) {
        state?.controller.value = TextEditingValue(text: value.toString());
      }
    }
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
    properties['selectionStart'] = BindingObjectProperty(
        getter: () => selectionStart,
        setter: (value) {
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
    properties['selectionEnd'] = BindingObjectProperty(
        getter: () => selectionEnd,
        setter: (value) {
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
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['value'] = dom.ElementAttributeProperty(getter: () => value, setter: (value) => this.value = value);
    attributes['disabled'] =
        dom.ElementAttributeProperty(getter: () => disabled.toString(), setter: (value) => disabled = value);
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
    value = text;
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
  double get leading =>
      lineHeight > fontSize && (maxLines != 1 || height == null || lineHeight < renderStyle.height.computedValue)
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

  @override
  void didDetachRenderer([RenderObjectElement? flutterWidgetElement]) {
    super.didDetachRenderer();
  }
}

mixin BaseInputState on WebFWidgetElementState {
  TextEditingController controller = TextEditingController();
  FocusNode? _focusNode;

  @override
  FlutterInputElement get widgetElement => super.widgetElement as FlutterInputElement;

  bool get _isFocus => _focusNode?.hasFocus ?? false;

  void blur() {
    _focusNode?.unfocus();
  }

  void focus() {
    _focusNode?.requestFocus();
  }

  void initBaseInputState() {
    _focusNode ??= FocusNode();
    _focusNode!.addListener(handleFocusChange);
  }

  void handleFocusChange() {
    if (_isFocus) {
      widgetElement.oldValue = widgetElement.value;
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_FOCUS, relatedTarget: widgetElement));
      });

      HardwareKeyboard.instance.addHandler(_handleKey);
    } else {
      if (widgetElement.oldValue != widgetElement.value) {
        scheduleMicrotask(() {
          widgetElement.dispatchEvent(dom.Event('change'));
        });
      }
      scheduleMicrotask(() {
        widgetElement.dispatchEvent(dom.FocusEvent(dom.EVENT_BLUR, relatedTarget: widgetElement));
      });

      HardwareKeyboard.instance.removeHandler(_handleKey);
    }
  }

  bool _handleKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      widgetElement.dispatchEvent(dom.KeyboardEvent(
        dom.EVENT_KEY_UP,
        code: event.physicalKey.debugName ?? '',
        key: event.logicalKey.keyLabel,
      ));
    } else if (event is KeyDownEvent) {
      widgetElement.dispatchEvent(dom.KeyboardEvent(
        dom.EVENT_KEY_DOWN,
        code: event.physicalKey.debugName ?? '',
        key: event.logicalKey.keyLabel,
      ));
    }
    return false;
  }

  void deactivateBaseInput() {
    _focusNode?.unfocus();
    _focusNode?.removeListener(handleFocusChange);
  }

  void _updateSelection() {
    int? start = widgetElement.selectionStart;
    int? end = widgetElement.selectionEnd;
    if (start != null && end != null) {
      controller.selection = TextSelection(baseOffset: start, extentOffset: end);
    }
  }

  Widget createInputWidget(BuildContext context) {
    onChanged(String newValue) {
      setState(() {
        widgetElement._selectionStart = null;
        widgetElement._selectionEnd = null;

        dom.InputEvent inputEvent = dom.InputEvent(inputType: '', data: newValue);
        widgetElement.dispatchEvent(inputEvent);
      });
    }

    _updateSelection();

    InputDecoration decoration = InputDecoration(
        label: widgetElement.label != null ? Text(widgetElement.label!) : null,
        border: InputBorder.none,
        isDense: true,
        isCollapsed: true,
        contentPadding: EdgeInsets.fromLTRB(0, widgetElement._defaultPadding, 0, widgetElement._defaultPadding),
        hintText: widgetElement.placeholder,
        counterText: '',
        // Hide counter to align with web
        suffix: widgetElement.isSearch && widgetElement.value.isNotEmpty && _isFocus
            ? SizedBox(
                width: 14,
                height: 14,
                child: IconButton(
                  iconSize: 14,
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                      dom.InputEvent inputEvent = dom.InputEvent(inputType: '', data: '');
                      widgetElement.dispatchEvent(inputEvent);
                    });
                  },
                  icon: Icon(Icons.clear),
                ),
              )
            : null);
    late Widget widget = TextField(
      controller: controller,
      cursorHeight: widgetElement.renderStyle.fontSize.computedValue,
      enabled: !widgetElement.disabled && !widgetElement.readonly,
      style: widgetElement._textStyle,
      strutStyle: widgetElement._textStruct,
      autofocus: widgetElement.autofocus,
      minLines: widgetElement.minLines,
      maxLines: widgetElement.maxLines,
      maxLength: widgetElement.maxLength,
      onChanged: onChanged,
      textAlign: widgetElement.renderStyle.textAlign,
      focusNode: _focusNode,
      obscureText: widgetElement.isPassWord,
      cursorColor: widgetElement.renderStyle.caretColor ?? widgetElement.renderStyle.color.value,
      cursorRadius: Radius.circular(4),
      textInputAction: widgetElement.getTextInputAction(),
      keyboardType: widgetElement.getKeyboardType(),
      inputFormatters: widgetElement.getInputFormatters(),
      onSubmitted: (String value) {
        if (widgetElement.isSearch) {
          widgetElement.dispatchEvent(dom.Event('search'));
        }
        widgetElement.dispatchEvent(dom.KeyboardEvent(
          dom.EVENT_KEY_DOWN,
          code: 'Enter',
          key: 'Enter',
        ));
        widgetElement.dispatchEvent(dom.KeyboardEvent(
          dom.EVENT_KEY_UP,
          code: 'Enter',
          key: 'Enter',
        ));
      },
      decoration: decoration,
    );
    return widget;
  }

  void disposeBaseInput() {
    _focusNode?.removeListener(handleFocusChange);
    _focusNode?.unfocus();
  }
}
