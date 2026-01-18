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

  @override
  Widget build(BuildContext context) {
    Widget? labelWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      labelWidget = WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    }

    bool? value;
    if (widgetElement.indeterminate) {
      value = null; // Indeterminate state in Flutter is represented as null
    } else {
      value = widgetElement.checked;
    }

    final checkbox = ShadCheckbox(
      value: value ?? false,
      enabled: !widgetElement.disabled,
      onChanged: widgetElement.disabled
          ? null
          : (newValue) {
              widgetElement._checked = newValue;
              widgetElement._indeterminate = false;
              widgetElement.dispatchEvent(Event('change'));
              widgetElement.state?.requestUpdateState(() {});
            },
    );

    if (labelWidget != null) {
      return GestureDetector(
        onTap: widgetElement.disabled
            ? null
            : () {
                widgetElement._checked = !widgetElement._checked;
                widgetElement._indeterminate = false;
                widgetElement.dispatchEvent(Event('change'));
                widgetElement.state?.requestUpdateState(() {});
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            checkbox,
            const SizedBox(width: 8),
            labelWidget,
          ],
        ),
      );
    }

    return checkbox;
  }
}
