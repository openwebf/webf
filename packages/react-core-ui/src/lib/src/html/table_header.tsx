import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFTableHeaderMethods {
}
export interface WebFTableHeaderProps {
  /**
   * Whether this header group should be sticky.
   * When true, this header section remains visible when scrolling.
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
    'sticky',
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