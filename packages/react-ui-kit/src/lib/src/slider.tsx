import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterSliderProps {
  /**
   * val property
   * @default undefined
   */
  val?: string;
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
export interface FlutterSliderElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterSlider - WebF FlutterSlider component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterSlider
 *   // Add props here
 * >
 *   Content
 * </FlutterSlider>
 * ```
 */
export const FlutterSlider = createWebFComponent<FlutterSliderElement, FlutterSliderProps>({
  tagName: 'flutter-slider',
  displayName: 'FlutterSlider',
  // Map props to attributes
  attributeProps: [
    'val',
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