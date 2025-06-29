import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableProps {
  /**
   * bordered property
   * @default undefined
   */
  bordered?: boolean;
  /**
   * striped property
   * @default undefined
   */
  striped?: boolean;
  /**
   * compact property
   * @default undefined
   */
  compact?: boolean;
  /**
   * stickyHeader property
   * @default undefined
   */
  stickyHeader?: boolean;
  /**
   * hoverable property
   * @default undefined
   */
  hoverable?: boolean;
  /**
   * datachange event handler
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
 * <WebFTable
 *   // Add example props here
 * >
 *   Content
 * </WebFTable>
 * ```
 */
export const WebFTable = createWebFComponent<WebFTableElement, WebFTableProps>({
  tagName: 'web-f-table',
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