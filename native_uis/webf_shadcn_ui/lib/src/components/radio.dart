/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'radio_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadRadioGroup].
///
/// Exposed as `<flutter-shadcn-radio>` in the DOM.
class FlutterShadcnRadio extends FlutterShadcnRadioBindings {
  FlutterShadcnRadio(super.context);

  String? _value;
  bool _disabled = false;
  String _orientation = 'vertical';

  @override
  String? get value => _value;

  @override
  set value(value) {
    final String? v = value?.toString();
    if (v != _value) {
      _value = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _disabled) {
      _disabled = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get orientation => _orientation;

  @override
  set orientation(value) {
    final String newValue = value?.toString() ?? 'vertical';
    if (newValue != _orientation) {
      _orientation = newValue;
      state?.requestUpdateState(() {});
    }
  }

  bool get isHorizontal => _orientation.toLowerCase() == 'horizontal';

  @override
  WebFWidgetElementState createState() => FlutterShadcnRadioState(this);
}

class FlutterShadcnRadioState extends WebFWidgetElementState {
  FlutterShadcnRadioState(super.widgetElement);

  @override
  FlutterShadcnRadio get widgetElement =>
      super.widgetElement as FlutterShadcnRadio;

  List<FlutterShadcnRadioItem> _getRadioItems() {
    return widgetElement.childNodes
        .whereType<FlutterShadcnRadioItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getRadioItems();

    final radioItems = items.map((item) {
      Widget? labelWidget;
      if (item.childNodes.isNotEmpty) {
        labelWidget = WebFWidgetElementChild(
          child: item.childNodes.first.toWidget(),
        );
      }

      return ShadRadio<String>(
        value: item._itemValue ?? '',
        enabled: !widgetElement.disabled && !item._itemDisabled,
        label: labelWidget,
      );
    }).toList();

    return ShadRadioGroup<String>(
      initialValue: widgetElement.value,
      enabled: !widgetElement.disabled,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('change'));
      },
      items: radioItems,
    );
  }
}

/// WebF custom element for individual radio items.
///
/// Exposed as `<flutter-shadcn-radio-item>` in the DOM.
class FlutterShadcnRadioItem extends WidgetElement {
  FlutterShadcnRadioItem(super.context);

  String? _itemValue;
  bool _itemDisabled = false;

  String? get value => _itemValue;

  set value(value) {
    final String? v = value?.toString();
    if (v != _itemValue) {
      _itemValue = v;
      _notifyParent();
    }
  }

  bool get disabled => _itemDisabled;

  set disabled(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _itemDisabled) {
      _itemDisabled = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnRadio) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['value'] = ElementAttributeProperty(
      getter: () => value?.toString(),
      setter: (v) => value = v,
      deleter: () => value = null,
    );
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (value) => disabled = value == 'true' || value == '',
      deleter: () => disabled = false,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnRadioItemState(this);
}

class FlutterShadcnRadioItemState extends WebFWidgetElementState {
  FlutterShadcnRadioItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is built by the parent FlutterShadcnRadio
    return const SizedBox.shrink();
  }
}
