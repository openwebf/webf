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
          setState(() {});
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
          setState(() {});
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
          setState(() {});
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
          setState(() {});
        }
      }
    );

    // Disabled state
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _disabled.toString(),
      setter: (val) {
        _disabled = val != 'false';
        setState(() {});
      }
    );
  }

  @override
  Widget build(BuildContext context, ChildNodeList childNodes) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoSlider(
      value: _value,
      min: _min,
      max: _max,
      divisions: _divisions,
      activeColor: isDark ? CupertinoColors.activeBlue.darkColor : CupertinoColors.activeBlue,
      thumbColor: CupertinoColors.white,
      onChanged: _disabled ? null : (double value) {
        _value = value;
        dispatchEvent(CustomEvent('change', detail: value));
        setState(() {});
      },
      onChangeStart: (double value) {
        dispatchEvent(CustomEvent('changestart', detail: value));
      },
      onChangeEnd: (double value) {
        dispatchEvent(CustomEvent('changeend', detail: value));
      },
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
          slider.setState(() {});
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
}
