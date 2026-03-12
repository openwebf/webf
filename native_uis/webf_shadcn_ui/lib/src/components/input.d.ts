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

  /**
   * Text alignment within the input.
   * Options: 'start', 'end', 'left', 'right', 'center'
   * Default: 'start'
   */
  textalign?: string;

  /**
   * Controls automatic text capitalization behavior.
   * Options: 'none', 'sentences', 'words', 'characters'
   * Default: 'none'
   */
  autocapitalize?: string;

  /**
   * Whether to enable autocorrect.
   * Default: true
   */
  autocorrect?: boolean;

  /**
   * Whether to show input suggestions.
   * Default: true
   */
  enablesuggestions?: boolean;

  /**
   * Hint for the keyboard action button.
   * Options: 'done', 'go', 'next', 'search', 'send', 'previous', 'newline'
   */
  enterkeyhint?: string;

  /**
   * Maximum number of lines for the input. Use for multi-line input.
   */
  maxlines?: string;

  /**
   * Minimum number of lines for the input.
   */
  minlines?: string;

  /**
   * Color of the cursor (e.g., '#FF0000', 'red').
   */
  cursorcolor?: string;

  /**
   * Color of the text selection highlight (e.g., '#0000FF', 'blue').
   */
  selectioncolor?: string;

  /**
   * Character used to obscure text in password mode.
   * Default: '•'
   */
  obscuringcharacter?: string;
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

  /** Fired when the user submits the input (e.g., presses Enter/Done). */
  submit: Event;
}
