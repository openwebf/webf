import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";
export interface FlutterCupertinoModalPopupProps {
  /**
   * visible property
   * @default undefined
   */
  visible?: boolean;
  /**
   * height property
   * @default undefined
   */
  height?: number;
  /**
   * surfacePainted property
   * @default undefined
   */
  surfacePainted?: boolean;
  /**
   * maskClosable property
   * @default undefined
   */
  maskClosable?: boolean;
  /**
   * backgroundOpacity property
   * @default undefined
   */
  backgroundOpacity?: number;
  /**
   * close event handler
   */
  onClose?: (event: CustomEvent) => void;
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
export interface FlutterCupertinoModalPopupElement extends WebFElementWithMethods<{
  show(): void;
  hide(): void;
}> {}
/**
 * FlutterCupertinoModalPopup - WebF FlutterCupertinoModalPopup component
 * 
 * @example
 * ```tsx
 * <FlutterCupertinoModalPopup
 *   // Add example props here
 * >
 *   Content
 * </FlutterCupertinoModalPopup>
 * ```
 */
export const FlutterCupertinoModalPopup = createWebFComponent<FlutterCupertinoModalPopupElement, FlutterCupertinoModalPopupProps>({
  tagName: 'flutter-cupertino-modal-popup',
  displayName: 'FlutterCupertinoModalPopup',
  // Map props to attributes
  attributeProps: [
    'visible',
    'height',
    'surfacePainted',
    'maskClosable',
    'backgroundOpacity',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    surfacePainted: 'surface-painted',
    maskClosable: 'mask-closable',
    backgroundOpacity: 'background-opacity',
  },
  // Event handlers
  events: [
    {
      propName: 'onClose',
      eventName: 'close',
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