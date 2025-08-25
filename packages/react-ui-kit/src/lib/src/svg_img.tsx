import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterSVGImgProps {
  /**
   * src property
   */
  src: string;
  /**
   * width property
   * @default undefined
   */
  width?: '4' | '0';
  /**
   * height property
   * @default undefined
   */
  height?: '4' | '0';
  /**
   * naturalWidth property
   * @default undefined
   */
  naturalWidth?: number;
  /**
   * naturalHeight property
   * @default undefined
   */
  naturalHeight?: number;
  /**
   * complete property
   * @default undefined
   */
  complete?: boolean;
  /**
   * load event handler
   */
  onLoad?: (event: Event) => void;
  /**
   * error event handler
   */
  onError?: (event: Event) => void;
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
export interface FlutterSVGImgElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterSVGImg - WebF FlutterSVGImg component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterSVGImg
 *   // Add props here
 * >
 *   Content
 * </FlutterSVGImg>
 * ```
 */
export const FlutterSVGImg = createWebFComponent<FlutterSVGImgElement, FlutterSVGImgProps>({
  tagName: 'flutter-svg-img',
  displayName: 'FlutterSVGImg',
  // Map props to attributes
  attributeProps: [
    'src',
    'width',
    'height',
    'naturalWidth',
    'naturalHeight',
    'complete',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    naturalWidth: 'natural-width',
    naturalHeight: 'natural-height',
  },
  // Event handlers
  events: [
    {
      propName: 'onLoad',
      eventName: 'load',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
    {
      propName: 'onError',
      eventName: 'error',
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