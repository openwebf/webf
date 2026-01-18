/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-form>
 *
 * A form container that manages form state and validation.
 *
 * @example
 * ```html
 * <flutter-shadcn-form onsubmit="handleSubmit(event)">
 *   <flutter-shadcn-form-field name="email" label="Email">
 *     <flutter-shadcn-input type="email" placeholder="Enter email" />
 *   </flutter-shadcn-form-field>
 *   <flutter-shadcn-button type="submit">Submit</flutter-shadcn-button>
 * </flutter-shadcn-form>
 * ```
 */
interface FlutterShadcnFormProperties {
  /**
   * Disable all form fields.
   */
  disabled?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-form>
 */
interface FlutterShadcnFormEvents {
  /** Fired when form is submitted. */
  submit: Event;

  /** Fired when form is reset. */
  reset: Event;
}

/**
 * Properties for <flutter-shadcn-form-field>
 *
 * A form field wrapper with label and validation.
 */
interface FlutterShadcnFormFieldProperties {
  /**
   * Field name/identifier.
   */
  name?: string;

  /**
   * Label text for the field.
   */
  label?: string;

  /**
   * Description text shown below the label.
   */
  description?: string;

  /**
   * Error message to display.
   */
  error?: string;

  /**
   * Whether this field is required.
   */
  required?: boolean;
}

interface FlutterShadcnFormFieldEvents {}

/**
 * Properties for <flutter-shadcn-form-label>
 *
 * Label element for form fields.
 */
interface FlutterShadcnFormLabelProperties {}

interface FlutterShadcnFormLabelEvents {}

/**
 * Properties for <flutter-shadcn-form-description>
 *
 * Description text for form fields.
 */
interface FlutterShadcnFormDescriptionProperties {}

interface FlutterShadcnFormDescriptionEvents {}

/**
 * Properties for <flutter-shadcn-form-message>
 *
 * Validation message for form fields.
 */
interface FlutterShadcnFormMessageProperties {
  /**
   * Type of message.
   * Options: 'error', 'success', 'info'
   * Default: 'error'
   */
  type?: string;
}

interface FlutterShadcnFormMessageEvents {}
