import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnTextareaProps {
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
  /**
   * Fired on every input change.
   */
  onInput?: (event: Event) => void;
  /**
   * Fired when textarea loses focus.
   */
  onChange?: (event: Event) => void;
  /**
   * Fired when textarea gains focus.
   */
  onFocus?: (event: Event) => void;
  /**
   * Fired when textarea loses focus.
   */
  onBlur?: (event: Event) => void;
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
export interface FlutterShadcnTextareaElement extends WebFElementWithMethods<{
}> {
  /** Current value of the textarea. */
  value?: string;
  /** Placeholder text shown when empty. */
  placeholder?: string;
  /** Number of visible text rows. */
  rows?: string;
  /** Disable the textarea. */
  disabled?: boolean;
  /** Make the textarea read-only. */
  readonly?: boolean;
  /** Maximum length of the input value. */
  maxlength?: string;
  /** Whether the textarea is required. */
  required?: boolean;
  /** Autofocus on mount. */
  autofocus?: boolean;
}
/**
 * Properties for <flutter-shadcn-textarea>
A multi-line text input field.
@example
```html
<flutter-shadcn-textarea
  placeholder="Enter your message..."
  rows="4"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTextarea
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTextarea>
 * ```
 */
export const FlutterShadcnTextarea = createWebFComponent<FlutterShadcnTextareaElement, FlutterShadcnTextareaProps>({
  tagName: 'flutter-shadcn-textarea',
  displayName: 'FlutterShadcnTextarea',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'rows',
    'disabled',
    'readonly',
    'maxlength',
    'required',
    'autofocus',
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
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});