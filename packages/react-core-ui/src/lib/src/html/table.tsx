import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableProps {
  /**
   * Show table borders
   * @default true
   */
  bordered?: boolean;
  /**
   * Striped rows
   * @default false
   */
  striped?: boolean;
  /**
   * Compact table style
   * @default false
   */
  compact?: boolean;
  /**
   * Fixed header when scrolling
   * @default false
   */
  stickyHeader?: boolean;
  /**
   * Hover effect on rows
   * @default false
   */
  hoverable?: boolean;
  /**
   * Table data change event
   */
  onDatachange?: (event: Event) => void;
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
    'bordered',
    'striped',
    'compact',
    'stickyHeader',
    'hoverable',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    stickyHeader: 'sticky-header',
  },
  // Event handlers
  events: [
    {
      propName: 'onDatachange',
      eventName: 'datachange',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
  ],
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});