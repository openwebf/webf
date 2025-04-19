/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';

abstract class FlutterCupertinoSliderBindings extends WidgetElement {
  FlutterCupertinoSliderBindings(super.context);

  double get val;
  set val(value);

  double get min;
  set min(value);

  double get max;
  set max(value);

  int? get divisions;
  set divisions(value);

  bool get disabled;
  set disabled(value);

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['val'] = ElementAttributeProperty(
        getter: () => val.toString(),
        setter: (value) => val = value
    );

    // Minimum value
    attributes['min'] = ElementAttributeProperty(
        getter: () => min.toString(),
        setter: (val) => min = val
    );

    // Maximum value
    attributes['max'] = ElementAttributeProperty(
        getter: () => max.toString(),
        setter: (val) => max = val
    );

    // Step divisions
    attributes['step'] = ElementAttributeProperty(
        getter: () => divisions?.toString() ?? '',
        setter: (val) => divisions = val
    );

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
        getter: () => disabled.toString(),
        setter: (val) => disabled = val
    );
  }

  static StaticDefinedBindingPropertyMap flutterCupertinoSliderProperties = {
    'val': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterCupertinoSliderBindings>(element).val,
      setter: (element, value) =>
      castToType<FlutterCupertinoSliderBindings>(element).val = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties =>
      [
        ...super.properties,
        flutterCupertinoSliderProperties,
      ];

  double getValue(List<dynamic> args);
  void setValue(List<dynamic> args);

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap sliderSyncMethods = {
    'getValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        return castToType<FlutterCupertinoSlider>(element).getValue(args);
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<FlutterCupertinoSlider>(element).setValue(args);
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods =>
      [
        ...super.methods,
        sliderSyncMethods,
      ];
}

class FlutterCupertinoSlider extends FlutterCupertinoSliderBindings {
  FlutterCupertinoSlider(super.context);

  @override
  double get val => _value;

  @override
  set val(value) {
    final newValue = double.tryParse(value) ?? _value;
    if (newValue != _value) {
      _value = newValue.clamp(_min, _max);
    }
  }

  double _value = 0.0;
  double _min = 0.0;
  double _max = 100.0;
  int? _divisions;
  bool _disabled = false;

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSliderState(this);
  }

  @override
  double getValue(List args) {
    return _value;
  }

  @override
  void setValue(List<dynamic> args) {
    if (args.isNotEmpty) {
      final newValue = double.tryParse(args[0].toString()) ?? _value;
      _value = newValue.clamp(_min, _max);
    }
  }

  @override
  double get min => _min;
  @override
  set min(value) {
    final newMin = double.tryParse(value) ?? _min;
    if (newMin != _min) {
      _min = newMin;
      _value = _value.clamp(_min, _max);
    }
  }

  @override
  double get max => _max;
  @override
  set max(value) {
    final newMax = double.tryParse(value) ?? _max;
    if (newMax != _max) {
      _max = newMax;
      _value = _value.clamp(_min, _max);
    }
  }

  @override
  int? get divisions => _divisions;
  @override
  set divisions(value) {
    final steps = int.tryParse(value);
    if (steps != _divisions) {
      _divisions = steps;
    }
  }

  @override
  bool get disabled => _disabled;
  @override
  set disabled(value) {
    _disabled = value != 'false';
  }
}

class FlutterCupertinoSliderState extends WebFWidgetElementState {
  FlutterCupertinoSliderState(super.widgetElement);

  @override
  FlutterCupertinoSlider get widgetElement => super.widgetElement as FlutterCupertinoSlider;

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoSlider(
      value: widgetElement._value,
      min: widgetElement._min,
      max: widgetElement._max,
      divisions: widgetElement._divisions,
      activeColor: isDark ? CupertinoColors.activeBlue.darkColor : CupertinoColors.activeBlue,
      thumbColor: CupertinoColors.white,
      onChanged: widgetElement._disabled ? null : (double value) {
        setState(() {
          widgetElement._value = value;
        });
        widgetElement.dispatchEvent(CustomEvent('change', detail: value));
      },
      onChangeStart: (double value) {
        widgetElement.dispatchEvent(CustomEvent('changestart', detail: value));
      },
      onChangeEnd: (double value) {
        widgetElement.dispatchEvent(CustomEvent('changeend', detail: value));
      },
    );
  }
}
