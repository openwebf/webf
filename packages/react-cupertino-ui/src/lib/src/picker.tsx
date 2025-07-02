import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoPickerProps {
  /**
   * height property
   * @default undefined
   */
  height?: number;
  /**
   * itemHeight property
   * @default undefined
   */
  itemHeight?: number;
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoPickerElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoPicker - WebF FlutterCupertinoPicker component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoPicker
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoPicker>
 * ```
 */
export const FlutterCupertinoPicker = createWebFComponent<FlutterCupertinoPickerElement, FlutterCupertinoPickerProps>({
  tagName: 'flutter-cupertino-picker',
  displayName: 'FlutterCupertinoPicker',
  // Map props to attributes
  attributeProps: [
    'height',
    'itemHeight',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    itemHeight: 'item-height',
  },
  // Event handlers
  events: [
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});