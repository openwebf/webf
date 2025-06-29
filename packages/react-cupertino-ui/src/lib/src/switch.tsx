import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterCupertinoSwitchProps {
  /**
   * checked property
   * @default undefined
   */
  checked?: boolean;
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
   * inactiveColor property
   * @default undefined
   */
  inactiveColor?: string;
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
export interface FlutterCupertinoSwitchElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoSwitch - WebF FlutterCupertinoSwitch component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoSwitch
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoSwitch>
 * ```
 */
export const FlutterCupertinoSwitch = createWebFComponent<FlutterCupertinoSwitchElement, FlutterCupertinoSwitchProps>({
  tagName: 'flutter-cupertino-switch',
  displayName: 'FlutterCupertinoSwitch',
  // Map props to attributes
  attributeProps: [
    'checked',
    'disabled',
    'activeColor',
    'inactiveColor',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    activeColor: 'active-color',
    inactiveColor: 'inactive-color',
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