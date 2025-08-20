import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
type int = number;
export interface FlutterCupertinoTabProps {
  /**
   * change event handler
   */
  onChange?: (event: CustomEvent<number>) => void;
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
export interface FlutterCupertinoTabElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoTab - WebF FlutterCupertinoTab component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoTab
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoTab>
 * ```
 */
export const FlutterCupertinoTab = createWebFComponent<FlutterCupertinoTabElement, FlutterCupertinoTabProps>({
  tagName: 'flutter-cupertino-tab',
  displayName: 'FlutterCupertinoTab',
  // Map props to attributes
  attributeProps: [
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
        callback((event as CustomEvent<number>));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
export interface FlutterCupertinoTabItemProps {
  /**
   * title property
   * @default undefined
   */
  title?: string;
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
export interface FlutterCupertinoTabItemElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterCupertinoTabItem - WebF FlutterCupertinoTabItem component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterCupertinoTabItem
 *   // Add props here
 * >
 *   Content
 * </FlutterCupertinoTabItem>
 * ```
 */
export const FlutterCupertinoTabItem = createWebFComponent<FlutterCupertinoTabItemElement, FlutterCupertinoTabItemProps>({
  tagName: 'flutter-cupertino-tab-item',
  displayName: 'FlutterCupertinoTabItem',
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