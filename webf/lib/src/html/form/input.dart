/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
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

// ignore: constant_identifier_names
const INPUT = 'INPUT';

enum InputSize {
  small,
  medium,
  large,
}

class FlutterInputElement extends WidgetElement
    with BaseInputElement, BaseCheckedElement, BaseRadioElement, BaseButtonElement {
  FlutterInputElement(super.context);

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      state?.blur();
    });
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      // If state is not yet available, remember to focus after mount.
      if (state != null) {
        state?.focus();
      } else {
        (this as BaseInputElement).markPendingFocus();
      }
    });
  }

  // defaultValue for INPUT maps to the `value` attribute in HTML.
  // Setting it should also set the current value property.
  @override
  String? get defaultValue => getAttribute('value') ?? '';

  @override
  set defaultValue(String? text) {
    final String v = text?.toString() ?? '';
    // Update the attribute that carries the default value in HTML
    internalSetAttribute('value', v);

    // Update the live value property according to type
    switch (type) {
      case 'radio':
        (this as BaseRadioElement).radioValue = v;
        break;
      case 'button':
      case 'submit':
        // BaseButtonElement.attributeDidUpdate will reflect label
        break;
      default:
        // Do not override existing live value if already set (HTML dirty value semantics).
        // Only initialize when current value is empty.
        if ((elementValue).isEmpty) {
          setElementValue(v);
        }
    }
  }

  // Resolve potential mixin conflicts by routing value to the right storage.
  @override
  get value {
    switch (type) {
      case 'radio':
        return (this as BaseRadioElement).radioValue;
      case 'button':
      case 'submit':
        // Avoid recursion via attribute getter mapping; return raw attribute.
        return attributes['value'] ?? '';
      default:
        return elementValue; // BaseInputElement storage
    }
  }

  @override
  set value(v) {
    switch (type) {
      case 'radio':
        (this as BaseRadioElement).radioValue = v?.toString() ?? '';
        break;
      case 'button':
      case 'submit':
        internalSetAttribute('value', v?.toString() ?? '');
        break;
      default:
        setElementValue(v?.toString() ?? '');
    }
  }

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);

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
    attributes['type'] = dom.ElementAttributeProperty(
        getter: () => (this.attributes['type'] ?? 'text'),
        setter: (value) {
          // Route through the type setter so default UA style resets appropriately.
          type = value;
        });
    attributes['disabled'] =
        dom.ElementAttributeProperty(getter: () => disabled.toString(), setter: (value) => (this as dynamic).disabled = value);
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

  // Implementation for TimeElementState
  @override
  Widget createTimeInput(BuildContext context) {
    return createInput(context);
  }

  @override
  void initState() {
    super.initState();
    switch (widgetElement.type) {
      case 'radio':
        initRadioState();
        break;
      case 'checkbox':
        initCheckboxState();
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

  Widget createInput(BuildContext context, {int minLines = 1, int maxLines = 1}) {
    widgetElement.minLines = minLines;
    widgetElement.maxLines = maxLines;
    switch (widgetElement.type) {
      case 'hidden':
        return SizedBox(width: 0, height: 0);
    }
    // Width and height are now handled inside createInputWidget
    return createInputWidget(context);
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
