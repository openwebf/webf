/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'textarea_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadTextarea].
///
/// Exposed as `<flutter-shadcn-textarea>` in the DOM.
class FlutterShadcnTextarea extends FlutterShadcnTextareaBindings {
  FlutterShadcnTextarea(super.context);

  String _value = '';
  String? _placeholder;
  int _rows = 3;
  bool _disabled = false;
  bool _readonly = false;
  int? _maxLength;
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
  String get rows => _rows.toString();

  @override
  set rows(value) {
    final newValue = int.tryParse(value?.toString() ?? '') ?? 3;
    if (newValue != _rows) {
      _rows = newValue;
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

  @override
  WebFWidgetElementState createState() => FlutterShadcnTextareaState(this);
}

class FlutterShadcnTextareaState extends WebFWidgetElementState {
  FlutterShadcnTextareaState(super.widgetElement);

  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  FlutterShadcnTextarea get widgetElement =>
      super.widgetElement as FlutterShadcnTextarea;

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
      autofocus: widgetElement.autofocus,
      inputFormatters: inputFormatters,
      minLines: widgetElement._rows,
      maxLines: null, // Allow expansion
      keyboardType: TextInputType.multiline,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('input'));
      },
    );
  }
}
