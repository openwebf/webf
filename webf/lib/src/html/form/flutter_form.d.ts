/**
 * A custom Flutter form element that provides form validation and submission functionality
 * 
 * This element wraps Flutter FormBuilder to provide a native form experience in WebF.
 * It supports automatic validation, custom layouts, and form submission handling.
 * 
 * The element supports these JavaScript events:
 * - 'submit': Triggered when form validation passes and form is submitted
 * - 'validation-error': Triggered when form validation fails
 * - 'reset': Triggered when form is reset
 */
interface FlutterFormProperties {
  /**
   * Whether to automatically validate form fields on change
   * @default false
   */
  autovalidate?: boolean;

  /**
   * Whether to validate form on submit
   * @default false
   */
  'validate-on-submit'?: boolean;

  /**
   * Form layout type
   * @default 'vertical'
   */
  layout?: 'vertical' | 'horizontal';
}

interface FlutterFormMethods {
  /**
   * Validates all form fields and submits the form if validation passes
   * 
   * This method triggers validation for all form fields. If validation passes,
   * a 'submit' event is dispatched. If validation fails, a 'validation-error'
   * event is dispatched instead.
   */
  validateAndSubmit(): void;

  /**
   * Resets all form fields to their initial values
   * 
   * This method clears all form field values and resets validation states.
   * A 'reset' event is dispatched after the form is reset.
   */
  resetForm(): void;

  /**
   * Gets the current values of all form fields
   * 
   * @returns An object containing the current form field values, where keys
   * are field names and values are the current field values
   */
  getFormValues(): any;
}

interface FlutterFormEvents {
  /**
   * Fired when form validation passes and form is submitted
   */
  submit: Event;

  /**
   * Fired when form validation fails during submission
   */
  'validation-error': Event;

  /**
   * Fired when form is reset
   */
  reset: Event;
}


/**
 * A form field element that provides validation and different input types
 * 
 * This element works as a child of flutter-webf-form and provides individual
 * form field functionality with validation rules and various input types.
 */
interface FlutterFormFieldProperties {
  /**
   * The name of the form field (used as the key in form values)
   */
  name: string;

  /**
   * Whether this field is required
   * @default false
   */
  required?: boolean;

  /**
   * Label text for the form field
   */
  label?: string;

  /**
   * Input type for the form field
   * @default 'text'
   */
  type?: 'text' | 'email' | 'password' | 'number' | 'url';
}

interface FlutterFormFieldMethods {
  /**
   * Sets validation rules for this form field
   * 
   * @param rules JSON string containing validation rules to apply to this field
   */
  setRules(rules: string): void;
}

interface FlutterFormFieldEvents {
  // Form field events are handled by the parent form
  // Individual fields don't emit their own events
}