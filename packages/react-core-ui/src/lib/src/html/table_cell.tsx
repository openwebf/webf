import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableCellProps {
  /**
   * align property
   * @default undefined
   */
  align?: void;
  /**
   * type property
   * @default undefined
   */
  type?: void;
  /**
   * colspan property
   * @default undefined
   */
  colspan?: number;
  /**
   * rowspan property
   * @default undefined
   */
  rowspan?: number;
  /**
   * width property
   * @default undefined
   */
  width?: string;
  /**
   * valueColor property
   * @default undefined
   */
  valueColor?: string;
  /**
   * click event handler
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
 * <WebFTableCell
 *   // Add example props here
 * >
 *   Content
 * </WebFTableCell>
 * ```
 */
export const WebFTableCell = createWebFComponent<WebFTableCellElement, WebFTableCellProps>({
  tagName: 'web-f-table-cell',
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