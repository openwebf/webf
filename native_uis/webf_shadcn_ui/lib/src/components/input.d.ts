/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-input>
 *
 * A styled text input field.
 *
 * @example
 * ```html
 * <flutter-shadcn-input
 *   placeholder="Enter your email"
 *   type="email"
 *   oninput="handleInput(event)"
 * />
 * ```
 */
interface FlutterShadcnInputProperties {
  /**
   * Current value of the input.
   */
  value?: string;

  /**
   * Placeholder text shown when empty.
   */
  placeholder?: string;

  /**
   * Input type.
   * Options: 'text', 'password', 'email', 'number', 'tel', 'url', 'search'
   * Default: 'text'
   */
  type?: string;

  /**
   * Disable the input.
   */
  disabled?: boolean;

  /**
   * Make the input read-only.
   */
  readonly?: boolean;

  /**
   * Maximum length of the input value.
   */
  maxlength?: string;

  /**
   * Minimum length of the input value.
   */
  minlength?: string;

  /**
   * Pattern for validation (regex).
   */
  pattern?: string;

  /**
   * Whether the input is required.
   */
  required?: boolean;

  /**
   * Autofocus on mount.
   */
  autofocus?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-input>
 */
interface FlutterShadcnInputEvents {
  /** Fired on every input change. */
  input: Event;

  /** Fired when input loses focus. */
  change: Event;

  /** Fired when input gains focus. */
  focus: Event;

  /** Fired when input loses focus. */
  blur: Event;
}
