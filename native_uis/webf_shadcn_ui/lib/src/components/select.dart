/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

import 'select_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadSelect].
///
/// Exposed as `<flutter-shadcn-select>` in the DOM.
class FlutterShadcnSelect extends FlutterShadcnSelectBindings {
  FlutterShadcnSelect(super.context);

  String? _value;
  String? _placeholder;
  bool _disabled = false;
  bool _multiple = false;
  bool _searchable = false;
  String? _searchPlaceholder;

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
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final String? v = value?.toString();
    if (v != _placeholder) {
      _placeholder = v;
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
  bool get multiple => _multiple;

  @override
  set multiple(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _multiple) {
      _multiple = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get searchable => _searchable;

  @override
  set searchable(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _searchable) {
      _searchable = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get searchPlaceholder => _searchPlaceholder;

  @override
  set searchPlaceholder(value) {
    final String? v = value?.toString();
    if (v != _searchPlaceholder) {
      _searchPlaceholder = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectState(this);
}

class FlutterShadcnSelectState extends WebFWidgetElementState {
  FlutterShadcnSelectState(super.widgetElement);

  @override
  FlutterShadcnSelect get widgetElement =>
      super.widgetElement as FlutterShadcnSelect;

  List<ShadOption<String>> _buildOptions() {
    final options = <ShadOption<String>>[];

    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnSelectItem) {
        final value = node._itemValue ?? '';
        String label = value;

        // Get label from child text content
        if (node.childNodes.isNotEmpty) {
          final textContent = node.childNodes
              .map((n) => n is dom.TextNode ? n.data : '')
              .join('')
              .trim();
          if (textContent.isNotEmpty) {
            label = textContent;
          }
        }

        options.add(ShadOption(
          value: value,
          child: Text(label),
        ));
      } else if (node is FlutterShadcnSelectGroup) {
        // Handle groups - add items from the group
        for (final groupChild in node.childNodes) {
          if (groupChild is FlutterShadcnSelectItem) {
            final value = groupChild._itemValue ?? '';
            String label = value;

            if (groupChild.childNodes.isNotEmpty) {
              final textContent = groupChild.childNodes
                  .map((n) => n is dom.TextNode ? n.data : '')
                  .join('')
                  .trim();
              if (textContent.isNotEmpty) {
                label = textContent;
              }
            }

            options.add(ShadOption(
              value: value,
              child: Text(label),
            ));
          }
        }
      }
    }

    return options;
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();

    return ShadSelect<String>(
      initialValue: widgetElement.value,
      placeholder: widgetElement.placeholder != null
          ? Text(widgetElement.placeholder!)
          : null,
      enabled: !widgetElement.disabled,
      options: options,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('change'));
      },
      selectedOptionBuilder: (context, value) {
        final option = options.firstWhereOrNull((o) => o.value == value);
        if (option != null) {
          return option.child;
        }
        return Text(value);
      },
    );
  }
}

/// WebF custom element for select items.
///
/// Exposed as `<flutter-shadcn-select-item>` in the DOM.
class FlutterShadcnSelectItem extends WidgetElement {
  FlutterShadcnSelectItem(super.context);

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
    if (parent is FlutterShadcnSelect) {
      parent.state?.requestUpdateState(() {});
    } else if (parent is FlutterShadcnSelectGroup) {
      final grandParent = parent.parentNode;
      if (grandParent is FlutterShadcnSelect) {
        grandParent.state?.requestUpdateState(() {});
      }
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
  WebFWidgetElementState createState() => FlutterShadcnSelectItemState(this);
}

class FlutterShadcnSelectItemState extends WebFWidgetElementState {
  FlutterShadcnSelectItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for select option groups.
///
/// Exposed as `<flutter-shadcn-select-group>` in the DOM.
class FlutterShadcnSelectGroup extends WidgetElement {
  FlutterShadcnSelectGroup(super.context);

  String? _label;

  String? get label => _label;

  set label(value) {
    final String? v = value?.toString();
    if (v != _label) {
      _label = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnSelect) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['label'] = ElementAttributeProperty(
      getter: () => label?.toString(),
      setter: (value) => label = value,
      deleter: () => label = null,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectGroupState(this);
}

class FlutterShadcnSelectGroupState extends WebFWidgetElementState {
  FlutterShadcnSelectGroupState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for select separators.
///
/// Exposed as `<flutter-shadcn-select-separator>` in the DOM.
class FlutterShadcnSelectSeparator extends WidgetElement {
  FlutterShadcnSelectSeparator(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnSelectSeparatorState(this);
}

class FlutterShadcnSelectSeparatorState extends WebFWidgetElementState {
  FlutterShadcnSelectSeparatorState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
