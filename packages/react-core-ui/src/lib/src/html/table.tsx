import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFTableMethods {
}
export interface WebFTableProps {
  /**
   * The text direction for the table content.
   * - 'ltr': Left-to-right text direction
   * - 'rtl': Right-to-left text direction
   * @default 'ltr'
   */
  textDirection?: 'ltr' | 'rtl';
  /**
   * The default vertical alignment for table cells.
   * - 'top': Align content to the top of cells
   * - 'middle': Center content vertically in cells
   * - 'bottom': Align content to the bottom of cells
   * - 'baseline': Align content to the baseline
   * - 'fill': Expand content to fill the cell height
   * @default 'middle'
   */
  defaultVerticalAlignment?: 'top' | 'middle' | 'bottom' | 'baseline' | 'fill';
  /**
   * The default column width strategy for the table.
   * - 'flex': Columns expand proportionally to fill available space
   * - 'intrinsic': Columns size based on their content
   * - 'fixed': Columns have a fixed width (100px by default)
   * - 'min': Columns use minimum of fixed and flex widths
   * - 'max': Columns use maximum of fixed and flex widths
   * @default 'flex'
   */
  defaultColumnWidth?: 'flex' | 'intrinsic' | 'fixed' | 'min' | 'max';
  /**
   * JSON string to configure individual column widths.
   * Format: {"columnIndex": {"type": "fixed", "width": 100}}
   * This property allows fine-grained control over column sizing.
   * @example '{"0": {"type": "fixed", "width": 150}, "1": {"type": "flex", "flex": 2}}'
   */
  columnWidths?: string;
  /**
   * JSON string to configure table borders.
   * When set to any non-empty value, applies borders to all table cells.
   * Future versions will support more detailed border configuration.
   * @example 'all' or '{"all": true}'
   */
  border?: string;
  /**
   * The text baseline for table content alignment.
   * - 'alphabetic': Use alphabetic baseline (for Latin scripts)
   * - 'ideographic': Use ideographic baseline (for CJK scripts)
   * This affects how text is vertically aligned when using baseline alignment.
   * @default 'alphabetic'
   */
  textBaseline?: 'alphabetic' | 'ideographic';
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
export interface WebFTableElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFTable - WebF WebFTable component
 * 
 * @example
 * ```tsx
 * 
 * <WebFTable
 *   // Add props here
 * >
 *   Content
 * </WebFTable>
 * ```
 */
export const WebFTable = createWebFComponent<WebFTableElement, WebFTableProps>({
  tagName: 'webf-table',
  displayName: 'WebFTable',
  // Map props to attributes
  attributeProps: [
    'textDirection',
    'defaultVerticalAlignment',
    'defaultColumnWidth',
    'columnWidths',
    'border',
    'textBaseline',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    textDirection: 'text-direction',
    defaultVerticalAlignment: 'default-vertical-alignment',
    defaultColumnWidth: 'default-column-width',
    columnWidths: 'column-widths',
    textBaseline: 'text-baseline',
  },
  // Event handlers
  events: [
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});