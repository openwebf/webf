/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'switch_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadSwitch].
///
/// Exposed as `<flutter-shadcn-switch>` in the DOM.
class FlutterShadcnSwitch extends FlutterShadcnSwitchBindings {
  FlutterShadcnSwitch(super.context);

  bool _checked = false;
  bool _disabled = false;

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
  WebFWidgetElementState createState() => FlutterShadcnSwitchState(this);
}

class FlutterShadcnSwitchState extends WebFWidgetElementState {
  FlutterShadcnSwitchState(super.widgetElement);

  @override
  FlutterShadcnSwitch get widgetElement =>
      super.widgetElement as FlutterShadcnSwitch;

  @override
  Widget build(BuildContext context) {
    Widget? labelWidget;
    if (widgetElement.childNodes.isNotEmpty) {
      labelWidget = WebFWidgetElementChild(
        child: widgetElement.childNodes.first.toWidget(),
      );
    }

    final switchWidget = ShadSwitch(
      value: widgetElement.checked,
      enabled: !widgetElement.disabled,
      onChanged: widgetElement.disabled
          ? null
          : (value) {
              widgetElement._checked = value;
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
                widgetElement.dispatchEvent(Event('change'));
                widgetElement.state?.requestUpdateState(() {});
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switchWidget,
            const SizedBox(width: 8),
            labelWidget,
          ],
        ),
      );
    }

    return switchWidget;
  }
}
