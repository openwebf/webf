/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';

import 'radio_group_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadRadioGroup].
///
/// Exposed as `<flutter-shadcn-radio-group>` in the DOM.
///
/// Note: We render radio items manually rather than using [ShadRadioGroup]
/// because [ShadRadio] relies on [ShadProvider] (InheritedWidget) which
/// does not work correctly in WebF's widget tree.
class FlutterShadcnRadioGroup extends FlutterShadcnRadioGroupBindings {
  FlutterShadcnRadioGroup(super.context);

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
  WebFWidgetElementState createState() => FlutterShadcnRadioGroupState(this);
}

class FlutterShadcnRadioGroupState extends WebFWidgetElementState {
  FlutterShadcnRadioGroupState(super.widgetElement);

  @override
  FlutterShadcnRadioGroup get widgetElement =>
      super.widgetElement as FlutterShadcnRadioGroup;

  /// Recursively find all [FlutterShadcnRadioGroupItem] descendants.
  List<FlutterShadcnRadioGroupItem> _getRadioItems() {
    return _findItemsRecursive(widgetElement.childNodes);
  }

  List<FlutterShadcnRadioGroupItem> _findItemsRecursive(
      Iterable<Node> nodes) {
    final items = <FlutterShadcnRadioGroupItem>[];
    for (final node in nodes) {
      if (node is FlutterShadcnRadioGroupItem) {
        items.add(node);
      } else if (node.childNodes.isNotEmpty) {
        items.addAll(_findItemsRecursive(node.childNodes));
      }
    }
    return items;
  }

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

  void _selectValue(String? itemValue) {
    if (widgetElement.disabled) return;
    if (itemValue != null && itemValue != widgetElement._value) {
      widgetElement._value = itemValue;
      widgetElement
          .dispatchEvent(CustomEvent('change', detail: {'value': itemValue}));
      setState(() {});
    }
  }

  String? _resolveItemValue(FlutterShadcnRadioGroupItem item) {
    final String? internalValue = item._itemValue;
    if (internalValue != null && internalValue.isNotEmpty) {
      return internalValue;
    }

    final String? attrValue = item.getAttribute('value');
    if (attrValue != null && attrValue.isNotEmpty) {
      return attrValue;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final items = _getRadioItems();

    final radioWidgets =
        items.map((item) => _buildRadioItem(item, theme)).toList();

    if (widgetElement.isHorizontal) {
      return Wrap(
        spacing: theme.radioTheme.spacing ?? 4,
        runSpacing: theme.radioTheme.runSpacing ?? 0,
        children: radioWidgets,
      );
    }

    return Wrap(
      direction: Axis.vertical,
      spacing: theme.radioTheme.spacing ?? 4,
      runSpacing: theme.radioTheme.runSpacing ?? 0,
      children: radioWidgets,
    );
  }

  /// Build a single radio item matching [ShadRadio] visual style.
  Widget _buildRadioItem(
    FlutterShadcnRadioGroupItem item,
    ShadThemeData theme,
  ) {
    var itemValue = _resolveItemValue(item);
    final isEnabled = !widgetElement.disabled && !item._itemDisabled;

    // Read theme values matching ShadRadio defaults
    final effectiveSize = theme.radioTheme.size ?? 16.0;
    final effectiveCircleSize = theme.radioTheme.circleSize ?? 10.0;
    final effectiveColor =
        theme.radioTheme.color ?? theme.colorScheme.primary;
    final effectivePadding = theme.radioTheme.padding ??
        const EdgeInsetsDirectional.only(start: 8);
    final effectiveRadioPadding =
        theme.radioTheme.radioPadding ?? const EdgeInsets.only(top: 1);

    // Extract label text from child nodes (like accordion pattern)
    final labelText = _extractTextContent(item.childNodes);

    // Defensive fallback when value binding is not available.
    if (itemValue == null && labelText.isNotEmpty) {
      itemValue = labelText.toLowerCase();
    }

    final isSelected = itemValue != null && widgetElement.value == itemValue;

    // Radio circle: outer ring + inner fill when selected
    final radioCircle = SizedBox.square(
      dimension: effectiveSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveColor,
            width: 1,
          ),
        ),
        child: isSelected
            ? Center(
                child: SizedBox.square(
                  dimension: effectiveCircleSize,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: effectiveColor,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: effectiveRadioPadding,
            child: radioCircle,
          ),
          if (labelText.isNotEmpty)
            Flexible(
              child: Padding(
                padding: effectivePadding,
                child: Text(
                  labelText,
                  style: theme.textTheme.muted.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (!isEnabled) {
      return AbsorbPointer(
        absorbing: true,
        child: Opacity(
          opacity: theme.disabledOpacity,
          child: row,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectValue(itemValue),
      child: row,
    );
  }
}

/// WebF custom element for individual radio items.
///
/// Exposed as `<flutter-shadcn-radio-group-item>` in the DOM.
class FlutterShadcnRadioGroupItem extends WidgetElement {
  FlutterShadcnRadioGroupItem(super.context);

  String? _itemValue;
  bool _itemDisabled = false;

  String? get value => _itemValue;

  set value(value) {
    final String? v = value?.toString();
    if (v != _itemValue) {
      _itemValue = v;
      _notifyParentGroup();
    }
  }

  bool get disabled => _itemDisabled;

  set disabled(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _itemDisabled) {
      _itemDisabled = v;
      _notifyParentGroup();
    }
  }

  /// Walk up the tree to find the parent [FlutterShadcnRadioGroup].
  void _notifyParentGroup() {
    Node? current = parentNode;
    while (current != null) {
      if (current is FlutterShadcnRadioGroup) {
        current.state?.requestUpdateState(() {});
        return;
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
  WebFWidgetElementState createState() =>
      FlutterShadcnRadioGroupItemState(this);
}

class FlutterShadcnRadioGroupItemState extends WebFWidgetElementState {
  FlutterShadcnRadioGroupItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is built by the parent FlutterShadcnRadioGroup
    return const SizedBox.shrink();
  }
}
