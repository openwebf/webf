import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoTimerPickerProps {
  /**
   * mode property
   * @default undefined
   */
  mode?: string;
  /**
   * initialTimerDuration property
   * @default undefined
   */
  initialTimerDuration?: number;
  /**
   * minuteInterval property
   * @default undefined
   */
  minuteInterval?: number;
  /**
   * secondInterval property
   * @default undefined
   */
  secondInterval?: number;
  /**
   * backgroundColor property
   * @default undefined
   */
  backgroundColor?: string;
  /**
   * height property
   * @default undefined
   */
  height?: number;
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent<number>) => void;
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
export interface FlutterCupertinoTimerPickerElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoTimerPicker - WebF FlutterCupertinoTimerPicker component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoTimerPicker
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoTimerPicker>
 * ```
 */
export const FlutterCupertinoTimerPicker = createWebFComponent<FlutterCupertinoTimerPickerElement, FlutterCupertinoTimerPickerProps>({
  tagName: 'flutter-cupertino-timer-picker',
  displayName: 'FlutterCupertinoTimerPicker',
  // Map props to attributes
  attributeProps: [
    'mode',
    'initialTimerDuration',
    'minuteInterval',
    'secondInterval',
    'backgroundColor',
    'height',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    initialTimerDuration: 'initial-timer-duration',
    minuteInterval: 'minute-interval',
    secondInterval: 'second-interval',
    backgroundColor: 'background-color',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback) => (event) => {
        callback((event as CustomEvent<number>));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});