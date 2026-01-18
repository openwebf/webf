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
    }
  }

  bool get isMultiple => _type == 'multiple';

  Set<String> get expandedValues {
    if (_value == null) return {};
    return _value!.split(',').map((e) => e.trim()).toSet();
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
    final expanded = widgetElement.expandedValues;

    if (widgetElement.isMultiple) {
      if (expanded.contains(itemValue)) {
        expanded.remove(itemValue);
      } else {
        expanded.add(itemValue);
      }
      widgetElement._value = expanded.join(',');
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
      children: items.map((item) {
        final isExpanded =
            widgetElement.expandedValues.contains(item._itemValue);
        return _AccordionItemWidget(
          item: item,
          isExpanded: isExpanded,
          onToggle: () => _toggleItem(item._itemValue ?? ''),
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

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    Widget? triggerContent;
    Widget? contentContent;

    for (final node in item.childNodes) {
      if (node is FlutterShadcnAccordionTrigger) {
        triggerContent = WebFWidgetElementChild(child: node.toWidget());
      } else if (node is FlutterShadcnAccordionContent) {
        contentContent = WebFWidgetElementChild(child: node.toWidget());
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
          // Trigger
          GestureDetector(
            onTap: item._itemDisabled ? null : onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: item._itemDisabled
                            ? theme.colorScheme.mutedForeground
                            : null,
                      ),
                      child: triggerContent ?? const SizedBox.shrink(),
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
          // Content
          if (isExpanded && contentContent != null)
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: contentContent,
            ),
        ],
      ),
    );
  }
}

/// WebF custom element for accordion item.
class FlutterShadcnAccordionItem extends WidgetElement {
  FlutterShadcnAccordionItem(super.context);

  String? _itemValue;
  bool _itemDisabled = false;

  String? get value => _itemValue;

  set value(value) {
    final newValue = value?.toString();
    if (newValue != _itemValue) {
      _itemValue = newValue;
    }
  }

  bool get disabled => _itemDisabled;

  set disabled(value) {
    final newValue = value == true;
    if (newValue != _itemDisabled) {
      _itemDisabled = newValue;
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['value'] = ElementAttributeProperty(
      getter: () => value,
      setter: (v) => value = v,
      deleter: () => value = null,
    );
    attributes['disabled'] = ElementAttributeProperty(
      getter: () => disabled.toString(),
      setter: (v) => disabled = v == 'true' || v == '',
      deleter: () => disabled = false,
    );
  }

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
