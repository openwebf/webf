/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'combobox_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui combobox functionality.
///
/// Exposed as `<flutter-shadcn-combobox>` in the DOM.
class FlutterShadcnCombobox extends FlutterShadcnComboboxBindings {
  FlutterShadcnCombobox(super.context);

  String? _value;
  String? _placeholder;
  String? _searchPlaceholder;
  String? _emptyText;
  bool _disabled = false;
  bool _clearable = false;

  @override
  String? get value => _value;

  @override
  set value(value) {
    final String? v = value;
    if (v != _value) {
      _value = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get placeholder => _placeholder;

  @override
  set placeholder(value) {
    final String? v = value;
    if (v != _placeholder) {
      _placeholder = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get searchPlaceholder => _searchPlaceholder;

  @override
  set searchPlaceholder(value) {
    final String? v = value;
    if (v != _searchPlaceholder) {
      _searchPlaceholder = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get emptyText => _emptyText;

  @override
  set emptyText(value) {
    final String? v = value;
    if (v != _emptyText) {
      _emptyText = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get disabled => _disabled;

  @override
  set disabled(value) {
    final bool v = value == true;
    if (v != _disabled) {
      _disabled = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get clearable => _clearable;

  @override
  set clearable(value) {
    final bool v = value == true;
    if (v != _clearable) {
      _clearable = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnComboboxState(this);
}

class FlutterShadcnComboboxState extends WebFWidgetElementState {
  FlutterShadcnComboboxState(super.widgetElement);

  String _searchQuery = '';

  @override
  FlutterShadcnCombobox get widgetElement =>
      super.widgetElement as FlutterShadcnCombobox;

  /// Extract text content from a list of nodes recursively.
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

  List<({String value, String label, bool disabled})> _getItems() {
    final items = <({String value, String label, bool disabled})>[];

    for (final node in widgetElement.childNodes) {
      if (node is FlutterShadcnComboboxItem) {
        final itemElement = node;
        final value = itemElement._itemValue ?? '';
        String label = value;

        if (itemElement.childNodes.isNotEmpty) {
          final textContent = _extractTextContent(itemElement.childNodes);
          if (textContent.isNotEmpty) {
            label = textContent;
          }
        }

        items.add((value: value, label: label, disabled: itemElement._itemDisabled));
      }
    }

    return items;
  }

  List<({String value, String label, bool disabled})> _getFilteredItems() {
    final items = _getItems();
    if (_searchQuery.isEmpty) return items;

    return items
        .where((item) =>
            item.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItems();
    final filteredItems = _getFilteredItems();

    // Find selected item label
    String? selectedLabel;
    if (widgetElement.value != null) {
      final selectedItem =
          items.firstWhereOrNull((item) => item.value == widgetElement.value);
      selectedLabel = selectedItem?.label;
    }

    // Build options
    final options = filteredItems.map((item) {
      return ShadOption(
        value: item.value,
        child: Text(item.label),
      );
    }).toList();

    return ShadSelect<String>.withSearch(
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
      onSearchChanged: (query) {
        _searchQuery = query;
        widgetElement.dispatchEvent(Event('search'));
        setState(() {});
      },
      searchPlaceholder: Text(widgetElement.searchPlaceholder ?? 'Search...'),
      selectedOptionBuilder: (context, value) {
        return Text(selectedLabel ?? value);
      },
    );
  }
}

/// WebF custom element for combobox items.
///
/// Exposed as `<flutter-shadcn-combobox-item>` in the DOM.
class FlutterShadcnComboboxItem extends WidgetElement {
  FlutterShadcnComboboxItem(super.context);

  String? _itemValue;
  bool _itemDisabled = false;

  String? get value => _itemValue;

  set value(value) {
    final String? v = value;
    if (v != _itemValue) {
      _itemValue = v;
      _notifyParent();
    }
  }

  bool get disabled => _itemDisabled;

  set disabled(value) {
    final bool v = value == true;
    if (v != _itemDisabled) {
      _itemDisabled = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnCombobox) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['value'] = ElementAttributeProperty(
      getter: () => value?.toString(),
      setter: (val) => value = val,
      deleter: () => value = null
    );
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (val) => disabled = val == 'true' || val == '',
      deleter: () => disabled = false
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnComboboxItemProperties = {
    'value': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnComboboxItem>(element).value,
      setter: (element, value) =>
      castToType<FlutterShadcnComboboxItem>(element).value = value,
    ),
    'disabled': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnComboboxItem>(element).disabled,
      setter: (element, value) =>
      castToType<FlutterShadcnComboboxItem>(element).disabled = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
    ...super.properties,
    flutterShadcnComboboxItemProperties,
  ];

  @override
  WebFWidgetElementState createState() => FlutterShadcnComboboxItemState(this);
}

class FlutterShadcnComboboxItemState extends WebFWidgetElementState {
  FlutterShadcnComboboxItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
