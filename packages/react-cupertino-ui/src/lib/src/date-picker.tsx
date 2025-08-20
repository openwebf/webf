import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoDatePickerProps {
  /**
   * mode property
   * @default undefined
   */
  mode?: string;
  /**
   * minimumDate property
   * @default undefined
   */
  minimumDate?: string;
  /**
   * maximumDate property
   * @default undefined
   */
  maximumDate?: string;
  /**
   * minuteInterval property
   * @default undefined
   */
  minuteInterval?: string;
  /**
   * value property
   * @default undefined
   */
  value?: string;
  /**
   * minimumYear property
   * @default undefined
   */
  minimumYear?: string;
  /**
   * maximumYear property
   * @default undefined
   */
  maximumYear?: string;
  /**
   * showDayOfWeek property
   * @default undefined
   */
  showDayOfWeek?: string;
  /**
   * dateOrder property
   * @default undefined
   */
  dateOrder?: string;
  /**
   * height property
   * @default undefined
   */
  height?: string;
  /**
   * use24H property
   * @default undefined
   */
  use24H?: boolean;
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent<string>) => void;
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
export interface FlutterCupertinoDatePickerElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoDatePicker - WebF FlutterCupertinoDatePicker component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoDatePicker
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoDatePicker>
 * ```
 */
export const FlutterCupertinoDatePicker = createWebFComponent<FlutterCupertinoDatePickerElement, FlutterCupertinoDatePickerProps>({
  tagName: 'flutter-cupertino-date-picker',
  displayName: 'FlutterCupertinoDatePicker',
  // Map props to attributes
  attributeProps: [
    'mode',
    'minimumDate',
    'maximumDate',
    'minuteInterval',
    'value',
    'minimumYear',
    'maximumYear',
    'showDayOfWeek',
    'dateOrder',
    'height',
    'use24H',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    minimumDate: 'minimum-date',
    maximumDate: 'maximum-date',
    minuteInterval: 'minute-interval',
    minimumYear: 'minimum-year',
    maximumYear: 'maximum-year',
    showDayOfWeek: 'show-day-of-week',
    dateOrder: 'date-order',
    use24H: 'use-24-h',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<string>));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});