/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'form_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui form functionality.
///
/// Exposed as `<flutter-shadcn-form>` in the DOM.
class FlutterShadcnForm extends FlutterShadcnFormBindings {
  FlutterShadcnForm(super.context);

  bool _disabled = false;

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
  WebFWidgetElementState createState() => FlutterShadcnFormState(this);
}

class FlutterShadcnFormState extends WebFWidgetElementState {
  FlutterShadcnFormState(super.widgetElement);

  @override
  FlutterShadcnForm get widgetElement =>
      super.widgetElement as FlutterShadcnForm;

  @override
  Widget build(BuildContext context) {
    final children = widgetElement.childNodes
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// WebF custom element for form fields.
///
/// Exposed as `<flutter-shadcn-form-field>` in the DOM.
class FlutterShadcnFormField extends WidgetElement {
  FlutterShadcnFormField(super.context);

  String? _name;
  String? _label;
  String? _description;
  String? _error;
  bool _required = false;

  String? get name => _name;

  set name(value) {
    final String? v = value?.toString();
    if (v != _name) {
      _name = v;
    }
  }

  String? get label => _label;

  set label(value) {
    final String? v = value?.toString();
    if (v != _label) {
      _label = v;
      state?.requestUpdateState(() {});
    }
  }

  String? get description => _description;

  set description(value) {
    final String? v = value?.toString();
    if (v != _description) {
      _description = v;
      state?.requestUpdateState(() {});
    }
  }

  String? get error => _error;

  set error(value) {
    final String? v = value?.toString();
    if (v != _error) {
      _error = v;
      state?.requestUpdateState(() {});
    }
  }

  bool get required => _required;

  set required(value) {
    final bool v = value == true || value == 'true' || value == '';
    if (v != _required) {
      _required = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['name'] = ElementAttributeProperty(
      getter: () => name?.toString(),
      setter: (value) => name = value,
      deleter: () => name = null,
    );
    attributes['label'] = ElementAttributeProperty(
      getter: () => label?.toString(),
      setter: (value) => label = value,
      deleter: () => label = null,
    );
    attributes['description'] = ElementAttributeProperty(
      getter: () => description?.toString(),
      setter: (value) => description = value,
      deleter: () => description = null,
    );
    attributes['error'] = ElementAttributeProperty(
      getter: () => error?.toString(),
      setter: (value) => error = value,
      deleter: () => error = null,
    );
    attributes['required'] = ElementAttributeProperty(
      getter: () => required.toString(),
      setter: (value) => required = value == 'true' || value == '',
      deleter: () => required = false,
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnFormFieldState(this);
}

class FlutterShadcnFormFieldState extends WebFWidgetElementState {
  FlutterShadcnFormFieldState(super.widgetElement);

  @override
  FlutterShadcnFormField get widgetElement =>
      super.widgetElement as FlutterShadcnFormField;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widgetElement.label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widgetElement.label!,
                style: theme.textTheme.small.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widgetElement.required)
                Text(
                  ' *',
                  style: theme.textTheme.small.copyWith(
                    color: theme.colorScheme.destructive,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Field content
        ...widgetElement.childNodes
            .map((node) => WebFWidgetElementChild(child: node.toWidget())),

        // Description
        if (widgetElement.description != null) ...[
          const SizedBox(height: 4),
          Text(
            widgetElement.description!,
            style: theme.textTheme.muted,
          ),
        ],

        // Error
        if (widgetElement.error != null) ...[
          const SizedBox(height: 4),
          Text(
            widgetElement.error!,
            style: theme.textTheme.small.copyWith(
              color: theme.colorScheme.destructive,
            ),
          ),
        ],
      ],
    );
  }
}

/// WebF custom element for form labels.
///
/// Exposed as `<flutter-shadcn-form-label>` in the DOM.
class FlutterShadcnFormLabel extends WidgetElement {
  FlutterShadcnFormLabel(super.context);

  @override
  WebFWidgetElementState createState() => FlutterShadcnFormLabelState(this);
}

class FlutterShadcnFormLabelState extends WebFWidgetElementState {
  FlutterShadcnFormLabelState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.small.copyWith(
        fontWeight: FontWeight.w500,
      ),
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}

/// WebF custom element for form descriptions.
///
/// Exposed as `<flutter-shadcn-form-description>` in the DOM.
class FlutterShadcnFormDescription extends WidgetElement {
  FlutterShadcnFormDescription(super.context);

  @override
  WebFWidgetElementState createState() =>
      FlutterShadcnFormDescriptionState(this);
}

class FlutterShadcnFormDescriptionState extends WebFWidgetElementState {
  FlutterShadcnFormDescriptionState(super.widgetElement);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return DefaultTextStyle(
      style: theme.textTheme.muted,
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}

/// WebF custom element for form validation messages.
///
/// Exposed as `<flutter-shadcn-form-message>` in the DOM.
class FlutterShadcnFormMessage extends WidgetElement {
  FlutterShadcnFormMessage(super.context);

  String _type = 'error';

  String get type => _type;

  set type(value) {
    final String newValue = value?.toString() ?? 'error';
    if (newValue != _type) {
      _type = newValue;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['type'] = ElementAttributeProperty(
      getter: () => type,
      setter: (value) => type = value,
      deleter: () => type = 'error',
    );
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnFormMessageState(this);
}

class FlutterShadcnFormMessageState extends WebFWidgetElementState {
  FlutterShadcnFormMessageState(super.widgetElement);

  @override
  FlutterShadcnFormMessage get widgetElement =>
      super.widgetElement as FlutterShadcnFormMessage;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    Color textColor;
    switch (widgetElement.type) {
      case 'success':
        textColor = Colors.green;
        break;
      case 'info':
        textColor = theme.colorScheme.primary;
        break;
      default:
        textColor = theme.colorScheme.destructive;
    }

    return DefaultTextStyle(
      style: theme.textTheme.small.copyWith(color: textColor),
      child: WebFWidgetElementChild(
        child: WebFHTMLElement(
          tagName: 'SPAN',
          controller: widgetElement.ownerDocument.controller,
          parentElement: widgetElement,
          children: widgetElement.childNodes.toWidgetList(),
        ),
      ),
    );
  }
}
