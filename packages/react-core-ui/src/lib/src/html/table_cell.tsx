import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableCellProps {
  /**
   * Text alignment
   * @default "left"
   */
  align?: 'left' | 'center' | 'right';
  /**
   * Cell type (header or data)
   * @default "data"
   */
  type?: 'header' | 'data';
  /**
   * Column span
   * @default 1
   */
  colspan?: number;
  /**
   * Row span
   * @default 1
   */
  rowspan?: number;
  /**
   * Cell width
   * @default undefined
   */
  width?: string;
  /**
   * Text color based on value
   * @default undefined
   */
  valueColor?: string;
  /**
   * Cell click event
   */
  onClick?: (event: CustomEvent) => void;
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
    'align',
    'type',
    'colspan',
    'rowspan',
    'width',
    'valueColor',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    valueColor: 'value-color',
  },
  // Event handlers
  events: [
    {
      propName: 'onClick',
      eventName: 'click',
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