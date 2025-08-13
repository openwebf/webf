/*
 * Copyright (C) 2022-present The WebF Company. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/html.dart';
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

  static final Map<String, String> _groupValues = <String, String>{};
  static final Map<String, bool> _earlyCheckedStates = <String, bool>{};  // Track early checked states

  static final StreamController<Map<String, String>> _streamController =
      StreamController<Map<String, String>>.broadcast();

  StreamController<Map<String, String>> get streamController => _streamController;
  
  // Public methods to access early checked states
  static void setEarlyCheckedState(String key, bool value) {
    _earlyCheckedStates[key] = value;
  }
  
  static bool? getEarlyCheckedState(String key) {
    return _earlyCheckedStates[key];
  }
  
  static Map<String, bool> get earlyCheckedStates => _earlyCheckedStates;
  
  BaseRadioElement get _radioElement => widgetElement as BaseRadioElement;

  String get groupValue => _groupValues[_radioElement.name] ?? '';

  set groupValue(String? gv) {
    _radioElement.internalSetAttribute('groupValue', gv ?? _radioElement.name);
    _groupValues[_radioElement.name] = gv ?? _radioElement.name;
  }

  void initRadioState() {
    // Check if JS already set checked=true before state was initialized
    String radioKey = _radioElement.value;
    bool wasSetCheckedEarly = RadioElementState.getEarlyCheckedState(radioKey) == true;
    
    _subscription = _streamController.stream.listen((message) {
      setState(() {
        for (var entry in message.entries) {
          if (entry.key == _radioElement.name) {
            _groupValues[entry.key] = entry.value;
          }
        }
      });
    });

    // Check if this radio is initially checked
    // This handles both: direct checked attribute and early setChecked calls
    if (wasSetCheckedEarly) {
      String radioValue = _radioElement.value;
      String singleRadioValue = '${_radioElement.name}-$radioValue';
      _groupValues[_radioElement.name] = singleRadioValue;
      setState(() {});
    } else if (_groupValues.containsKey(_radioElement.name)) {
      setState(() {});
    }
  }


  void disposeRadio() {
    _subscription?.cancel();
    if (_groupValues.containsKey(_radioElement.name)) {
      _groupValues.remove(_radioElement.name);
    }
    if (_groupValues.isEmpty) {
      _streamController.close();
    }
  }

  Widget createRadio(BuildContext context) {
    String radioValue = _radioElement.value;
    String singleRadioValue = '${_radioElement.name}-$radioValue';
    
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
                      map[_radioElement.name] = newValue;
                      _streamController.sink.add(map);
                      _radioElement.dispatchEvent(dom.InputEvent(inputType: 'radio', data: newValue));
                      _radioElement.dispatchEvent(dom.Event('change'));
                    });
                  }
                },
          groupValue: groupValue),
    );
  }
}
