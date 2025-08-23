import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface WebFListviewMaterialMethods {
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}
export interface WebFListviewMaterialProps {
  /**
   * shrinkWrap property
   * @default undefined
   */
  shrinkWrap?: boolean;
  /**
   * refresh event handler
   */
  onRefresh?: (event: Event) => void;
  /**
   * loadmore event handler
   */
  onLoadmore?: (event: Event) => void;
  /**
   * HTML id attribute
   */
  id?: string;
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
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<WebFListviewMaterialElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface WebFListviewMaterialElement extends WebFElementWithMethods<{
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}> {}
/**
 * WebFListviewMaterial - WebF WebFListviewMaterial component
 * 
 * @example
 * ```tsx
 * const ref = useRef<WebFListviewMaterialElement>(null);
 * 
 * <WebFListviewMaterial
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </WebFListviewMaterial>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const WebFListviewMaterial = createWebFComponent<WebFListviewMaterialElement, WebFListviewMaterialProps>({
  tagName: 'webf-listview-material',
  displayName: 'WebFListviewMaterial',
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