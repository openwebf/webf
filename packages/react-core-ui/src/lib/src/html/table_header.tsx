import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableHeaderProps {
  /**
   * Header background color
   * @default undefined
   */
  backgroundColor?: string;
  /**
   * Header text color
   * @default undefined
   */
  color?: string;
  /**
   * Fixed header
   * @default false
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
 * 
 * <WebFTableHeader
 *   // Add props here
 * >
 *   Content
 * </WebFTableHeader>
 * ```
 */
export const WebFTableHeader = createWebFComponent<WebFTableHeaderElement, WebFTableHeaderProps>({
  tagName: 'webf-table-header',
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