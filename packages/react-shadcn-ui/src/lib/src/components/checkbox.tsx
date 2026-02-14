import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnCheckboxProps {
  /**
   * Whether the checkbox is checked.
   */
  checked?: boolean;
  /**
   * Disable the checkbox.
   */
  disabled?: boolean;
  /**
   * Show indeterminate state (neither checked nor unchecked).
   */
  indeterminate?: boolean;
  /**
   * Fired when the checked state changes.
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
export interface FlutterShadcnCheckboxElement extends WebFElementWithMethods<{
}> {
  /** Whether the checkbox is checked. */
  checked?: boolean;
  /** Disable the checkbox. */
  disabled?: boolean;
  /** Show indeterminate state (neither checked nor unchecked). */
  indeterminate?: boolean;
}
/**
 * Properties for <flutter-shadcn-checkbox>
A checkbox control for boolean input.
@example
```html
<flutter-shadcn-checkbox
  checked
  onchange="handleChange(event)"
>
  Accept terms and conditions
</flutter-shadcn-checkbox>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnCheckbox
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnCheckbox>
 * ```
 */
export const FlutterShadcnCheckbox = createWebFComponent<FlutterShadcnCheckboxElement, FlutterShadcnCheckboxProps>({
  tagName: 'flutter-shadcn-checkbox',
  displayName: 'FlutterShadcnCheckbox',
  // Map props to attributes
  attributeProps: [
    'checked',
    'disabled',
    'indeterminate',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
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