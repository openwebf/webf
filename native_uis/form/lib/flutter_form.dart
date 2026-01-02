/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

import 'flutter_form_bindings_generated.dart';

// Define validation rule types
enum ValidatorType {
  string,
  number,
  boolean,
  url,
  email,
}

// Validation rule structure
class ValidationRule {
  final String? message; // Error message
  final List<String>? enumValues; // Enum values
  final int? len; // Fixed length
  final int? minLength; // Minimum length
  final int? maxLength; // Maximum length
  final num? min; // Minimum value
  final num? max; // Maximum value
  final bool? required; // Whether required
  final ValidatorType? type; // Data type

  ValidationRule({
    this.message,
    this.enumValues,
    this.len,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.required,
    this.type,
  });

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    ValidatorType? parseType(String? typeStr) {
      if (typeStr == null) return null;
      switch (typeStr.toLowerCase()) {
        case 'string':
          return ValidatorType.string;
        case 'number':
          return ValidatorType.number;
        case 'boolean':
          return ValidatorType.boolean;
        case 'url':
          return ValidatorType.url;
        case 'email':
          return ValidatorType.email;
        default:
          return null;
      }
    }

    return ValidationRule(
      message: json['message'] as String?,
      enumValues: json['enum'] != null ? List<String>.from(json['enum']) : null,
      len: json['len'] as int?,
      minLength: json['minLength'] as int?,
      maxLength: json['maxLength'] as int?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      required: json['required'] as bool?,
      type: parseType(json['type'] as String?),
    );
  }
}

const FLUTTER_FORM = 'FLUTTER-FORM';

// Define form element class
class FlutterForm extends FlutterFormBindings {
  FlutterForm(super.context);

  // Form key
  final _formKey = GlobalKey<FormBuilderState>();

  // Form layout type
  FlutterFormLayout _layout = FlutterFormLayout.vertical;

  bool _autovalidate = false;
  bool _validateOnSubmit = false;
  bool _submittedOnce = false;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    // Backward-compatible alias.
    attributes['validateOnSubmit'] = ElementAttributeProperty(
        getter: () => validateOnSubmit.toString(),
        setter: (value) => validateOnSubmit = value == 'true' || value == '',
        deleter: () => validateOnSubmit = false);

    // Override to avoid throwing on invalid values and to keep a stable default.
    attributes['layout'] = ElementAttributeProperty(
        getter: () => layout?.value,
        setter: (value) {
          FlutterFormLayout? parsed;
          try {
            parsed = FlutterFormLayout.parse(value);
          } catch (_) {
            parsed = null;
          }
          layout = parsed ?? FlutterFormLayout.vertical;
        },
        deleter: () => layout = FlutterFormLayout.vertical);
  }

  bool _coerceBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return false;
    final str = value.toString();
    return str == 'true' || str.isEmpty;
  }

  @override
  bool get autovalidate => _autovalidate;

  @override
  set autovalidate(value) {
    final next = _coerceBool(value);
    if (_autovalidate == next) return;
    _autovalidate = next;
    state?.requestUpdateState();
  }

  @override
  bool get validateOnSubmit => _validateOnSubmit;

  @override
  set validateOnSubmit(value) {
    final next = _coerceBool(value);
    if (_validateOnSubmit == next) return;
    _validateOnSubmit = next;
    state?.requestUpdateState();
  }

  @override
  FlutterFormLayout? get layout => _layout;

  @override
  set layout(value) {
    final next = value ?? FlutterFormLayout.vertical;
    if (_layout == next) return;
    _layout = next;
    state?.requestUpdateState();
  }

  bool get submittedOnce => _submittedOnce;

  // Define static method mapping for frontend calls
  static StaticDefinedSyncBindingObjectMethodMap formSyncMethods = {
    'validateAndSubmit': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterForm>(element);
        formElement.validateAndSubmit();
        return null;
      },
    ),
    'resetForm': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterForm>(element);
        formElement.resetForm();
        return null;
      },
    ),
    'getFormValues': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterForm>(element);
        return formElement.getFormValues();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        formSyncMethods,
      ];

  // Get the current state of the form
  FormBuilderState? get formState => _formKey.currentState;

  // Validate and submit the form
  void validateAndSubmit() {
    if (state == null) return;

    if (_validateOnSubmit) {
      _submittedOnce = true;
      state?.requestUpdateState();

      if (_formKey.currentState?.saveAndValidate() ?? false) {
        dispatchEvent(dom.Event('submit'));
      } else {
        dispatchEvent(dom.Event('validation-error'));
      }
      return;
    }

    _formKey.currentState?.save();
    dispatchEvent(dom.Event('submit'));
  }

  // Reset the form
  void resetForm() {
    if (state == null) return;

    _formKey.currentState?.reset();
    state?.requestUpdateState(() {
      _submittedOnce = false;
    });
    dispatchEvent(dom.Event('reset'));
  }

  // Get form values
  Map<String, dynamic> getFormValues() {
    return _formKey.currentState?.value ?? {};
  }

  @override
  FlutterFormState? get state => super.state as FlutterFormState?;

  @override
  WebFWidgetElementState createState() => FlutterFormState(this);
}

class FlutterFormState extends WebFWidgetElementState {
  FlutterFormState(super.widgetElement);

  @override
  FlutterForm get widgetElement => super.widgetElement as FlutterForm;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widgetElement._formKey,
      autovalidateMode: (widgetElement.autovalidate ||
              (widgetElement.validateOnSubmit && widgetElement.submittedOnce))
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          child: _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    switch (widgetElement.layout) {
      case FlutterFormLayout.horizontal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        );
      case FlutterFormLayout.vertical:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        );
    }
  }

  List<Widget> _buildChildren() {
    return widgetElement.childNodes.map<Widget>((node) {
      // Pass the current form layout type to child elements
      if (node is FlutterFormField) {
        node.formLayout = widgetElement.layout ?? FlutterFormLayout.vertical;
      }
      return node.toWidget();
    }).toList();
  }
}

const FLUTTER_FORM_FIELD = 'FLUTTER-FORM-FIELD';

// Form field wrapper for unified validation handling
class FlutterFormField extends WidgetElement {
  FlutterFormField(super.context);

  String _name = '';
  bool _isRequired = false;
  String _label = '';
  FlutterFormLayout _formLayout =
      FlutterFormLayout.vertical; // Default to vertical layout
  String _type = 'text'; // Input type
  String _placeholder = '';

  // Validation rules list
  List<ValidationRule> _rules = [];

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);

    attributes['name'] = ElementAttributeProperty(
        getter: () => _name,
        setter: (value) {
          _name = value;
          state?.requestUpdateState();
        });

    attributes['required'] = ElementAttributeProperty(
      getter: () => _isRequired.toString(),
      setter: (value) {
        _isRequired = value == 'true' || value.isEmpty;
        state?.requestUpdateState();
      },
      deleter: () {
        _isRequired = false;
        state?.requestUpdateState();
      },
    );

    attributes['label'] = ElementAttributeProperty(
        getter: () => _label,
        setter: (value) {
          _label = value;
          state?.requestUpdateState();
        });

    attributes['type'] = ElementAttributeProperty(
        getter: () => _type,
        setter: (value) {
          _type = value;
          state?.requestUpdateState();
        });

    attributes['placeholder'] = ElementAttributeProperty(
      getter: () => _placeholder,
      setter: (value) {
        _placeholder = value;
        state?.requestUpdateState();
      },
    );
  }

  // Set rules method
  void setRules(List<Map<String, dynamic>> rulesData) {
    try {
      _rules = rulesData.map((rule) => ValidationRule.fromJson(rule)).toList();

      state?.requestUpdateState();
    } catch (e) {
      debugPrint('Failed to set rules: $e');
    }
  }

  // Define static method mapping for frontend calls
  static StaticDefinedSyncBindingObjectMethodMap formFieldSyncMethods = {
    'setRules': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formField = castToType<FlutterFormField>(element);
        if (args.isEmpty) return null;
        final input = args[0];

        List<dynamic>? list;
        if (input is List) {
          list = input;
        } else if (input is String) {
          try {
            final decoded = jsonDecode(input);
            if (decoded is List) list = decoded;
          } catch (_) {
            list = null;
          }
        }

        if (list != null) {
          final rules = <Map<String, dynamic>>[];
          for (final item in list) {
            if (item is Map) {
              rules.add(Map<String, dynamic>.from(item));
            }
          }
          formField.setRules(rules);
        }
        return null;
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        formFieldSyncMethods,
      ];

  String get name => _name;
  bool get isRequired => _isRequired;
  String get label => _label;
  String get type => _type;
  String get placeholder => _placeholder;
  List<ValidationRule> get rules => _rules;

  // Set form layout
  set formLayout(FlutterFormLayout layout) {
    if (_formLayout != layout) {
      _formLayout = layout;
      state?.requestUpdateState();
    }
  }

  FlutterFormLayout get formLayout => _formLayout;

  @override
  FlutterFormFieldState? get state => super.state as FlutterFormFieldState?;

  @override
  WebFWidgetElementState createState() => FlutterFormFieldState(this);
}

class FlutterFormFieldState extends WebFWidgetElementState {
  FlutterFormFieldState(super.widgetElement);

  @override
  FlutterFormField get widgetElement => super.widgetElement as FlutterFormField;

  @override
  Widget build(BuildContext context) {
    // Handle input type
    final inputType = widgetElement.type;
    final placeholder = _getPlaceholderFromChild() ?? widgetElement.placeholder;

    // Build different field layouts based on form layout type
    switch (widgetElement.formLayout) {
      case FlutterFormLayout.horizontal:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widgetElement.label.isNotEmpty)
                SizedBox(
                  width: 120, // Fixed label width
                  child: Text(
                    widgetElement.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Expanded(
                child: _buildFormField(context, inputType, placeholder),
              ),
            ],
          ),
        );

      case FlutterFormLayout.vertical:
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widgetElement.label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    widgetElement.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              _buildFormField(context, inputType, placeholder),
            ],
          ),
        );
    }
  }

  String? _getPlaceholderFromChild() {
    if (widgetElement.childNodes.isEmpty) return null;
    final node = widgetElement.childNodes.first;
    if (node is dom.Element) {
      return node.getAttribute('placeholder');
    }
    return null;
  }

  Widget _buildFormField(
      BuildContext context, String type, String placeholder) {
    // Build validator list based on rules
    List<FormFieldValidator<String>> validators = [];

    // First handle required, highest priority
    bool isRequired = widgetElement.isRequired;
    final labelOrName = widgetElement.label.isNotEmpty
        ? widgetElement.label
        : widgetElement.name;
    final defaultRequiredMessage = '$labelOrName cannot be empty';

    // Check if there's a required rule from rules
    final requiredRule = widgetElement.rules.firstWhere(
      (rule) => rule.required == true,
      orElse: () => ValidationRule(),
    );

    if (requiredRule.required == true || isRequired) {
      validators.add(FormBuilderValidators.required(
        errorText: requiredRule.message ?? defaultRequiredMessage,
      ));
      isRequired = true;
    }

    // Handle different types of validation rules
    for (final rule in widgetElement.rules) {
      // Skip if already handled required
      if (rule.required == true) continue;

      // Handle enum validation
      if (rule.enumValues != null && rule.enumValues!.isNotEmpty) {
        validators.add((value) {
          if (value == null || value.isEmpty) {
            return isRequired ? (rule.message ?? defaultRequiredMessage) : null;
          }

          if (!rule.enumValues!.contains(value)) {
            return rule.message ?? 'Please select a valid option';
          }

          return null;
        });
      }

      // Handle length validation
      if (rule.len != null) {
        validators.add(FormBuilderValidators.equalLength(
          rule.len!,
          errorText: rule.message ?? 'Length must be ${rule.len} characters',
        ));
      }

      // Handle minimum length validation
      if (rule.minLength != null) {
        validators.add(FormBuilderValidators.minLength(
          rule.minLength!,
          errorText: rule.message ??
              'Length cannot be less than ${rule.minLength} characters',
        ));
      }

      // Handle maximum length validation
      if (rule.maxLength != null) {
        validators.add(FormBuilderValidators.maxLength(
          rule.maxLength!,
          errorText: rule.message ??
              'Length cannot exceed ${rule.maxLength} characters',
        ));
      }

      // Handle type validation
      if (rule.type != null) {
        switch (rule.type) {
          case ValidatorType.email:
            validators.add(FormBuilderValidators.email(
              errorText: rule.message ?? 'Please enter a valid email address',
            ));
            break;

          case ValidatorType.url:
            validators.add(FormBuilderValidators.url(
              errorText: rule.message ?? 'Please enter a valid URL',
            ));
            break;

          case ValidatorType.number:
            validators.add(FormBuilderValidators.numeric(
              errorText: rule.message ?? 'Please enter a valid number',
            ));

            // Handle minimum value validation
            if (rule.min != null) {
              validators.add(FormBuilderValidators.min(
                rule.min!.toDouble(),
                errorText:
                    rule.message ?? 'Value cannot be less than ${rule.min}',
              ));
            }

            // Handle maximum value validation
            if (rule.max != null) {
              validators.add(FormBuilderValidators.max(
                rule.max!.toDouble(),
                errorText:
                    rule.message ?? 'Value cannot be greater than ${rule.max}',
              ));
            }
            break;

          default:
            break;
        }
      } else {
        // If no type specified but has min/max, assume number type
        if (rule.min != null || rule.max != null) {
          // Add number validation
          validators.add(FormBuilderValidators.numeric(
            errorText: rule.message ?? 'Please enter a valid number',
          ));

          if (rule.min != null) {
            validators.add(FormBuilderValidators.min(
              rule.min!.toDouble(),
              errorText:
                  rule.message ?? 'Value cannot be less than ${rule.min}',
            ));
          }

          if (rule.max != null) {
            validators.add(FormBuilderValidators.max(
              rule.max!.toDouble(),
              errorText:
                  rule.message ?? 'Value cannot be greater than ${rule.max}',
            ));
          }
        }
      }
    }

    final validator =
        validators.isEmpty ? null : FormBuilderValidators.compose(validators);

    // Build different form controls based on field type
    switch (type) {
      case 'email':
        return FormBuilderTextField(
          name: widgetElement.name,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: validator,
        );

      case 'password':
        return FormBuilderTextField(
          name: widgetElement.name,
          obscureText: true,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        );

      case 'number':
        return FormBuilderTextField(
          name: widgetElement.name,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: validator,
        );

      case 'url':
        return FormBuilderTextField(
          name: widgetElement.name,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          keyboardType: TextInputType.url,
          validator: validator,
        );

      default: // text
        return FormBuilderTextField(
          name: widgetElement.name,
          decoration: InputDecoration(
            hintText: placeholder,
            border: const OutlineInputBorder(),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        );
    }
  }
}
