/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'input_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadInput].
///
/// Exposed as `<flutter-shadcn-input>` in the DOM.
class FlutterShadcnInput extends FlutterShadcnInputBindings {
  FlutterShadcnInput(super.context);

  String _value = '';
  String? _placeholder;
  String _type = 'text';
  bool _disabled = false;
  bool _readonly = false;
  int? _maxLength;
  int? _minLength;
  String? _pattern;
  bool _required = false;
  bool _autofocus = false;

  @override
  String get value => _value;

  @override
  set value(value) {
    final newValue = value?.toString() ?? '';
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final newValue = value?.toString();
    if (newValue != _placeholder) {
      _placeholder = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get type => _type;

  @override
  set type(value) {
    final newValue = value?.toString() ?? 'text';
    if (newValue != _type) {
      _type = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final newValue = value == true;
    if (newValue != _disabled) {
      _disabled = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get readonly => _readonly;

  @override
  set readonly(value) {
    final newValue = value == true;
    if (newValue != _readonly) {
      _readonly = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get maxlength => _maxLength?.toString();

  @override
  set maxlength(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _maxLength) {
      _maxLength = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get minlength => _minLength?.toString();

  @override
  set minlength(value) {
    final newValue = value != null ? int.tryParse(value.toString()) : null;
    if (newValue != _minLength) {
      _minLength = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get pattern => _pattern;

  @override
  set pattern(value) {
    final newValue = value?.toString();
    if (newValue != _pattern) {
      _pattern = newValue;
    }
  }

  @override
  bool get required => _required;

  @override
  set required(value) {
    final newValue = value == true;
    if (newValue != _required) {
      _required = newValue;
    }
  }

  @override
  bool get autofocus => _autofocus;

  @override
  set autofocus(value) {
    final newValue = value == true;
    if (newValue != _autofocus) {
      _autofocus = newValue;
    }
  }

  TextInputType get keyboardType {
    switch (_type.toLowerCase()) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'tel':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  bool get obscureText => _type.toLowerCase() == 'password';

  @override
  WebFWidgetElementState createState() => FlutterShadcnInputState(this);
}

class FlutterShadcnInputState extends WebFWidgetElementState {
  FlutterShadcnInputState(super.widgetElement);

  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  FlutterShadcnInput get widgetElement =>
      super.widgetElement as FlutterShadcnInput;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widgetElement.value);
    _focusNode = FocusNode();

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      widgetElement.dispatchEvent(Event('focus'));
    } else {
      widgetElement.dispatchEvent(Event('blur'));
      widgetElement.dispatchEvent(Event('change'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync controller with external value changes
    if (_controller.text != widgetElement.value) {
      _controller.text = widgetElement.value;
    }

    List<TextInputFormatter>? inputFormatters;
    if (widgetElement._maxLength != null) {
      inputFormatters = [
        LengthLimitingTextInputFormatter(widgetElement._maxLength),
      ];
    }

    return ShadInput(
      controller: _controller,
      focusNode: _focusNode,
      placeholder: widgetElement.placeholder != null
          ? Text(widgetElement.placeholder!)
          : null,
      enabled: !widgetElement.disabled,
      readOnly: widgetElement.readonly,
      obscureText: widgetElement.obscureText,
      keyboardType: widgetElement.keyboardType,
      autofocus: widgetElement.autofocus,
      inputFormatters: inputFormatters,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('input'));
      },
    );
  }
}
