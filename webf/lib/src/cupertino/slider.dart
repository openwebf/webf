/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/cupertino.dart';
import 'package:webf/webf.dart';

class FlutterCupertinoSlider extends WidgetElement {
  FlutterCupertinoSlider(super.context);

  double _value = 0.0;
  double _min = 0.0;
  double _max = 100.0;
  int? _divisions;
  bool _disabled = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Current value
    attributes['val'] = ElementAttributeProperty(
      getter: () => _value.toString(),
      setter: (val) {
        final newValue = double.tryParse(val) ?? _value;
        if (newValue != _value) {
          _value = newValue.clamp(_min, _max);
        }
      }
    );

    // Minimum value
    attributes['min'] = ElementAttributeProperty(
      getter: () => _min.toString(),
      setter: (val) {
        final newMin = double.tryParse(val) ?? _min;
        if (newMin != _min) {
          _min = newMin;
          _value = _value.clamp(_min, _max);
        }
      }
    );

    // Maximum value
    attributes['max'] = ElementAttributeProperty(
      getter: () => _max.toString(),
      setter: (val) {
        final newMax = double.tryParse(val) ?? _max;
        if (newMax != _max) {
          _max = newMax;
          _value = _value.clamp(_min, _max);
        }
      }
    );

    // Step divisions
    attributes['step'] = ElementAttributeProperty(
      getter: () => _divisions?.toString() ?? '',
      setter: (val) {
        final steps = int.tryParse(val);
        if (steps != _divisions) {
          _divisions = steps;
        }
      }
    );

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (val) {
        _disabled = val != 'false';
      }
    );
  }

  // Define static method map
  static StaticDefinedSyncBindingObjectMethodMap sliderSyncMethods = {
    'getValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final slider = castToType<FlutterCupertinoSlider>(element);
        return slider._value;
      },
    ),
    'setValue': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final slider = castToType<FlutterCupertinoSlider>(element);
        if (args.isNotEmpty) {
          final newValue = double.tryParse(args[0].toString()) ?? slider._value;
          slider._value = newValue.clamp(slider._min, slider._max);
        }
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    sliderSyncMethods,
  ];

  @override
  WebFWidgetElementState createState() {
    return FlutterCupertinoSliderState(this);
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
