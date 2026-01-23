/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'checkbox_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadCheckbox].
///
/// Exposed as `<flutter-shadcn-checkbox>` in the DOM.
class FlutterShadcnCheckbox extends FlutterShadcnCheckboxBindings {
  FlutterShadcnCheckbox(super.context);

  bool _checked = false;
  bool _disabled = false;
  bool _indeterminate = false;

  @override
  bool get checked => _checked;

  @override
  set checked(value) {
    final newValue = value == true;
    if (newValue != _checked) {
      _checked = newValue;
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
  bool get indeterminate => _indeterminate;

  @override
  set indeterminate(value) {
    final newValue = value == true;
    if (newValue != _indeterminate) {
      _indeterminate = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnCheckboxState(this);
}

class FlutterShadcnCheckboxState extends WebFWidgetElementState {
  FlutterShadcnCheckboxState(super.widgetElement);

  @override
  FlutterShadcnCheckbox get widgetElement =>
      super.widgetElement as FlutterShadcnCheckbox;

  /// Extract text content from nodes recursively.
  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    // Extract label text from child nodes
    Widget? labelWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      final labelText = _extractTextContent(widgetElement.childNodes);
      if (labelText.isNotEmpty) {
        labelWidget = Text(labelText);
      }
    }

    bool? value;
    if (widgetElement.indeterminate) {
      value = null; // Indeterminate state in Flutter is represented as null
    } else {
      value = widgetElement.checked;
    }

    // Use ShadCheckbox's built-in label property so clicking label toggles checkbox
    return ShadCheckbox(
      value: value ?? false,
      enabled: !widgetElement.disabled,
      label: labelWidget,
      onChanged: widgetElement.disabled
          ? null
          : (newValue) {
              widgetElement._checked = newValue;
              widgetElement._indeterminate = false;
              widgetElement.dispatchEvent(Event('change'));
              widgetElement.state?.requestUpdateState(() {});
            },
    );
  }
}
