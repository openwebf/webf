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
  bool _allowDeselection = false;
  bool _closeOnSelect = true;

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
  bool get allowDeselection => _allowDeselection;

  @override
  set allowDeselection(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _allowDeselection) {
      _allowDeselection = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get closeOnSelect => _closeOnSelect;

  @override
  set closeOnSelect(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _closeOnSelect) {
      _closeOnSelect = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectState(this);
}

class FlutterShadcnSelectState extends WebFWidgetElementState {
  FlutterShadcnSelectState(super.widgetElement);

  String _searchValue = '';

  @override
  FlutterShadcnSelect get widgetElement =>
      super.widgetElement as FlutterShadcnSelect;

  String _extractTextContent(Iterable<dom.Node> nodes) {
    final buffer = StringBuffer();
    for (final node in nodes) {
      if (node is dom.TextNode) {
        buffer.write(node.data);
      } else if (node.childNodes.isNotEmpty) {
        buffer.write(_extractTextContent(node.childNodes));
      }
    }
    return buffer.toString().trim();
  }

  List<ShadOption<String>> _buildOptionsFromNodes(Iterable<dom.Node> nodes) {
    final options = <ShadOption<String>>[];

    for (final node in nodes) {
      if (node is FlutterShadcnSelectItem) {
        final value = node._itemValue ?? '';
        String label = _extractTextContent(node.childNodes);
        if (label.isEmpty) {
          label = value;
        }

        // Filter by search if searchable
        if (widgetElement.searchable && _searchValue.isNotEmpty) {
          if (!label.toLowerCase().contains(_searchValue.toLowerCase())) {
            continue;
          }
        }

        options.add(ShadOption(
          value: value,
          child: Text(label),
        ));
      } else if (node is FlutterShadcnSelectGroup) {
        // Add group label if present
        final groupLabel = node._label;
        if (groupLabel != null && groupLabel.isNotEmpty) {
          // Check if any items in this group match the search
          bool hasMatchingItems = true;
          if (widgetElement.searchable && _searchValue.isNotEmpty) {
            hasMatchingItems = node.childNodes.any((child) {
              if (child is FlutterShadcnSelectItem) {
                final label = _extractTextContent(child.childNodes);
                return label.toLowerCase().contains(_searchValue.toLowerCase());
              }
              return false;
            });
          }

          if (hasMatchingItems) {
            options.add(ShadOption(
              value: '__group_label_${groupLabel}__',
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  groupLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ));
          }
        }

        // Add items from the group
        options.addAll(_buildOptionsFromNodes(node.childNodes));
      } else if (node is FlutterShadcnSelectLabel) {
        final label = _extractTextContent(node.childNodes);
        if (label.isNotEmpty) {
          options.add(ShadOption(
            value: '__label_${label}__',
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ));
        }
      } else if (node is FlutterShadcnSelectContent) {
        // Process content children
        options.addAll(_buildOptionsFromNodes(node.childNodes));
      }
    }

    return options;
  }

  List<ShadOption<String>> _buildOptions() {
    return _buildOptionsFromNodes(widgetElement.childNodes);
  }

  String? _getPlaceholder() {
    // First check for trigger with placeholder
    final trigger = widgetElement.childNodes
        .firstWhereOrNull((n) => n is FlutterShadcnSelectTrigger);
    if (trigger is FlutterShadcnSelectTrigger && trigger._placeholder != null) {
      return trigger._placeholder;
    }
    // Fall back to select's placeholder property
    return widgetElement.placeholder;
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();
    final placeholder = _getPlaceholder() ?? 'Select...';

    if (widgetElement.searchable) {
      return ShadSelect<String>.withSearch(
        initialValue: widgetElement.value,
        placeholder: Text(placeholder),
        enabled: !widgetElement.disabled,
        options: options,
        allowDeselection: widgetElement.allowDeselection,
        closeOnSelect: widgetElement.closeOnSelect,
        searchPlaceholder: widgetElement.searchPlaceholder != null
            ? Text(widgetElement.searchPlaceholder!)
            : const Text('Search...'),
        onSearchChanged: (value) {
          setState(() {
            _searchValue = value;
          });
        },
        onChanged: (value) {
          widgetElement._value = value;
          widgetElement
              .dispatchEvent(CustomEvent('change', detail: {'value': value}));
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

    if (widgetElement.multiple) {
      return ShadSelect<String>.multiple(
        initialValues:
            widgetElement.value != null ? {widgetElement.value!} : {},
        placeholder: Text(placeholder),
        enabled: !widgetElement.disabled,
        options: options,
        allowDeselection: widgetElement.allowDeselection,
        closeOnSelect: widgetElement.closeOnSelect,
        onChanged: (values) {
          widgetElement._value = values.join(',');
          widgetElement.dispatchEvent(
              CustomEvent('change', detail: {'value': widgetElement._value}));
        },
        selectedOptionsBuilder: (context, values) {
          if (values.isEmpty) {
            return Text(placeholder);
          }
          return Text(values.join(', '));
        },
      );
    }

    return ShadSelect<String>(
      initialValue: widgetElement.value,
      placeholder: Text(placeholder),
      enabled: !widgetElement.disabled,
      options: options,
      allowDeselection: widgetElement.allowDeselection,
      closeOnSelect: widgetElement.closeOnSelect,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement
            .dispatchEvent(CustomEvent('change', detail: {'value': value}));
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

/// WebF custom element for select trigger.
///
/// Exposed as `<flutter-shadcn-select-trigger>` in the DOM.
class FlutterShadcnSelectTrigger extends WidgetElement {
  FlutterShadcnSelectTrigger(super.context);

  String? _placeholder;

  String? get placeholder => _placeholder;

  set placeholder(value) {
    final String? v = value?.toString();
    if (v != _placeholder) {
      _placeholder = v;
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
    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => placeholder?.toString(),
      setter: (value) => placeholder = value,
      deleter: () => placeholder = null,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectTriggerState(this);
}

class FlutterShadcnSelectTriggerState extends WebFWidgetElementState {
  FlutterShadcnSelectTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Trigger is handled by the parent Select, return empty
    return const SizedBox.shrink();
  }
}

/// WebF custom element for select content.
///
/// Exposed as `<flutter-shadcn-select-content>` in the DOM.
class FlutterShadcnSelectContent extends WidgetElement {
  FlutterShadcnSelectContent(super.context);

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnSelect) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectContentState(this);
}

class FlutterShadcnSelectContentState extends WebFWidgetElementState {
  FlutterShadcnSelectContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // Content is handled by the parent Select, return empty
    return const SizedBox.shrink();
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
    dom.Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnSelect) {
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
    dom.Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnSelect) {
        current.state?.requestUpdateState(() {});
        break;
      }
      current = current.parentNode;
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

/// WebF custom element for select labels.
///
/// Exposed as `<flutter-shadcn-select-label>` in the DOM.
class FlutterShadcnSelectLabel extends WidgetElement {
  FlutterShadcnSelectLabel(super.context);

  void _notifyParent() {
    dom.Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnSelect) {
        current.state?.requestUpdateState(() {});
        break;
      }
      current = current.parentNode;
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnSelectLabelState(this);
}

class FlutterShadcnSelectLabelState extends WebFWidgetElementState {
  FlutterShadcnSelectLabelState(super.widgetElement);

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
