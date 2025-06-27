import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
export interface FlutterCupertinoIconProps {
  /**
   * type property
   * @default undefined
   */
  type?: string;
  /**
   * label property
   * @default undefined
   */
  label?: string;
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
export interface FlutterCupertinoIconElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoIcon - WebF FlutterCupertinoIcon component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoIcon
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoIcon>
 * ```
 */
export const FlutterCupertinoIcon = createWebFComponent<FlutterCupertinoIconElement, FlutterCupertinoIconProps>({
  tagName: 'flutter-cupertino-icon',
  displayName: 'FlutterCupertinoIcon',
  // Map props to attributes
  attributeProps: [
    'type',
    'label',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});