import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFTableRowMethods {
}
export interface WebFTableRowProps {
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
export interface WebFTableRowElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFTableRow - WebF WebFTableRow component
 * 
 * @example
 * ```tsx
 * 
 * <WebFTableRow
 *   // Add props here
 * >
 *   Content
 * </WebFTableRow>
 * ```
 */
export const WebFTableRow = createWebFComponent<WebFTableRowElement, WebFTableRowProps>({
  tagName: 'webf-table-row',
  displayName: 'WebFTableRow',
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