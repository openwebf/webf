/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-textarea>
 *
 * A multi-line text input field.
 *
 * @example
 * ```html
 * <flutter-shadcn-textarea
 *   placeholder="Enter your message..."
 *   rows="4"
 * />
 * ```
 */
interface FlutterShadcnTextareaProperties {
  /**
   * Current value of the textarea.
   */
  value?: string;

  /**
   * Placeholder text shown when empty.
   */
  placeholder?: string;

  /**
   * Number of visible text rows.
   * Default: 3
   */
  rows?: string;

  /**
   * Disable the textarea.
   */
  disabled?: boolean;

  /**
   * Make the textarea read-only.
   */
  readonly?: boolean;

  /**
   * Maximum length of the input value.
   */
  maxlength?: string;

  /**
   * Whether the textarea is required.
   */
  required?: boolean;

  /**
   * Autofocus on mount.
   */
  autofocus?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-textarea>
 */
interface FlutterShadcnTextareaEvents {
  /** Fired on every input change. */
  input: Event;

  /** Fired when textarea loses focus. */
  change: Event;

  /** Fired when textarea gains focus. */
  focus: Event;

  /** Fired when textarea loses focus. */
  blur: Event;
}
