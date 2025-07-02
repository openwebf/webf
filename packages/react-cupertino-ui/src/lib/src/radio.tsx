import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoRadioProps {
  /**
   * val property
   * @default undefined
   */
  val?: string;
  /**
   * groupValue property
   * @default undefined
   */
  groupValue?: string;
  /**
   * useCheckmarkStyle property
   * @default undefined
   */
  useCheckmarkStyle?: boolean;
  /**
   * disabled property
   * @default undefined
   */
  disabled?: boolean;
  /**
   * activeColor property
   * @default undefined
   */
  activeColor?: string;
  /**
   * focusColor property
   * @default undefined
   */
  focusColor?: string;
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
export interface FlutterCupertinoRadioElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoRadio - WebF FlutterCupertinoRadio component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoRadio
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoRadio>
 * ```
 */
export const FlutterCupertinoRadio = createWebFComponent<FlutterCupertinoRadioElement, FlutterCupertinoRadioProps>({
  tagName: 'flutter-cupertino-radio',
  displayName: 'FlutterCupertinoRadio',
  // Map props to attributes
  attributeProps: [
    'val',
    'groupValue',
    'useCheckmarkStyle',
    'disabled',
    'activeColor',
    'focusColor',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    groupValue: 'group-value',
    useCheckmarkStyle: 'use-checkmark-style',
    activeColor: 'active-color',
    focusColor: 'focus-color',
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