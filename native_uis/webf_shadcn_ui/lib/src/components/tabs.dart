/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'tabs_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadTabs].
///
/// Exposed as `<flutter-shadcn-tabs>` in the DOM.
class FlutterShadcnTabs extends FlutterShadcnTabsBindings {
  FlutterShadcnTabs(super.context);

  String? _value;
  String? _defaultValue;

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
  String? get defaultValue => _defaultValue;

  @override
  set defaultValue(value) {
    final String? v = value?.toString();
    if (v != _defaultValue) {
      _defaultValue = v;
    }
  }

  String? get activeValue => _value ?? _defaultValue;

  @override
  WebFWidgetElementState createState() => FlutterShadcnTabsState(this);
}

class FlutterShadcnTabsState extends WebFWidgetElementState {
  FlutterShadcnTabsState(super.widgetElement);

  @override
  FlutterShadcnTabs get widgetElement =>
      super.widgetElement as FlutterShadcnTabs;

  FlutterShadcnTabsList? _findTabsList() {
    return widgetElement.childNodes
        .whereType<FlutterShadcnTabsList>()
        .firstOrNull;
  }

  List<FlutterShadcnTabsContent> _findTabsContents() {
    return widgetElement.childNodes
        .whereType<FlutterShadcnTabsContent>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabsList = _findTabsList();
    final contents = _findTabsContents();

    // Build tabs data
    final triggers = tabsList?.childNodes
            .whereType<FlutterShadcnTabsTrigger>()
            .toList() ??
        [];

    final tabs = triggers.map((trigger) {
      final contentWidget = contents
          .firstWhereOrNull((c) => c._contentValue == trigger._triggerValue);

      String label = trigger._triggerValue ?? '';
      if (trigger.childNodes.isNotEmpty) {
        final textContent = trigger.childNodes
            .map((n) => n is dom.TextNode ? n.data : '')
            .join('')
            .trim();
        if (textContent.isNotEmpty) {
          label = textContent;
        }
      }

      return ShadTab(
        value: trigger._triggerValue ?? '',
        content: contentWidget != null
            ? WebFWidgetElementChild(child: contentWidget.toWidget())
            : const SizedBox.shrink(),
        enabled: !trigger._triggerDisabled,
        child: Text(label),
      );
    }).toList();

    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return ShadTabs<String>(
      value: widgetElement.activeValue ?? tabs.first.value,
      onChanged: (value) {
        widgetElement._value = value;
        widgetElement.dispatchEvent(Event('change'));
        widgetElement.state?.requestUpdateState(() {});
      },
      tabs: tabs,
    );
  }
}

/// WebF custom element for tabs list container.
///
/// Exposed as `<flutter-shadcn-tabs-list>` in the DOM.
class FlutterShadcnTabsList extends WidgetElement {
  FlutterShadcnTabsList(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnTabsListState(this);
}

class FlutterShadcnTabsListState extends WebFWidgetElementState {
  FlutterShadcnTabsListState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    // This widget is built by the parent FlutterShadcnTabs
    return const SizedBox.shrink();
  }
}

/// WebF custom element for tab triggers.
///
/// Exposed as `<flutter-shadcn-tabs-trigger>` in the DOM.
class FlutterShadcnTabsTrigger extends WidgetElement {
  FlutterShadcnTabsTrigger(super.context);

  String? _triggerValue;
  bool _triggerDisabled = false;

  String? get value => _triggerValue;

  set value(value) {
    final String? v = value?.toString();
    if (v != _triggerValue) {
      _triggerValue = v;
      _notifyParent();
    }
  }

  bool get disabled => _triggerDisabled;

  set disabled(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _triggerDisabled) {
      _triggerDisabled = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final tabsList = parentNode;
    if (tabsList is FlutterShadcnTabsList) {
      final tabs = tabsList.parentNode;
      if (tabs is FlutterShadcnTabs) {
        tabs.state?.requestUpdateState(() {});
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
      setter: (v) => disabled = v == 'true' || v == '',
      deleter: () => disabled = false,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTabsTriggerState(this);
}

class FlutterShadcnTabsTriggerState extends WebFWidgetElementState {
  FlutterShadcnTabsTriggerState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// WebF custom element for tab content panels.
///
/// Exposed as `<flutter-shadcn-tabs-content>` in the DOM.
class FlutterShadcnTabsContent extends WidgetElement {
  FlutterShadcnTabsContent(super.context);

  String? _contentValue;

  String? get value => _contentValue;

  set value(value) {
    final String? v = value?.toString();
    if (v != _contentValue) {
      _contentValue = v;
      _notifyParent();
    }
  }

  void _notifyParent() {
    final tabs = parentNode;
    if (tabs is FlutterShadcnTabs) {
      tabs.state?.requestUpdateState(() {});
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
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnTabsContentState(this);
}

class FlutterShadcnTabsContentState extends WebFWidgetElementState {
  FlutterShadcnTabsContentState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    return WebFWidgetElementChild(
      child: WebFHTMLElement(
        tagName: 'DIV',
        controller: widgetElement.ownerDocument.controller,
        parentElement: widgetElement,
        children: widgetElement.childNodes.toWidgetList(),
      ),
    );
  }
}
