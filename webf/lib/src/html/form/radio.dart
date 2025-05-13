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

  String get name => _name;

  set name(String? n) {
    if (RadioElementState._groupValues[_name] != null) {
      RadioElementState._groupValues.remove(_name);
    }
    _name = n?.toString() ?? '';
    RadioElementState._groupValues[_name] = _name;
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

  static final StreamController<Map<String, String>> _streamController =
      StreamController<Map<String, String>>.broadcast();

  StreamController<Map<String, String>> get streamController => _streamController;

  String get groupValue => _groupValues[widgetElement.name] ?? widgetElement.name;

  set groupValue(String? gv) {
    widgetElement.internalSetAttribute('groupValue', gv ?? widgetElement.name);
    _groupValues[widgetElement.name] = gv ?? widgetElement.name;
  }

  @override
  FlutterInputElement get widgetElement => super.widgetElement as FlutterInputElement;

  void initRadioState() {
    _subscription = _streamController.stream.listen((message) {
      setState(() {
        for (var entry in message.entries) {
          if (entry.key == widgetElement.name) {
            _groupValues[entry.key] = entry.value;
          }
        }
      });
    });

    if (_groupValues.containsKey(widgetElement.name)) {
      setState(() {});
    }
  }

  void disposeRadio() {
    _subscription?.cancel();
    if (_groupValues.containsKey(widgetElement.name)) {
      _groupValues.remove(widgetElement.name);
    }
    if (_groupValues.isEmpty) {
      _streamController.close();
    }
  }

  Widget createRadio(BuildContext context) {
    String singleRadioValue = '${widgetElement.name}-${widgetElement.getAttribute('value')}';
    return Transform.scale(
      child: Radio<String>(
          value: singleRadioValue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          onChanged: widgetElement.disabled
              ? null
              : (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      Map<String, String> map = <String, String>{};
                      map[widgetElement.name] = newValue;
                      _streamController.sink.add(map);
                      widgetElement.dispatchEvent(dom.InputEvent(inputType: 'radio', data: newValue));
                      widgetElement.dispatchEvent(dom.Event('change'));
                    });
                  }
                },
          groupValue: groupValue),
      scale: widgetElement.getRadioSize(),
    );
  }
}
