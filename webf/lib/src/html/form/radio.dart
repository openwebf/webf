/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF Company. All rights reserved.
 */

// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/dom.dart' as dom;

import 'checked.dart';

/// create a radio widget when input type='radio'
mixin BaseRadioElement on WidgetElement, BaseCheckedElement {
  String _name = '';
  String _value = '';

  String get name => _name;
  
  @override
  String get value => _value;
  
  @override
  set value(value) {
    _value = value?.toString() ?? '';
  }
  
  // Public getter for _value to allow FlutterInputElement to access it
  String get radioValue => _value;
  
  // Public setter for _value to allow FlutterInputElement to set it
  set radioValue(String value) {
    _value = value;
  }

  set name(String? n) {
    if (RadioElementState._groupValues[_name] != null) {
      RadioElementState._groupValues.remove(_name);
    }
    _name = n?.toString() ?? '';
    // Don't set the group value here - it should be set when a radio is checked
  }

  double getRadioSize() {
    //TODO support zoom
    //width and height
    if (renderStyle.width.value != null && renderStyle.height.value != null) {
      return renderStyle.width.computedValue / 18.0;
    }
    return 1.0;
  }
}

mixin RadioElementState on WebFWidgetElementState {
  StreamSubscription<Map<String, String>>? _subscription;
  String? _cachedGroupName; // Cache the group name to prevent loss
  String _currentGroupValue = ''; // Instance-level group value cache

  static final Map<String, String> _groupValues = <String, String>{};
  
  // Helper to update group values
  static void _updateGroupValues(String key, String value) {
    if (value.isEmpty) {
      _groupValues.remove(key);
    } else {
      _groupValues[key] = value;
    }
  }
  static final Map<String, bool> _earlyCheckedStates = <String, bool>{};  // Track early checked states

  static StreamController<Map<String, String>>? _streamController;

  StreamController<Map<String, String>> get streamController {
    if (_streamController == null || _streamController!.isClosed) {
      _streamController = StreamController<Map<String, String>>.broadcast();
    }
    return _streamController!;
  }
  
  // Public getter to access cached group name
  String? get cachedGroupName => _cachedGroupName;
  
  // Public methods to access early checked states
  static void setEarlyCheckedState(String key, bool value) {
    _earlyCheckedStates[key] = value;
  }
  
  static bool? getEarlyCheckedState(String key) {
    return _earlyCheckedStates[key];
  }
  
  static Map<String, bool> get earlyCheckedStates => _earlyCheckedStates;
  
  BaseRadioElement get _radioElement => widgetElement as BaseRadioElement;

  String get groupValue {
    String groupName = _cachedGroupName ?? _radioElement.name;
    String staticValue = _groupValues[groupName] ?? '';
    String result = _currentGroupValue.isNotEmpty ? _currentGroupValue : staticValue;
    return result;
  }

  set groupValue(String? gv) {
    String groupName = _cachedGroupName ?? _radioElement.name;
    String value = gv ?? groupName;
    _radioElement.internalSetAttribute('groupValue', value);
    _updateGroupValues(groupName, value);
    _currentGroupValue = value; // Cache at instance level
  }

  void initRadioState() {
    
    // Cache the group name when it's first set
    if (_radioElement.name.isNotEmpty && _cachedGroupName == null) {
      _cachedGroupName = _radioElement.name;
    }
    
    _subscription = streamController.stream.listen((message) {
      setState(() {
        for (var entry in message.entries) {
          String groupName = _cachedGroupName ?? _radioElement.name;
          if (entry.key == groupName) {
            _updateGroupValues(entry.key, entry.value);
            _currentGroupValue = entry.value; // Update instance cache
          }
        }
      });
    });

    // Check if this radio is initially checked or has early checked state
    String radioKey = _radioElement.value;
    bool wasSetCheckedEarly = RadioElementState.getEarlyCheckedState(radioKey) == true;
    bool isInitiallyChecked = _radioElement.getAttribute('checked') == 'true';
    
    
    if (wasSetCheckedEarly || isInitiallyChecked) {
      String radioValue = _radioElement.value;
      String groupName = _cachedGroupName ?? _radioElement.name;
      String singleRadioValue = '$groupName-$radioValue';
      _updateGroupValues(groupName, singleRadioValue);
      _currentGroupValue = singleRadioValue; // Cache at instance level
      setState(() {});
    } else {
      String groupName = _cachedGroupName ?? _radioElement.name;
      if (_groupValues.containsKey(groupName)) {
        setState(() {});
      }
    }
  }


  void disposeRadio() {
    _subscription?.cancel();
    // Don't remove group values on dispose - other radios might still need them
    // Only remove if this is the last radio in the group

  }

  Widget createRadio(BuildContext context) {
    String groupName = _cachedGroupName ?? _radioElement.name;
    String radioValue = _radioElement.value;
    String singleRadioValue = '$groupName-$radioValue';
    String currentGroupValue = groupValue; // Use getter instead of direct Map access
    
    
    return Transform.scale(
      scale: _radioElement.getRadioSize(),
      child: Radio<String>(
          value: singleRadioValue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onChanged: _radioElement.disabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      Map<String, String> map = <String, String>{};
                      map[groupName] = newValue;
                      streamController.sink.add(map);
                      _radioElement.dispatchEvent(dom.InputEvent(inputType: 'radio', data: newValue));
                      _radioElement.dispatchEvent(dom.Event('change'));
                    });
                  }
                },
          groupValue: currentGroupValue),
    );
  }
}
