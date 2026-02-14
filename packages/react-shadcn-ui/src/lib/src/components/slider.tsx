import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
import * as __webfTypes from "../../../types";
export interface FlutterShadcnSliderProps {
  /**
   * Current value of the slider.
   */
  value?: string;
  /**
   * Minimum value.
   * Default: 0
   */
  min?: string;
  /**
   * Maximum value.
   * Default: 100
   */
  max?: string;
  /**
   * Step increment.
   * Default: 1
   */
  step?: string;
  /**
   * Disable the slider.
   */
  disabled?: boolean;
  /**
   * Orientation of the slider.
   * Options: 'horizontal', 'vertical'
   * Default: 'horizontal'
   */
  orientation?: string;
  /**
   * Fired continuously while sliding.
   */
  onInput?: (event: Event) => void;
  /**
   * Fired when sliding ends.
   */
  onChange?: (event: Event) => void;
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
export interface FlutterShadcnSliderElement extends WebFElementWithMethods<{
}> {
  /** Current value of the slider. */
  value?: string;
  /** Minimum value. */
  min?: string;
  /** Maximum value. */
  max?: string;
  /** Step increment. */
  step?: string;
  /** Disable the slider. */
  disabled?: boolean;
  /** Orientation of the slider. */
  orientation?: string;
}
/**
 * Properties for <flutter-shadcn-slider>
A slider control for selecting a value from a range.
@example
```html
<flutter-shadcn-slider
  value="50"
  min="0"
  max="100"
  step="1"
  oninput="handleInput(event)"
/>
```
 * 
 * @example
 * ```tsx
 * 
 * <FlutterShadcnSlider
 *   // Add props here
 * >
 *   Content
 * </FlutterShadcnSlider>
 * ```
 */
export const FlutterShadcnSlider = createWebFComponent<FlutterShadcnSliderElement, FlutterShadcnSliderProps>({
  tagName: 'flutter-shadcn-slider',
  displayName: 'FlutterShadcnSlider',
  // Map props to attributes
  attributeProps: [
    'value',
    'min',
    'max',
    'step',
    'disabled',
    'orientation',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onInput',
      eventName: 'input',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
    {
      propName: 'onChange',
      eventName: 'change',
      handler: (callback: (event: Event) => void) => (event: Event) => {
        callback(event as Event);
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});