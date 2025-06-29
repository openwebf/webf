import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface FlutterCupertinoSliderMethods {
  getValue(): number;
  setValue(val: number): void;
}
export interface FlutterCupertinoSliderProps {
  /**
   * val property
   * @default undefined
   */
  val?: number;
  /**
   * min property
   * @default undefined
   */
  min?: number;
  /**
   * max property
   * @default undefined
   */
  max?: number;
  /**
   * step property
   * @default undefined
   */
  step?: number;
  /**
   * disabled property
   * @default undefined
   */
  disabled?: boolean;
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent) => void;
  /**
   * changestart event handler
   */
  onChangestart?: (event: CustomEvent) => void;
  /**
   * changeend event handler
   */
  onChangeend?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoSliderElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoSlider - WebF FlutterCupertinoSlider component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoSlider
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoSlider>
 * ```
 */
export const FlutterCupertinoSlider = createWebFComponent<FlutterCupertinoSliderElement, FlutterCupertinoSliderProps>({
  tagName: 'flutter-cupertino-slider',
  displayName: 'FlutterCupertinoSlider',
  // Map props to attributes
  attributeProps: [
    'val',
    'min',
    'max',
    'step',
    'disabled',
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
    {
      propName: 'onChangestart',
      eventName: 'changestart',
      handler: (callback) => (event) => {
        callback((event as CustomEvent));
      },
    },
    {
      propName: 'onChangeend',
      eventName: 'changeend',
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