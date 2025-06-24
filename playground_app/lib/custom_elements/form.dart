import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/webf.dart';

// Define form layout enum
enum FormLayout {
  vertical,    // Vertical layout, label on top, input below
  horizontal,  // Horizontal layout, label on left, input on right
}

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
  final String? message;       // Error message
  final List<String>? enumValues; // Enum values
  final int? len;              // Fixed length
  final int? minLength;        // Minimum length
  final int? maxLength;        // Maximum length
  final num? min;              // Minimum value
  final num? max;              // Maximum value
  final bool? required;        // Whether required
  final ValidatorType? type;   // Data type

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
        case 'string': return ValidatorType.string;
        case 'number': return ValidatorType.number;
        case 'boolean': return ValidatorType.boolean;
        case 'url': return ValidatorType.url;
        case 'email': return ValidatorType.email;
        default: return null;
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

// Define form element class
class FlutterWebFForm extends WidgetElement {
  FlutterWebFForm(super.context);

  // Form key
  final _formKey = GlobalKey<FormBuilderState>();

  // Whether to show validation errors
  // bool _showValidationErrors = false;
  
  // Form layout type
  FormLayout _layout = FormLayout.vertical;

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    attributes['autovalidate'] = ElementAttributeProperty(
      getter: () => _autovalidate.toString(),
      setter: (value) {
        _autovalidate = value != 'false';
      }
    );
    
    attributes['validateOnSubmit'] = ElementAttributeProperty(
      getter: () => _validateOnSubmit.toString(),
      setter: (value) {
        _validateOnSubmit = value != 'false';
      }
    );
    
    attributes['layout'] = ElementAttributeProperty(
      getter: () => _layout.toString().split('.').last,
      setter: (value) {
        switch (value.toLowerCase()) {
          case 'horizontal':
            _layout = FormLayout.horizontal;
            break;
          default:
            _layout = FormLayout.vertical;
            break;
        }
        
        state?.requestUpdateState();
      }
    );
  }

  bool _autovalidate = false;
  bool _validateOnSubmit = false;

  bool get autovalidate => _autovalidate;
  bool get validateOnSubmit => _validateOnSubmit;
  FormLayout get layout => _layout;

  // Define static method mapping for frontend calls
  static StaticDefinedSyncBindingObjectMethodMap formSyncMethods = {
    'validateAndSubmit': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterWebFForm>(element);
        formElement.validateAndSubmit();
        return null;
      },
    ),
    'resetForm': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterWebFForm>(element);
        formElement.resetForm();
        return null;
      },
    ),
    'getFormValues': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formElement = castToType<FlutterWebFForm>(element);
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
    
    state?.requestUpdateState(() {
      // _showValidationErrors = true;
    });
    
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Map<String, dynamic> formValues = getFormValues();
      // Record form values, then retrieve in frontend JS code
      dispatchEvent(dom.Event('submit'));
    } else {
      dispatchEvent(dom.Event('validation-error'));
    }
  }

  // Reset the form
  void resetForm() {
    if (state == null) return;
    
    _formKey.currentState?.reset();
    state?.requestUpdateState(() {
      // _showValidationErrors = false;
    });
    dispatchEvent(dom.Event('reset'));
  }

  // Get form values
  Map<String, dynamic> getFormValues() {
    return _formKey.currentState?.value ?? {};
  }

  @override
  FlutterWebFFormState? get state => super.state as FlutterWebFFormState?;

  @override
  WebFWidgetElementState createState() => FlutterWebFFormState(this);
}

class FlutterWebFFormState extends WebFWidgetElementState {
  FlutterWebFFormState(super.widgetElement);

  @override
  FlutterWebFForm get widgetElement => super.widgetElement as FlutterWebFForm;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: widgetElement._formKey,
      autovalidateMode: widgetElement.autovalidate 
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
      case FormLayout.horizontal:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: _buildChildren(),
        );
      case FormLayout.vertical:
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
      if (node is FlutterWebFFormField) {
        node.formLayout = widgetElement.layout;
      }
      return node.toWidget();
    }).toList();
  }
}

// Form field wrapper for unified validation handling
class FlutterWebFFormField extends WidgetElement {
  FlutterWebFFormField(super.context);

  String _name = '';
  bool _isRequired = false;
  String _label = '';
  FormLayout _formLayout = FormLayout.vertical; // Default to vertical layout
  String _type = 'text'; // Input type
  
  // Validation rules list
  List<ValidationRule> _rules = [];

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    
    attributes['name'] = ElementAttributeProperty(
      getter: () => _name,
      setter: (value) {
        _name = value;
      }
    );
    
    attributes['required'] = ElementAttributeProperty(
      getter: () => _isRequired.toString(),
      setter: (value) {
        _isRequired = value == 'true';
      }
    );
    
    attributes['label'] = ElementAttributeProperty(
      getter: () => _label,
      setter: (value) {
        _label = value;
      }
    );
    
    attributes['type'] = ElementAttributeProperty(
      getter: () => _type,
      setter: (value) {
        _type = value;
      }
    );
  }

  // Set rules method
  void setRules(List<Map<String, dynamic>> rulesData) {
    try {
      _rules = rulesData
          .map((rule) => ValidationRule.fromJson(rule))
          .toList();
          
      state?.requestUpdateState();
    } catch (e) {
      print('Failed to set rules: $e');
    }
  }

  // Define static method mapping for frontend calls
  static StaticDefinedSyncBindingObjectMethodMap formFieldSyncMethods = {
    'setRules': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final formField = castToType<FlutterWebFFormField>(element);
        if (args.isNotEmpty && args[0] is List) {
          final List<dynamic> rulesData = args[0] as List<dynamic>;
          final List<Map<String, dynamic>> rules = rulesData
              .whereType<Map<String, dynamic>>()
              .toList();
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
  List<ValidationRule> get rules => _rules;
  
  // Set form layout
  set formLayout(FormLayout layout) {
    if (_formLayout != layout) {
      _formLayout = layout;
      state?.requestUpdateState();
    }
  }
  
  FormLayout get formLayout => _formLayout;

  @override
  FlutterWebFFormFieldState? get state => super.state as FlutterWebFFormFieldState?;

  @override
  WebFWidgetElementState createState() => FlutterWebFFormFieldState(this);
}

class FlutterWebFFormFieldState extends WebFWidgetElementState {
  FlutterWebFFormFieldState(super.widgetElement);

  @override
  FlutterWebFFormField get widgetElement => super.widgetElement as FlutterWebFFormField;

  dom.Node? _getFirstChildNode() {
    return widgetElement.childNodes.isNotEmpty ? widgetElement.childNodes.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final childNode = _getFirstChildNode();
    final childWidget = childNode?.toWidget();
    
    if (childWidget == null) return const SizedBox();
    
    // Handle input type
    final inputType = widgetElement.type;
    final placeholder = _getPlaceholder(childNode);
    
    // Build different field layouts based on form layout type
    switch (widgetElement.formLayout) {
      case FormLayout.horizontal:
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
        
      case FormLayout.vertical:
      default:
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
  
  String _getPlaceholder(dom.Node? node) {
    if (node is dom.Element) {
      return node.getAttribute('placeholder') ?? '';
    }
    return '';
  }
  
  Widget _buildFormField(BuildContext context, String type, String placeholder) {
    // Build validator list based on rules
    List<FormFieldValidator<String>> validators = [];
    
    // First handle required, highest priority
    bool isRequired = widgetElement.isRequired;
    String defaultRequiredMessage = '${widgetElement.label} cannot be empty';
    
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
          errorText: rule.message ?? 'Length cannot be less than ${rule.minLength} characters',
        ));
      }
      
      // Handle maximum length validation
      if (rule.maxLength != null) {
        validators.add(FormBuilderValidators.maxLength(
          rule.maxLength!,
          errorText: rule.message ?? 'Length cannot exceed ${rule.maxLength} characters',
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
                errorText: rule.message ?? 'Value cannot be less than ${rule.min}',
              ));
            }
            
            // Handle maximum value validation
            if (rule.max != null) {
              validators.add(FormBuilderValidators.max(
                rule.max!.toDouble(),
                errorText: rule.message ?? 'Value cannot be greater than ${rule.max}',
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
              errorText: rule.message ?? 'Value cannot be less than ${rule.min}',
            ));
          }
          
          if (rule.max != null) {
            validators.add(FormBuilderValidators.max(
              rule.max!.toDouble(),
              errorText: rule.message ?? 'Value cannot be greater than ${rule.max}',
            ));
          }
        }
      }
    }
    
    final validator = validators.isEmpty ? null : FormBuilderValidators.compose(validators);
    
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