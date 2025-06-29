import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableHeaderProps {
  /**
   * backgroundColor property
   * @default undefined
   */
  backgroundColor?: string;
  /**
   * color property
   * @default undefined
   */
  color?: string;
  /**
   * sticky property
   * @default undefined
   */
  sticky?: boolean;
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
export interface WebFTableHeaderElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFTableHeader - WebF WebFTableHeader component
 * 
 * @example
 * ```tsx
 * <WebFTableHeader
 *   // Add example props here
 * >
 *   Content
 * </WebFTableHeader>
 * ```
 */
export const WebFTableHeader = createWebFComponent<WebFTableHeaderElement, WebFTableHeaderProps>({
  tagName: 'web-f-table-header',
  displayName: 'WebFTableHeader',
  // Map props to attributes
  attributeProps: [
    'backgroundColor',
    'color',
    'sticky',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    backgroundColor: 'background-color',
  },
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});