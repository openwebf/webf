/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart' as dom;

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
    properties['checked'] = BindingObjectProperty(
        getter: () => getChecked(),
        setter: (value) {
          setChecked(value == true);
        });
    properties['name'] = BindingObjectProperty(getter: () => name, setter: (value) => name = value);
  }

  @override
  void initializeAttributes(Map<String, dom.ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['value'] = dom.ElementAttributeProperty(getter: () => value, setter: (value) => this.value = value);
    attributes['disabled'] =
        dom.ElementAttributeProperty(getter: () => disabled.toString(), setter: (value) => disabled = value);
    attributes['checked'] = dom.ElementAttributeProperty(
        getter: () => getChecked().toString(), setter: (value) => setChecked(value == 'true'));
    attributes['name'] = dom.ElementAttributeProperty(getter: () => name, setter: (value) => name = value);
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
