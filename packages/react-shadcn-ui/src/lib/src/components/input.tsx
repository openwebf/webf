import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnInputProps {
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
  /**
   * Fired on every input change.
   */
  onInput?: (event: Event) => void;
  /**
   * Fired when input loses focus.
   */
  onChange?: (event: Event) => void;
  /**
   * Fired when input gains focus.
   */
  onFocus?: (event: Event) => void;
  /**
   * Fired when input loses focus.
   */
  onBlur?: (event: Event) => void;
  /**
   * Fired when the user submits the input (e.g., presses Enter/Done).
   */
  onSubmit?: (event: Event) => void;
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
export interface FlutterShadcnInputElement extends WebFElementWithMethods<{
}> {
  /** Current value of the input. */
  value?: string;
  /** Placeholder text shown when empty. */
  placeholder?: string;
  /** Input type. */
  type?: string;
  /** Disable the input. */
  disabled?: boolean;
  /** Make the input read-only. */
  readonly?: boolean;
  /** Maximum length of the input value. */
  maxlength?: string;
  /** Minimum length of the input value. */
  minlength?: string;
  /** Pattern for validation (regex). */
  pattern?: string;
  /** Whether the input is required. */
  required?: boolean;
  /** Autofocus on mount. */
  autofocus?: boolean;
  /** Text alignment within the input. */
  textalign?: string;
  /** Controls automatic text capitalization behavior. */
  autocapitalize?: string;
  /** Whether to enable autocorrect. */
  autocorrect?: boolean;
  /** Whether to show input suggestions. */
  enablesuggestions?: boolean;
  /** Hint for the keyboard action button. */
  enterkeyhint?: string;
  /** Maximum number of lines for the input. Use for multi-line input. */
  maxlines?: string;
  /** Minimum number of lines for the input. */
  minlines?: string;
  /** Color of the cursor (e.g., '#FF0000', 'red'). */
  cursorcolor?: string;
  /** Color of the text selection highlight (e.g., '#0000FF', 'blue'). */
  selectioncolor?: string;
  /** Character used to obscure text in password mode. */
  obscuringcharacter?: string;
}
/**
 * Properties for <flutter-shadcn-input>
A styled text input field.
@example
```html
<flutter-shadcn-input
  placeholder="Enter your email"
  type="email"
  oninput="handleInput(event)"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnInput
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnInput>
 * ```
 */
export const FlutterShadcnInput = createWebFComponent<FlutterShadcnInputElement, FlutterShadcnInputProps>({
  tagName: 'flutter-shadcn-input',
  displayName: 'FlutterShadcnInput',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'type',
    'disabled',
    'readonly',
    'maxlength',
    'minlength',
    'pattern',
    'required',
    'autofocus',
    'textalign',
    'autocapitalize',
    'autocorrect',
    'enablesuggestions',
    'enterkeyhint',
    'maxlines',
    'minlines',
    'cursorcolor',
    'selectioncolor',
    'obscuringcharacter',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onInput',
      eventName: 'input',
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
    {
      propName: 'onFocus',
      eventName: 'focus',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onBlur',
      eventName: 'blur',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onSubmit',
      eventName: 'submit',
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