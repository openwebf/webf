import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
export interface WebFTableRowProps {
  /**
   * index property
   * @default undefined
   */
  index?: number;
  /**
   * highlighted property
   * @default undefined
   */
  highlighted?: boolean;
  /**
   * clickable property
   * @default undefined
   */
  clickable?: boolean;
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
export interface WebFTableRowElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFTableRow - WebF WebFTableRow component
 * 
 * @example
 * ```tsx
 * <WebFTableRow
 *   // Add example props here
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
    'index',
    'highlighted',
    'clickable',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
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