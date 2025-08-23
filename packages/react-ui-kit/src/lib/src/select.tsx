import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterSelectProps {
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
export interface FlutterSelectElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterSelect - WebF FlutterSelect component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterSelect
 *   // Add props here
 * >
 *   Content
 * </FlutterSelect>
 * ```
 */
export const FlutterSelect = createWebFComponent<FlutterSelectElement, FlutterSelectProps>({
  tagName: 'flutter-select',
  displayName: 'FlutterSelect',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
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