import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
/**
 * Methods available on <flutter-shadcn-form>
 */
interface FlutterShadcnFormMethods {
  /**
   * Validate the form without saving.
   * 
   * @returns true if the form is valid, false otherwise
   */
  validate(): boolean;
  /**
   * Save and validate the form. Dispatches 'submit' event if valid.
   * 
   * @returns true if the form is valid and submitted, false otherwise
   */
  submit(): boolean;
  /**
   * Reset the form to its initial values. Dispatches 'reset' event.
   */
  reset(): void;
  /**
   * Get the value of a specific form field.
   * 
   * @param fieldId - The id of the field
   * @returns The field's current value
   */
  getFieldValue(fieldId: string): any;
  /**
   * Set the value of a specific form field.
   * 
   * @param fieldId - The id of the field
   * @param value - The value to set
   */
  setFieldValue(fieldId: string, value: any): void;
  /**
   * Set an error message for a specific form field.
   * 
   * @param fieldId - The id of the field
   * @param error - The error message, or null to clear the error
   */
  setFieldError(fieldId: string, error: string | null): void;
}
export interface FlutterShadcnFormProps {
  /**
   * Disable all form fields.
   */
  disabled?: boolean;
  /**
   * Auto-validation mode for the form.
   * 
   * Options:
   * - 'disabled': No auto validation
   * - 'always': Always validate
   * - 'onUserInteraction': Validate after user interaction
   * - 'alwaysAfterFirstValidation': Validate always after first validation (default)
   */
  autoValidateMode?: 'disabled' | 'always' | 'onUserInteraction' | 'alwaysAfterFirstValidation';
  /**
   * Current form values as a JSON string.
   * 
   * Get: Returns all form field values as a JSON string.
   * Set: Accepts a JSON string or object to set form values.
   */
  value?: string;
  /**
   * Fired when form is successfully submitted (after validation passes).
   * The event detail contains the form values.
   */
  onSubmit?: (event: CustomEvent<string>) => void;
  /**
   * Fired when form is reset.
   */
  onReset?: (event: Event) => void;
  /**
   * Fired when any form field value changes.
   */
  onChange?: (event: Event) => void;
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
 * Element interface with methods/properties accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<FlutterShadcnFormElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * // Access properties
 * console.log(ref.current?.disabled);
 * ```
 */
export interface FlutterShadcnFormElement extends WebFElementWithMethods<{
  /**
   * Validate the form without saving.
   * 
   * @returns true if the form is valid, false otherwise
   */
  validate(): boolean;
  /**
   * Save and validate the form. Dispatches 'submit' event if valid.
   * 
   * @returns true if the form is valid and submitted, false otherwise
   */
  submit(): boolean;
  /**
   * Reset the form to its initial values. Dispatches 'reset' event.
   */
  reset(): void;
  /**
   * Get the value of a specific form field.
   * 
   * @param fieldId - The id of the field
   * @returns The field's current value
   */
  getFieldValue(fieldId: string): any;
  /**
   * Set the value of a specific form field.
   * 
   * @param fieldId - The id of the field
   * @param value - The value to set
   */
  setFieldValue(fieldId: string, value: any): void;
  /**
   * Set an error message for a specific form field.
   * 
   * @param fieldId - The id of the field
   * @param error - The error message, or null to clear the error
   */
  setFieldError(fieldId: string, error: string | null): void;
}> {
  /** Disable all form fields. */
  disabled?: boolean;
  /** Auto-validation mode for the form. */
  autoValidateMode?: 'disabled' | 'always' | 'onUserInteraction' | 'alwaysAfterFirstValidation';
  /** Current form values as a JSON string. */
  value?: string;
}
/**
 * Properties for <flutter-shadcn-form>
A form container that manages form state and validation using shadcn_ui's ShadForm.
@example
```html
<flutter-shadcn-form id="myForm">
  <flutter-shadcn-form-field field-id="username" label="Username" required placeholder="Enter username" />
  <flutter-shadcn-form-field field-id="email" label="Email" placeholder="Enter email" />
  <flutter-shadcn-button onClick="document.getElementById('myForm').submit()">Submit</flutter-shadcn-button>
</flutter-shadcn-form>
```
@example
```javascript
const form = document.getElementById('myForm');
// Submit form and get values
if (form.submit()) {
  const values = JSON.parse(form.value);
  console.log('Form values:', values);
}
// Set form values
form.value = JSON.stringify({ username: 'john', email: 'john@example.com' });
// Get/set individual field values
form.setFieldValue('username', 'jane');
console.log(form.getFieldValue('username'));
// Set field errors
form.setFieldError('email', 'Invalid email format');
// Reset form
form.reset();
```
 * 
 * @example
 * ```tsx
 * const ref = useRef<FlutterShadcnFormElement>(null);
 * 
 * <FlutterShadcnForm
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnForm>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const FlutterShadcnForm = createWebFComponent<FlutterShadcnFormElement, FlutterShadcnFormProps>({
  tagName: 'flutter-shadcn-form',
  displayName: 'FlutterShadcnForm',
  // Map props to attributes
  attributeProps: [
    'disabled',
    'autoValidateMode',
    'value',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    autoValidateMode: 'auto-validate-mode',
  },
  // Event handlers
  events: [
    {
      propName: 'onSubmit',
      eventName: 'submit',
      handler: (callback: (event: CustomEvent<string>) => void) => (event: Event) => {
        callback(event as CustomEvent<string>);
      },
    },
    {
      propName: 'onReset',
      eventName: 'reset',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnFormFieldProps {
  /**
   * Unique identifier for the field within the form.
   * Used to access field values via form.getFieldValue(fieldId).
   */
  fieldId?: string;
  /**
   * Label text displayed above the field.
   */
  label?: string;
  /**
   * Description text shown below the field.
   */
  description?: string;
  /**
   * Error message to display. Overrides validation errors.
   */
  error?: string;
  /**
   * Whether this field is required.
   * Adds a "*" indicator and validates that the field is not empty.
   */
  required?: boolean;
  /**
   * Input type (used when no children are provided).
   * Default: 'text'
   */
  type?: string;
  /**
   * Placeholder text for the input field.
   */
  placeholder?: string;
  /**
   * Initial value for the field.
   */
  initialValue?: string;
  /**
   * Fired when the field value changes.
   * The event detail contains the new value.
   */
  onChange?: (event: CustomEvent<string>) => void;
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
export interface FlutterShadcnFormFieldElement extends WebFElementWithMethods<{
}> {
  /** Unique identifier for the field within the form. */
  fieldId?: string;
  /** Label text displayed above the field. */
  label?: string;
  /** Description text shown below the field. */
  description?: string;
  /** Error message to display. Overrides validation errors. */
  error?: string;
  /** Whether this field is required. */
  required?: boolean;
  /** Input type (used when no children are provided). */
  type?: string;
  /** Placeholder text for the input field. */
  placeholder?: string;
  /** Initial value for the field. */
  initialValue?: string;
}
/**
 * Properties for <flutter-shadcn-form-field>
A form field that automatically integrates with the parent form.
When used without children, renders a ShadInputFormField.
When used with children, wraps them with label, description, and error display.
@example
```html
<!-- Simple input field -->
<flutter-shadcn-form-field
  field-id="email"
  label="Email"
  description="We'll never share your email."
  placeholder="Enter your email"
  required
/>
<!-- Custom field with children -->
<flutter-shadcn-form-field field-id="bio" label="Bio" description="Tell us about yourself">
  <flutter-shadcn-textarea placeholder="Your bio..." />
</flutter-shadcn-form-field>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnFormField
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnFormField>
 * ```
 */
export const FlutterShadcnFormField = createWebFComponent<FlutterShadcnFormFieldElement, FlutterShadcnFormFieldProps>({
  tagName: 'flutter-shadcn-form-field',
  displayName: 'FlutterShadcnFormField',
  // Map props to attributes
  attributeProps: [
    'fieldId',
    'label',
    'description',
    'error',
    'required',
    'type',
    'placeholder',
    'initialValue',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    fieldId: 'field-id',
    initialValue: 'initial-value',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<string>) => void) => (event: Event) => {
        callback(event as CustomEvent<string>);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterShadcnFormLabelProps {
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
export interface FlutterShadcnFormLabelElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-form-label>
Label element for form fields.
Typically used inside a custom form field layout.
@example
```html
<flutter-shadcn-form-label>Username</flutter-shadcn-form-label>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnFormLabel
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnFormLabel>
 * ```
 */
export const FlutterShadcnFormLabel = createWebFComponent<FlutterShadcnFormLabelElement, FlutterShadcnFormLabelProps>({
  tagName: 'flutter-shadcn-form-label',
  displayName: 'FlutterShadcnFormLabel',
  // Map props to attributes
  attributeProps: [
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
export interface FlutterShadcnFormDescriptionProps {
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
export interface FlutterShadcnFormDescriptionElement extends WebFElementWithMethods<{
}> {
}
/**
 * Properties for <flutter-shadcn-form-description>
Description text for form fields.
Provides additional context or instructions.
@example
```html
<flutter-shadcn-form-description>
  This is your public display name.
</flutter-shadcn-form-description>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnFormDescription
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnFormDescription>
 * ```
 */
export const FlutterShadcnFormDescription = createWebFComponent<FlutterShadcnFormDescriptionElement, FlutterShadcnFormDescriptionProps>({
  tagName: 'flutter-shadcn-form-description',
  displayName: 'FlutterShadcnFormDescription',
  // Map props to attributes
  attributeProps: [
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
export interface FlutterShadcnFormMessageProps {
  /**
   * Type of message which determines the styling.
   * 
   * Options:
   * - 'error': Red text for validation errors (default)
   * - 'success': Green text for success messages
   * - 'info': Primary color for informational messages
   */
  type?: 'error' | 'success' | 'info';
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
export interface FlutterShadcnFormMessageElement extends WebFElementWithMethods<{
}> {
  /** Type of message which determines the styling. */
  type?: 'error' | 'success' | 'info';
}
/**
 * Properties for <flutter-shadcn-form-message>
Validation or status message for form fields.
@example
```html
<flutter-shadcn-form-message type="error">
  This field is required
</flutter-shadcn-form-message>
<flutter-shadcn-form-message type="success">
  Email is available
</flutter-shadcn-form-message>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnFormMessage
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnFormMessage>
 * ```
 */
export const FlutterShadcnFormMessage = createWebFComponent<FlutterShadcnFormMessageElement, FlutterShadcnFormMessageProps>({
  tagName: 'flutter-shadcn-form-message',
  displayName: 'FlutterShadcnFormMessage',
  // Map props to attributes
  attributeProps: [
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