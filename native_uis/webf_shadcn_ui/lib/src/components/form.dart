/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:webf/rendering.dart';
import 'package:webf/webf.dart';

import 'form_bindings_generated.dart';

/// WebF custom element that wraps shadcn_ui [ShadForm].
///
/// Exposed as `<flutter-shadcn-form>` in the DOM.
class FlutterShadcnForm extends FlutterShadcnFormBindings {
  FlutterShadcnForm(super.context);

  bool _disabled = false;
  FlutterShadcnFormAutoValidateMode? _autoValidateMode =
      FlutterShadcnFormAutoValidateMode.alwaysAfterFirstValidation;

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
  FlutterShadcnFormAutoValidateMode? get autoValidateMode => _autoValidateMode;

  @override
  set autoValidateMode(value) {
    FlutterShadcnFormAutoValidateMode? newValue;
    if (value is FlutterShadcnFormAutoValidateMode) {
      newValue = value;
    } else if (value is String) {
      newValue = FlutterShadcnFormAutoValidateMode.parse(value);
    }
    if (newValue != _autoValidateMode) {
      _autoValidateMode = newValue;
      state?.requestUpdateState(() {});
    }
  }

  ShadAutovalidateMode get shadAutovalidateMode {
    switch (_autoValidateMode) {
      case FlutterShadcnFormAutoValidateMode.disabled:
        return ShadAutovalidateMode.disabled;
      case FlutterShadcnFormAutoValidateMode.always:
        return ShadAutovalidateMode.always;
      case FlutterShadcnFormAutoValidateMode.onUserInteraction:
        return ShadAutovalidateMode.onUserInteraction;
      default:
        return ShadAutovalidateMode.alwaysAfterFirstValidation;
    }
  }

  /// Get form state from the state object
  ShadFormState? get formState {
    final currentState = state as FlutterShadcnFormState?;
    return currentState?.formKey.currentState;
  }

  /// Validate the form and return true if valid
  bool validate() {
    return formState?.validate() ?? false;
  }

  /// Save and validate the form, returning true if valid
  bool submit() {
    final result = formState?.saveAndValidate() ?? false;
    if (result) {
      final event = CustomEvent('submit', detail: {'value': value});
      dispatchEvent(event);
    }
    return result;
  }

  /// Reset the form to initial values
  void reset() {
    formState?.reset();
    dispatchEvent(Event('reset'));
  }

  /// Get current form values as a JSON string
  @override
  String? get value {
    final formValue = formState?.value ?? {};
    return jsonEncode(formValue);
  }

  /// Set form values from a JSON string or Map
  @override
  set value(dynamic newValue) {
    if (formState == null) return;

    Map<String, dynamic> valueMap;
    if (newValue is String) {
      try {
        valueMap = jsonDecode(newValue) as Map<String, dynamic>;
      } catch (e) {
        return;
      }
    } else if (newValue is Map) {
      valueMap = Map<String, dynamic>.from(newValue);
    } else {
      return;
    }

    formState!.setValue(valueMap);
  }

  /// Get a specific field value
  dynamic getFieldValue(String fieldId) {
    final formValue = formState?.value ?? {};
    return formValue[fieldId];
  }

  /// Set a specific field value
  void setFieldValue(String fieldId, dynamic fieldValue) {
    formState?.setFieldValue(fieldId, fieldValue);
  }

  /// Set error for a specific field
  void setFieldError(String fieldId, String? error) {
    try {
      formState?.setFieldError(fieldId, error);
    } catch (e) {
      // Field not found, ignore
    }
  }

  @override
  WebFWidgetElementState createState() => FlutterShadcnFormState(this);
}

class FlutterShadcnFormState extends WebFWidgetElementState {
  FlutterShadcnFormState(super.widgetElement);

  final GlobalKey<ShadFormState> formKey = GlobalKey<ShadFormState>();

  @override
  FlutterShadcnForm get widgetElement =>
      super.widgetElement as FlutterShadcnForm;

  void _onFormChanged() {
    widgetElement.dispatchEvent(Event('change'));
  }

  @override
  Widget build(BuildContext context) {
    final children = widgetElement.childNodes
        .map((node) => WebFWidgetElementChild(child: node.toWidget()))
        .toList();

    return ShadForm(
      key: formKey,
      enabled: !widgetElement.disabled,
      autovalidateMode: widgetElement.shadAutovalidateMode,
      onChanged: _onFormChanged,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// WebF custom element for form fields with ShadInputFormField.
///
/// Exposed as `<flutter-shadcn-form-field>` in the DOM.
class FlutterShadcnFormField extends WidgetElement {
  FlutterShadcnFormField(super.context);

  String? _fieldId;
  String? _label;
  String? _description;
  String? _error;
  bool _required = false;
  String _type = 'text';
  String? _placeholder;
  String? _initialValue;

  String? get fieldId => _fieldId;

  set fieldId(value) {
    final String? v = value?.toString();
    if (v != _fieldId) {
      _fieldId = v;
      state?.requestUpdateState(() {});
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

  String get type => _type;

  set type(value) {
    final String newValue = value?.toString() ?? 'text';
    if (newValue != _type) {
      _type = newValue;
      state?.requestUpdateState(() {});
    }
  }

  String? get placeholder => _placeholder;

  set placeholder(value) {
    final String? v = value?.toString();
    if (v != _placeholder) {
      _placeholder = v;
      state?.requestUpdateState(() {});
    }
  }

  String? get initialValue => _initialValue;

  set initialValue(value) {
    final String? v = value?.toString();
    if (v != _initialValue) {
      _initialValue = v;
      state?.requestUpdateState(() {});
    }
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    attributes['field-id'] = ElementAttributeProperty(
      getter: () => fieldId?.toString(),
      setter: (value) => fieldId = value,
      deleter: () => fieldId = null,
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
    attributes['type'] = ElementAttributeProperty(
      getter: () => type,
      setter: (value) => type = value,
      deleter: () => type = 'text',
    );
    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => placeholder?.toString(),
      setter: (value) => placeholder = value,
      deleter: () => placeholder = null,
    );
    attributes['initial-value'] = ElementAttributeProperty(
      getter: () => initialValue?.toString(),
      setter: (value) => initialValue = value,
      deleter: () => initialValue = null,
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

  String? _validator(String? value) {
    if (widgetElement.required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    // Check for custom error set via property
    if (widgetElement.error != null) {
      return widgetElement.error;
    }
    return null;
  }

  void _onChanged(String value) {
    final event = CustomEvent('change', detail: {'value': value});
    widgetElement.dispatchEvent(event);
  }

  @override
  Widget build(BuildContext context) {
    // If there are child nodes, render them as custom field content
    if (widgetElement.childNodes.isNotEmpty) {
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

          // Field content (children)
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

    // Otherwise, render as ShadInputFormField
    return ShadInputFormField(
      id: widgetElement.fieldId,
      initialValue: widgetElement.initialValue,
      label: widgetElement.label != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widgetElement.label!),
                if (widgetElement.required)
                  Text(
                    ' *',
                    style: TextStyle(
                      color: ShadTheme.of(context).colorScheme.destructive,
                    ),
                  ),
              ],
            )
          : null,
      description: widgetElement.description != null
          ? Text(widgetElement.description!)
          : null,
      placeholder: widgetElement.placeholder != null
          ? Text(widgetElement.placeholder!)
          : null,
      validator: _validator,
      onChanged: _onChanged,
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
