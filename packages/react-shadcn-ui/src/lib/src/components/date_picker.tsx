import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
/**
 * Detail for date picker change event.
 */
interface FlutterShadcnDatePickerChangeEventDetail {
  /**
   * The selected date in ISO format (YYYY-MM-DD).
   */
  value: string;
}
export interface FlutterShadcnDatePickerProps {
  /**
   * Selected date in ISO format (YYYY-MM-DD).
   */
  value?: string;
  /**
   * Placeholder text when no date is selected.
   */
  placeholder?: string;
  /**
   * Disable the picker.
   */
  disabled?: boolean;
  /**
   * Date format for display.
   * Default: 'yyyy-MM-dd'
   */
  format?: string;
  /**
   * Fired when date selection changes. Detail contains the selected value.
   */
  onChange?: (event: CustomEvent<FlutterShadcnDatePickerChangeEventDetail>) => void;
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
export interface FlutterShadcnDatePickerElement extends WebFElementWithMethods<{
}> {
  /** Selected date in ISO format (YYYY-MM-DD). */
  value?: string;
  /** Placeholder text when no date is selected. */
  placeholder?: string;
  /** Disable the picker. */
  disabled?: boolean;
  /** Date format for display. */
  format?: string;
}
/**
 * Properties for <flutter-shadcn-date-picker>
A date picker with a popover calendar.
@example
```html
<flutter-shadcn-date-picker
  value="2024-01-15"
  placeholder="Pick a date"
  onchange="handleChange(event)"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnDatePicker
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnDatePicker>
 * ```
 */
export const FlutterShadcnDatePicker = createWebFComponent<FlutterShadcnDatePickerElement, FlutterShadcnDatePickerProps>({
  tagName: 'flutter-shadcn-date-picker',
  displayName: 'FlutterShadcnDatePicker',
  // Map props to attributes
  attributeProps: [
    'value',
    'placeholder',
    'disabled',
    'format',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: CustomEvent<FlutterShadcnDatePickerChangeEventDetail>) => void) => (event: Event) => {
        callback(event as CustomEvent<FlutterShadcnDatePickerChangeEventDetail>);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});