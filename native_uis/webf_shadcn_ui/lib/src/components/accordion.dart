/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/webf.dart';
import 'package:webf/rendering.dart';

import 'accordion_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadAccordion].
///
/// Exposed as `<flutter-shadcn-accordion>` in the DOM.
class FlutterShadcnAccordion extends FlutterShadcnAccordionBindings {
  FlutterShadcnAccordion(super.context);

  String _type = 'single';
  String? _value;
  bool _collapsible = true;

  @override
  String get type => _type;

  @override
  set type(value) {
    final newValue = value?.toString() ?? 'single';
    if (newValue != _type) {
      _type = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String? get value => _value;

  @override
  set value(value) {
    final newValue = value?.toString();
    if (newValue != _value) {
      _value = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get collapsible => _collapsible;

  @override
  set collapsible(value) {
    final newValue = value == true;
    if (newValue != _collapsible) {
      _collapsible = newValue;
      state?.requestUpdateState(() {});
    }
  }

  bool get isMultiple => _type == 'multiple';

  Set<String> get expandedValues {
    final raw = _value?.trim();
    if (raw == null || raw.isEmpty) return {};
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnAccordionState(this);
}

class FlutterShadcnAccordionState extends WebFWidgetElementState {
  FlutterShadcnAccordionState(super.widgetElement);

  @override
  FlutterShadcnAccordion get widgetElement =>
      super.widgetElement as FlutterShadcnAccordion;

  void _toggleItem(String itemValue) {
    if (itemValue.trim().isEmpty) return;

    final expanded = widgetElement.expandedValues;

    if (widgetElement.isMultiple) {
      if (expanded.contains(itemValue)) {
        expanded.remove(itemValue);
      } else {
        expanded.add(itemValue);
      }
      if (expanded.isEmpty) {
        widgetElement._value = null;
      } else {
        final values = expanded.toList()..sort();
        widgetElement._value = values.join(',');
      }
    } else {
      if (expanded.contains(itemValue) && widgetElement.collapsible) {
        widgetElement._value = null;
      } else {
        widgetElement._value = itemValue;
      }
    }

    widgetElement.dispatchEvent(Event('change'));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widgetElement.childNodes
        .whereType<FlutterShadcnAccordionItem>()
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final itemValue = item.value ?? 'item-$index';
        final isExpanded = widgetElement.expandedValues.contains(itemValue);
        return _AccordionItemWidget(
          item: item,
          isExpanded: isExpanded,
          onToggle: () => _toggleItem(itemValue),
        );
      }).toList(),
    );
  }
}

class _AccordionItemWidget extends StatelessWidget {
  final FlutterShadcnAccordionItem item;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AccordionItemWidget({
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    String triggerText = '';
    String contentText = '';

    for (final node in item.childNodes) {
      if (node is FlutterShadcnAccordionTrigger) {
        triggerText = _extractTextContent(node.childNodes);
      } else if (node is FlutterShadcnAccordionContent) {
        contentText = _extractTextContent(node.childNodes);
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Trigger - use GestureDetector with opaque behavior to ensure taps are received
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: item._itemDisabled ? null : onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      triggerText,
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: item._itemDisabled
                            ? theme.colorScheme.mutedForeground
                            : null,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content with animation
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                contentText,
                style: theme.textTheme.muted,
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// WebF custom element for accordion item.
class FlutterShadcnAccordionItem extends WidgetElement {
  FlutterShadcnAccordionItem(super.context);

  // Local storage for attributes
  String? _itemValue;
  bool _itemDisabled = false;

  String? get value => _itemValue;

  set value(dynamic val) {
    final v = val?.toString();
    if (v != _itemValue) {
      _itemValue = v;
      _notifyParent();
    }
  }

  bool get disabled => _itemDisabled;

  set disabled(dynamic val) {
    final v = val == true || val == 'true' || val == '' || val == 'disabled';
    if (v != _itemDisabled) {
      _itemDisabled = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final parent = parentNode;
    if (parent is FlutterShadcnAccordion) {
      parent.state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['value'] = ElementAttributeProperty(
      getter: () => _itemValue,
      setter: (v) {
        value = v;
      },
      deleter: () => value = null,
    );
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => _itemDisabled ? 'true' : null,
      setter: (v) {
        disabled = v;
      },
      deleter: () => disabled = false,
    );
  }

  static StaticDefinedBindingPropertyMap flutterShadcnAccordionItemProperties = {
    'value': StaticDefinedBindingProperty(
      getter: (element) => castToType<FlutterShadcnAccordionItem>(element).value,
      setter: (element, value) =>
          castToType<FlutterShadcnAccordionItem>(element).value = value,
    ),
    'disabled': StaticDefinedBindingProperty(
      getter: (element) =>
          castToType<FlutterShadcnAccordionItem>(element).disabled,
      setter: (element, value) =>
          castToType<FlutterShadcnAccordionItem>(element).disabled = value,
    ),
  };

  @override
  List<StaticDefinedBindingPropertyMap> get properties => [
        ...super.properties,
        flutterShadcnAccordionItemProperties,
      ];

  @override
  WebFWidgetElementState createState() => FlutterShadcnAccordionItemState(this);
}

class FlutterShadcnAccordionItemState extends WebFWidgetElementState {
  FlutterShadcnAccordionItemState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for accordion trigger.
class FlutterShadcnAccordionTrigger extends WidgetElement {
  FlutterShadcnAccordionTrigger(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnAccordionTriggerState(this);
}

class FlutterShadcnAccordionTriggerState extends WebFWidgetElementState {
  FlutterShadcnAccordionTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'SPAN',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}

/// WebF custom element for accordion content.
class FlutterShadcnAccordionContent extends WidgetElement {
  FlutterShadcnAccordionContent(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnAccordionContentState(this);
}

class FlutterShadcnAccordionContentState extends WebFWidgetElementState {
  FlutterShadcnAccordionContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.muted,
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'DIV',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}
