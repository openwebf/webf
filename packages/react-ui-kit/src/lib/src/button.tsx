import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterButtonProps {
  /**
   * press event handler
   */
  onPress?: (event: Event) => void;
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
export interface FlutterButtonElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterButton - WebF FlutterButton component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterButton
 *   // Add props here
 * >
 *   Content
 * </FlutterButton>
 * ```
 */
export const FlutterButton = createWebFComponent<FlutterButtonElement, FlutterButtonProps>({
  tagName: 'flutter-button',
  displayName: 'FlutterButton',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onPress',
      eventName: 'press',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});