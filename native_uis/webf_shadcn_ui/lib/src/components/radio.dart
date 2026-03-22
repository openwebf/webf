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

  @override
  Widget build(BuildContext context) {
    final groupChildren = widgetElement.childNodes
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();

    return ShadRadioGroup<String>(
      initialValue: widgetElement.value,
      axis: widgetElement.isHorizontal ? Axis.horizontal : Axis.vertical,
      enabled: !widgetElement.disabled,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(
          CustomEvent('change', detail: {'value': value}),
        );
        widgetElement.state?.requestUpdateState(() {});
      },
      items: groupChildren,
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
    state?.requestUpdateState(() {});

    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnRadio) {
        current.state?.requestUpdateState(() {});
        break;
      }
      current = current.parentNode;
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

  static StaticDefinedBindingPropertyMap flutterShadcnRadioItemProperties = {
    'value': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnRadioItem>(element).value,
      setter: (element, value) =>
          castToType<FlutterShadcnRadioItem>(element).value = value,
    ),
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnRadioItem>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnRadioItem>(element).disabled = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnRadioItemProperties,
      ];

  @override
  WebFWidgetElementState createState() => FlutterShadcnRadioItemState(this);
}

class FlutterShadcnRadioItemState extends WebFWidgetElementState {
  FlutterShadcnRadioItemState(super.widgetElement);

  @override
  FlutterShadcnRadioItem get widgetElement =>
      super.widgetElement as FlutterShadcnRadioItem;

  FlutterShadcnRadio? _findRadioGroup() {
    Node? current = widgetElement.parentNode;
    while (current != null) {
      if (current is FlutterShadcnRadio) return current;
      current = current.parentNode;
    }
    return null;
  }

  String _extractTextContent(Iterable<Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final radioGroup = _findRadioGroup();
    final labelText = _extractTextContent(widgetElement.childNodes);
    final effectiveValue =
        widgetElement.value ?? widgetElement.getAttribute('value');

    return ShadRadio<String>(
      value: effectiveValue ?? '',
      enabled: !(radioGroup?.disabled ?? false) && !widgetElement._itemDisabled,
      label: labelText.isNotEmpty ? Text(labelText) : null,
    );
  }
}
