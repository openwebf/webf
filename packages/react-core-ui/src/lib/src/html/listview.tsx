import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFListViewMethods {
}
export interface WebFListViewProps {
  /**
   * shrinkWrap property
   * @default undefined
   */
  shrinkWrap?: string;
  /**
   * refresh event handler
   */
  onRefresh?: (event: Event) => void;
  /**
   * loadmore event handler
   */
  onLoadmore?: (event: Event) => void;
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
export interface WebFListViewElement extends WebFElementWithMethods<{
}> {}
/**
 * WebFListView - WebF WebFListView component
 * 
 * @example
 * ```tsx
 * <WebFListView
 *   // Add example props here
 * >
 *   Content
 * </WebFListView>
 * ```
 */
export const WebFListView = createWebFComponent<WebFListViewElement, WebFListViewProps>({
  tagName: 'webf-list-view',
  displayName: 'WebFListView',
  // Map props to attributes
  attributeProps: [
    'shrinkWrap',
  ],
  // Convert prop names to attribute names if needed
  attributeMap: {
    shrinkWrap: 'shrink-wrap',
  },
  // Event handlers
  events: [
    {
      propName: 'onRefresh',
      eventName: 'refresh',
      handler: (callback) => (event) => {
        callback((event as Event));
      },
    },
    {
      propName: 'onLoadmore',
      eventName: 'loadmore',
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