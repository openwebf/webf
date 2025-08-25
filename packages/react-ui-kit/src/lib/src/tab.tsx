import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterTabProps {
  /**
   * tabchange event handler
   */
  onTabchange?: (event: CustomEvent) => void;
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
export interface FlutterTabElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterTab - WebF FlutterTab component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterTab
 *   // Add props here
 * >
 *   Content
 * </FlutterTab>
 * ```
 */
export const FlutterTab = createWebFComponent<FlutterTabElement, FlutterTabProps>({
  tagName: 'flutter-tab',
  displayName: 'FlutterTab',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
    {
      propName: 'onTabchange',
      eventName: 'tabchange',
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
export interface FlutterTabItemProps {
  /**
   * title property
   */
  title: string;
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
export interface FlutterTabItemElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterTabItem - WebF FlutterTabItem component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterTabItem
 *   // Add props here
 * >
 *   Content
 * </FlutterTabItem>
 * ```
 */
export const FlutterTabItem = createWebFComponent<FlutterTabItemElement, FlutterTabItemProps>({
  tagName: 'flutter-tab-item',
  displayName: 'FlutterTabItem',
  // Map props to attributes
  attributeProps: [
    'title',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});