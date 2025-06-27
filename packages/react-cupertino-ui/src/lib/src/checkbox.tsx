import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
export interface FlutterCupertinoCheckboxProps {
  /**
   * val property
   * @default undefined
   */
  val?: string;
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
   * checkColor property
   * @default undefined
   */
  checkColor?: string;
  /**
   * focusColor property
   * @default undefined
   */
  focusColor?: string;
  /**
   * fillColorSelected property
   * @default undefined
   */
  fillColorSelected?: string;
  /**
   * fillColorDisabled property
   * @default undefined
   */
  fillColorDisabled?: string;
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoCheckboxElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoCheckbox - WebF FlutterCupertinoCheckbox component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoCheckbox
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoCheckbox>
 * ```
 */
export const FlutterCupertinoCheckbox = createWebFComponent<FlutterCupertinoCheckboxElement, FlutterCupertinoCheckboxProps>({
  tagName: 'flutter-cupertino-checkbox',
  displayName: 'FlutterCupertinoCheckbox',
  // Map props to attributes
  attributeProps: [
    'val',
    'disabled',
    'activeColor',
    'checkColor',
    'focusColor',
    'fillColorSelected',
    'fillColorDisabled',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    activeColor: 'active-color',
    checkColor: 'check-color',
    focusColor: 'focus-color',
    fillColorSelected: 'fill-color-selected',
    fillColorDisabled: 'fill-color-disabled',
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