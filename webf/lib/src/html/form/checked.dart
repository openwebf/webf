/*
 * Copyright (C) 2022-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

import 'base_input.dart';
import 'radio.dart';

mixin BaseCheckedElement on BaseInputElement {
  bool _checked = false;

  bool getChecked() {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      switch (input.type) {
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

  setChecked(bool value) {
    if (this is FlutterInputElement) {
      FlutterInputElement input = this as FlutterInputElement;
      
      if (state == null) {
        if (input.type == 'radio') {
          _setRadioChecked(value);
        } else if (input.type == 'checkbox') {
          // Store early checkbox state using value as unique key
          String? attrValue = input.getAttribute('value');
          String checkboxKey = (attrValue != null && attrValue.isNotEmpty) ? attrValue : input.hashCode.toString();
          CheckboxElementState.setEarlyCheckboxState(checkboxKey, value);
        }
        return;
      }
      
      state?.requestUpdateState(() {
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
      });
    }
  }

  bool _getRadioChecked() {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      return state?.groupValue == '${radio.name}-${radio.value}';
    }
    return false;
  }

  void _setRadioChecked(bool newValue) {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      String radioKey = radio.value;
      if (state == null) {
        RadioElementState.setEarlyCheckedState(radioKey, newValue);
      }
      
      if (newValue) {
        String newGroupValue = '${radio.name}-${radio.value}';
        Map<String, String> map = <String, String>{};
        map[radio.name] = newGroupValue;

        state?.groupValue = newGroupValue;

        if (state?.streamController.hasListener == true) {
          state?.streamController.sink.add(map);
        }
      }
    }
  }

  double getCheckboxSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.computedValue / 18.0;
    }
    return 1.0;
  }
}

mixin CheckboxElementState on WebFWidgetElementState {
  static final Map<String, bool> _earlyCheckboxStates = <String, bool>{}; // Track early checkbox states
  
  // Public methods to access early checked states
  static void setEarlyCheckboxState(String key, bool value) {
    _earlyCheckboxStates[key] = value;
  }
  
  static bool? getEarlyCheckboxState(String key) {
    return _earlyCheckboxStates[key];
  }
  
  BaseCheckedElement get _checkedElement => widgetElement as BaseCheckedElement;

  void initCheckboxState() {
    // Check if React already set checked=true before state was initialized
    String? attrValue = _checkedElement.getAttribute('value');
    String checkboxKey = (attrValue != null && attrValue.isNotEmpty) ? attrValue : _checkedElement.hashCode.toString();
    bool wasSetCheckedEarly = CheckboxElementState.getEarlyCheckboxState(checkboxKey) == true;
    
    // Restore early checked state
    if (wasSetCheckedEarly) {
      setState(() {
        (_checkedElement as dynamic)._checked = true;
      });
    }
  }

  Widget createCheckBox(BuildContext context) {
    return Transform.scale(
      scale: _checkedElement.getCheckboxSize(),
      child: Checkbox(
        value: _checkedElement.getChecked(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        onChanged: _checkedElement.disabled
            ? null
            : (bool? newValue) {
                setState(() {
                  _checkedElement.setChecked(newValue!);
                  _checkedElement.dispatchEvent(Event('change'));
                });
              },
      ),
    );
  }
}
