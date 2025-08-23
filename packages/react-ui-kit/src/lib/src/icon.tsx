import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterIconProps {
  /**
   * type property
   */
  type: string;
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
export interface FlutterIconElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterIcon - WebF FlutterIcon component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterIcon
 *   // Add props here
 * >
 *   Content
 * </FlutterIcon>
 * ```
 */
export const FlutterIcon = createWebFComponent<FlutterIconElement, FlutterIconProps>({
  tagName: 'flutter-icon',
  displayName: 'FlutterIcon',
  // Map props to attributes
  attributeProps: [
    'type',
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