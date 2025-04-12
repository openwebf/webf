/*
 * Copyright (C) 2022-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    if (this is BaseRadioElement && newValue) {
      BaseRadioElement radio = this as BaseRadioElement;
      String newGroupValue = '${radio.name}-${radio.value}';
      Map<String, String> map = <String, String>{};
      map[radio.name] = newGroupValue;

      state?.groupValue = newGroupValue;

      if (state?.streamController.hasListener == true) {
        state?.streamController.sink.add(map);
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
  @override
  FlutterInputElement get widgetElement => super.widgetElement as FlutterInputElement;

  Widget createCheckBox(BuildContext context) {
    return Transform.scale(
      child: Checkbox(
        value: widgetElement.getChecked(),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        onChanged: widgetElement.disabled
            ? null
            : (bool? newValue) {
                setState(() {
                  widgetElement.setChecked(newValue!);
                  widgetElement.dispatchEvent(Event('change'));
                });
              },
      ),
      scale: widgetElement.getCheckboxSize(),
    );
  }
}
