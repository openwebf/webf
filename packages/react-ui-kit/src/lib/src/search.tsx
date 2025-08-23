import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
export interface FlutterSearchProps {
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
export interface FlutterSearchElement extends WebFElementWithMethods<{
}> {}
/**
 * FlutterSearch - WebF FlutterSearch component
 * 
 * @example
 * ```tsx
 * 
 * <FlutterSearch
 *   // Add props here
 * >
 *   Content
 * </FlutterSearch>
 * ```
 */
export const FlutterSearch = createWebFComponent<FlutterSearchElement, FlutterSearchProps>({
  tagName: 'flutter-search',
  displayName: 'FlutterSearch',
  // Map props to attributes
  attributeProps: [
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});