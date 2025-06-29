import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFTableCellMethods {
}
export interface WebFTableCellProps {
  /**
   * Vertical alignment for this specific cell.
   * Overrides the table's defaultVerticalAlignment.
   * - 'top': Align content to the top
   * - 'middle': Center content vertically
   * - 'bottom': Align content to the bottom
   * - 'baseline': Align to baseline
   * - 'fill': Expand to fill cell height
   */
  verticalAlignment?: 'top' | 'middle' | 'bottom' | 'baseline' | 'fill';
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
export interface WebFTableCellElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFTableCell - WebF WebFTableCell component
 * 
 * @example
 * ```tsx
 * 
 * <WebFTableCell
 *   // Add props here
 * >
 *   Content
 * </WebFTableCell>
 * ```
 */
export const WebFTableCell = createWebFComponent<WebFTableCellElement, WebFTableCellProps>({
  tagName: 'webf-table-cell',
  displayName: 'WebFTableCell',
  // Map props to attributes
  attributeProps: [
    'verticalAlignment',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    verticalAlignment: 'vertical-alignment',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});