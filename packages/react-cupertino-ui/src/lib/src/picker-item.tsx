import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoPickerItemProps {
  /**
   * label property
   * @default undefined
   */
  label?: string;
  /**
   * val property
   * @default undefined
   */
  val?: string;
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
export interface FlutterCupertinoPickerItemElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoPickerItem - WebF FlutterCupertinoPickerItem component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoPickerItem
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoPickerItem>
 * ```
 */
export const FlutterCupertinoPickerItem = createWebFComponent<FlutterCupertinoPickerItemElement, FlutterCupertinoPickerItemProps>({
  tagName: 'flutter-cupertino-picker-item',
  displayName: 'FlutterCupertinoPickerItem',
  // Map props to attributes
  attributeProps: [
    'label',
    'val',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});