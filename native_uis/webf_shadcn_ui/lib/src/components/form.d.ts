/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-form>
 *
 * A form container that manages form state and validation using shadcn_ui's ShadForm.
 *
 * @example
 * ```html
 * <flutter-shadcn-form id="myForm">
 *   <flutter-shadcn-form-field field-id="username" label="Username" required placeholder="Enter username" />
 *   <flutter-shadcn-form-field field-id="email" label="Email" placeholder="Enter email" />
 *   <flutter-shadcn-button onClick="document.getElementById('myForm').submit()">Submit</flutter-shadcn-button>
 * </flutter-shadcn-form>
 * ```
 *
 * @example
 * ```javascript
 * const form = document.getElementById('myForm');
 *
 * // Submit form and get values
 * if (form.submit()) {
 *   const values = JSON.parse(form.value);
 *   console.log('Form values:', values);
 * }
 *
 * // Set form values
 * form.value = JSON.stringify({ username: 'john', email: 'john@example.com' });
 *
 * // Get/set individual field values
 * form.setFieldValue('username', 'jane');
 * console.log(form.getFieldValue('username'));
 *
 * // Set field errors
 * form.setFieldError('email', 'Invalid email format');
 *
 * // Reset form
 * form.reset();
 * ```
 */
interface FlutterShadcnFormProperties {
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
}

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

/**
 * Events emitted by <flutter-shadcn-form>
 */
interface FlutterShadcnFormEvents {
  /**
   * Fired when form is successfully submitted (after validation passes).
   * The event detail contains the form values.
   */
  submit: CustomEvent<string>;

  /**
   * Fired when form is reset.
   */
  reset: Event;

  /**
   * Fired when any form field value changes.
   */
  change: Event;
}

/**
 * Properties for <flutter-shadcn-form-field>
 *
 * A form field that automatically integrates with the parent form.
 * When used without children, renders a ShadInputFormField.
 * When used with children, wraps them with label, description, and error display.
 *
 * @example
 * ```html
 * <!-- Simple input field -->
 * <flutter-shadcn-form-field
 *   field-id="email"
 *   label="Email"
 *   description="We'll never share your email."
 *   placeholder="Enter your email"
 *   required
 * />
 *
 * <!-- Custom field with children -->
 * <flutter-shadcn-form-field field-id="bio" label="Bio" description="Tell us about yourself">
 *   <flutter-shadcn-textarea placeholder="Your bio..." />
 * </flutter-shadcn-form-field>
 * ```
 */
interface FlutterShadcnFormFieldProperties {
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
}

interface FlutterShadcnFormFieldEvents {
  /**
   * Fired when the field value changes.
   * The event detail contains the new value.
   */
  change: CustomEvent<string>;
}

/**
 * Properties for <flutter-shadcn-form-label>
 *
 * Label element for form fields.
 * Typically used inside a custom form field layout.
 *
 * @example
 * ```html
 * <flutter-shadcn-form-label>Username</flutter-shadcn-form-label>
 * ```
 */
interface FlutterShadcnFormLabelProperties {}

interface FlutterShadcnFormLabelEvents {}

/**
 * Properties for <flutter-shadcn-form-description>
 *
 * Description text for form fields.
 * Provides additional context or instructions.
 *
 * @example
 * ```html
 * <flutter-shadcn-form-description>
 *   This is your public display name.
 * </flutter-shadcn-form-description>
 * ```
 */
interface FlutterShadcnFormDescriptionProperties {}

interface FlutterShadcnFormDescriptionEvents {}

/**
 * Properties for <flutter-shadcn-form-message>
 *
 * Validation or status message for form fields.
 *
 * @example
 * ```html
 * <flutter-shadcn-form-message type="error">
 *   This field is required
 * </flutter-shadcn-form-message>
 *
 * <flutter-shadcn-form-message type="success">
 *   Email is available
 * </flutter-shadcn-form-message>
 * ```
 */
interface FlutterShadcnFormMessageProperties {
  /**
   * Type of message which determines the styling.
   *
   * Options:
   * - 'error': Red text for validation errors (default)
   * - 'success': Green text for success messages
   * - 'info': Primary color for informational messages
   */
  type?: 'error' | 'success' | 'info';
}

interface FlutterShadcnFormMessageEvents {}
