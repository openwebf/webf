import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../../utils/createWebFComponent";
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
interface FlutterFormFieldMethods {
  /**
   * Sets validation rules for this form field
   * 
   * @param rules JSON string containing validation rules to apply to this field
   */
  setRules(rules: string): void;
}
export interface FlutterFormProps {
  /**
   * Whether to automatically validate form fields on change
   * @default false
   */
  autovalidate?: boolean;
  /**
   * Whether to validate form on submit
   * @default false
   */
  validateOnSubmit?: boolean;
  /**
   * Form layout type
   * @default 'vertical'
   */
  layout?: 'vertical' | 'horizontal';
  /**
   * Fired when form validation passes and form is submitted
   */
  onSubmit?: (event: Event) => void;
  /**
   * Fired when form validation fails during submission
   */
  onValidationError?: (event: Event) => void;
  /**
   * Fired when form is reset
   */
  onReset?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterFormElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterFormElement extends WebFElementWithMethods<{
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
}> {}
/**
 * A custom Flutter form element that provides form validation and submission functionality
This element wraps Flutter FormBuilder to provide a native form experience in WebF.
It supports automatic validation, custom layouts, and form submission handling.
The element supports these JavaScript events:
- 'submit': Triggered when form validation passes and form is submitted
- 'validation-error': Triggered when form validation fails
- 'reset': Triggered when form is reset
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterFormElement>(null);
 * 
 * <FlutterForm
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterForm>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterForm = createWebFComponent<FlutterFormElement, FlutterFormProps>({
  tagName: 'flutter-form',
  displayName: 'FlutterForm',
  // Map props to attributes
  attributeProps: [
    'autovalidate',
    'validateOnSubmit',
    'layout',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    validateOnSubmit: 'validate-on-submit',
  },
  // Event handlers
  events: [
    {
      propName: 'onSubmit',
      eventName: 'submit',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
    {
      propName: 'onValidationError',
      eventName: 'validation-error',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
    {
      propName: 'onReset',
      eventName: 'reset',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterFormFieldProps {
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
  /**
   * HTML id attribute
   */
  id?: string;
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  /**
   * Children elements
   */
  children?: React.ReactNode;
  /**
   * Additional CSS class names
   */
  className?: string;
}
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterFormFieldElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface FlutterFormFieldElement extends WebFElementWithMethods<{
  /**
   * Sets validation rules for this form field
   * 
   * @param rules JSON string containing validation rules to apply to this field
   */
  setRules(rules: string): void;
}> {}
/**
 * A form field element that provides validation and different input types
This element works as a child of flutter-webf-form and provides individual
form field functionality with validation rules and various input types.
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterFormFieldElement>(null);
 * 
 * <FlutterFormField
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterFormField>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterFormField = createWebFComponent<FlutterFormFieldElement, FlutterFormFieldProps>({
  tagName: 'flutter-form-field',
  displayName: 'FlutterFormField',
  // Map props to attributes
  attributeProps: [
    'name',
    'required',
    'label',
    'type',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});