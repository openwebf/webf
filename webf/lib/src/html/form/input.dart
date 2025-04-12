/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/bridge.dart';

import 'base_input.dart';
import 'button.dart';
import 'checked.dart';
import 'radio.dart';
import 'time.dart';

const INPUT = 'INPUT';

enum InputSize {
  small,
  medium,
  large,
}

class FlutterInputElement extends WidgetElement
    with BaseInputElement, BaseCheckedElement, BaseRadioElement, BaseButtonElement {
  FlutterInputElement(BindingContext? context) : super(context);

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      state?.blur();
    });
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      state?.focus();
    });
  }

  @override
  WebFWidgetElementState createState() {
    return FlutterInputElementState(this);
  }
}

class FlutterInputElementState extends WebFWidgetElementState
    with BaseInputState, RadioElementState, CheckboxElementState, ButtonElementState, TimeElementState {
  FlutterInputElementState(super.widgetElement);

  @override
  void initState() {
    super.initState();
    switch (widgetElement.type) {
      case 'radio':
        initRadioState();
        break;
      default:
        initBaseInputState();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widgetElement.type) {
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

  Widget _wrapInputHeight(Widget widget) {
    double? heightValue = widgetElement.renderStyle.height.value;

    if (heightValue == null) return widget;

    return SizedBox(
        child: Center(
          child: widget,
        ),
        height: widgetElement.renderStyle.height.computedValue);
  }

  Widget createInput(BuildContext context, {int minLines = 1, int maxLines = 1}) {
    widgetElement..minLines = minLines;
    widgetElement..maxLines = maxLines;
    switch (widgetElement.type) {
      case 'hidden':
        return SizedBox(width: 0, height: 0);
    }
    return _wrapInputHeight(createInputWidget(context));
  }

  @override
  void deactivate() {
    super.deactivate();
    deactivateBaseInput();
  }

  @override
  void dispose() {
    super.dispose();
    disposeRadio();
    disposeBaseInput();
  }
}
