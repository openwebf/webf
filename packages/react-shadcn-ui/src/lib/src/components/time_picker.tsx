import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnTimePickerProps {
  /**
   * Selected time in HH:mm format.
   */
  value?: string;
  /**
   * Placeholder text when no time is selected.
   */
  placeholder?: string;
  /**
   * Disable the picker.
   */
  disabled?: boolean;
  /**
   * Use 24-hour format.
   * Default: true
   */
  use24Hour?: boolean;
  /**
   * Fired when time selection changes.
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
export interface FlutterShadcnTimePickerElement extends WebFElementWithMethods<{
}> {
  /** Selected time in HH:mm format. */
  value?: string;
  /** Placeholder text when no time is selected. */
  placeholder?: string;
  /** Disable the picker. */
  disabled?: boolean;
  /** Use 24-hour format. */
  use24Hour?: boolean;
}
/**
 * Properties for <flutter-shadcn-time-picker>
A time picker component.
@example
```html
<flutter-shadcn-time-picker
  value="14:30"
  placeholder="Select time"
  onchange="handleChange(event)"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnTimePicker
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnTimePicker>
 * ```
 */
export const FlutterShadcnTimePicker = createWebFComponent<FlutterShadcnTimePickerElement, FlutterShadcnTimePickerProps>({
  tagName: 'flutter-shadcn-time-picker',
  displayName: 'FlutterShadcnTimePicker',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'disabled',
    'use24Hour',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    use24Hour: 'use-24-hour',
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