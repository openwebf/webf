import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
export interface FlutterCupertinoButtonProps {
  /**
   * variant property
   * @default undefined
   */
  variant?: string;
  /**
   * size property
   * @default undefined
   */
  size?: string;
  /**
   * disabled property
   * @default undefined
   */
  disabled?: boolean;
  /**
   * pressedOpacity property
   * @default undefined
   */
  pressedOpacity?: string;
  /**
   * click event handler
   */
  onClick?: (event: Event) => void;
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
export interface FlutterCupertinoButtonElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoButton - WebF FlutterCupertinoButton component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoButton
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoButton>
 * ```
 */
export const FlutterCupertinoButton = createWebFComponent<FlutterCupertinoButtonElement, FlutterCupertinoButtonProps>({
  tagName: 'flutter-cupertino-button',
  displayName: 'FlutterCupertinoButton',
  // Map props to attributes
  attributeProps: [
    'variant',
    'size',
    'disabled',
    'pressedOpacity',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    pressedOpacity: 'pressed-opacity',
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
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