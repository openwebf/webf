/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import 'base_input.dart';
import 'radio.dart';

mixin BaseCheckedElement on BaseInputElement {
  bool _checked = false;

  String get _earlyCheckedKey => hashCode.toString();

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
          // Persist on the element immediately and also cache for restoration when state mounts.
          _checked = value;
          CheckboxElementState.setEarlyCheckboxState(_earlyCheckedKey, value);
        }
        return;
      }

      switch (input.type) {
        case 'radio':
          _setRadioChecked(value);
          // _setRadioChecked updates group selection immediately; request a rebuild for the widget.
          state?.requestUpdateState();
          break;
        case 'checkbox':
        default:
          // Keep checkedness synchronous for JS reads, then rebuild the widget.
          _checked = value;
          state?.requestUpdateState();
          break;
      }
    }
  }

  bool _getRadioChecked() {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      final String groupName = (state as RadioElementState?)?.cachedGroupName ?? radio.name;
      final String expected = '$groupName-${radio.value}';

      // Before widget state mounts, honor boolean attribute presence and any group selection
      // already recorded by early checked changes.
      if (state == null) {
        if (hasAttribute('checked')) return true;
        final bool? early = RadioElementState.getEarlyCheckedState(radio.hashCode.toString());
        if (early != null) return early;
        return RadioElementState.getGroupValueForName(groupName) == expected;
      }

      return (state as RadioElementState).groupValue == expected;
    }
    return false;
  }

  void _setRadioChecked(bool newValue) {
    if (this is BaseRadioElement) {
      BaseRadioElement radio = this as BaseRadioElement;
      String radioKey = radio.hashCode.toString();
      
      if (state == null) {
        // Update group selection immediately so `el.checked` reads correctly before mount.
        final String radioName = radio.name;
        if (newValue && radioName.isNotEmpty) {
          RadioElementState.setGroupValueForName(radioName, '$radioName-${radio.value}');
        } else if (!newValue && radioName.isNotEmpty) {
          final String expected = '$radioName-${radio.value}';
          if (RadioElementState.getGroupValueForName(radioName) == expected) {
            RadioElementState.setGroupValueForName(radioName, '');
          }
        }

        RadioElementState.setEarlyCheckedState(radioKey, newValue);
        return;
      }
      
      // Use cached group name from state, fallback to current name
      String radioName = (state as RadioElementState).cachedGroupName ?? radio.name;

      if (newValue) {
        String newGroupValue = '$radioName-${radio.value}';
        // Update shared group selection immediately so all radios read consistent checkedness.
        RadioElementState.setGroupValueForName(radioName, newGroupValue);
        Map<String, String> map = <String, String>{};
        map[radioName] = newGroupValue;

        state?.groupValue = newGroupValue;

        if (state?.streamController.hasListener == true) {
          state?.streamController.sink.add(map);
        }
      } else {
        // When unchecking, only clear if this radio is currently the selected one
        String currentRadioValue = '$radioName-${radio.value}';
        String currentGroupValue = (state as RadioElementState).groupValue;
        if (currentGroupValue == currentRadioValue) {
          RadioElementState.setGroupValueForName(radioName, '');
          state?.groupValue = '';
          Map<String, String> map = <String, String>{};
          map[radioName] = '';
          
          if (state?.streamController.hasListener == true) {
            state?.streamController.sink.add(map);
          }
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

  static void clearEarlyCheckboxState(String key) {
    _earlyCheckboxStates.remove(key);
  }
  
  BaseCheckedElement get _checkedElement => widgetElement as BaseCheckedElement;

  void initCheckboxState() {
    final String checkboxKey = _checkedElement.hashCode.toString();
    final bool? early = CheckboxElementState.getEarlyCheckboxState(checkboxKey);
    // Restore early checked state and then clear it to avoid leaks/cross-page interference.
    if (early != null) {
      setState(() {
        (_checkedElement as dynamic)._checked = early;
      });
      CheckboxElementState.clearEarlyCheckboxState(checkboxKey);
      return;
    }

    // Initialize from attribute presence for HTML parsing: <input checked> yields value="".
    if ((_checkedElement as dynamic).hasAttribute('checked') == true) {
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
                if (newValue == null) return;
                _checkedElement.setChecked(newValue);
                _checkedElement.dispatchEvent(dom.InputEvent(inputType: 'checkbox', data: newValue.toString()));
                _checkedElement.dispatchEvent(dom.Event('change'));
              },
      ),
    );
  }
}
