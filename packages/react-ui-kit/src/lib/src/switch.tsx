import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterSwitchProps {
  /**
   * selected property
   * @default undefined
   */
  selected?: boolean;
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
export interface FlutterSwitchElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterSwitch - WebF FlutterSwitch component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterSwitch
 *   // Add props here
 * >
 *   Content
 * </FlutterSwitch>
 * ```
 */
export const FlutterSwitch = createWebFComponent<FlutterSwitchElement, FlutterSwitchProps>({
  tagName: 'flutter-switch',
  displayName: 'FlutterSwitch',
  // Map props to attributes
  attributeProps: [
    'selected',
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