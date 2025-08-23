import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";
interface WebFListviewCupertinoMethods {
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}
export interface WebFListviewCupertinoProps {
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
 * const ref = useRef<WebFListviewCupertinoElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface WebFListviewCupertinoElement extends WebFElementWithMethods<{
  finishRefresh(result: 'success' | 'fail' | 'noMore'): void;
  finishLoadMore(result: 'success' | 'fail' | 'noMore'): void;
}> {}
/**
 * WebFListviewCupertino - WebF WebFListviewCupertino component
 * 
 * @example
 * ```tsx
 * const ref = useRef<WebFListviewCupertinoElement>(null);
 * 
 * <WebFListviewCupertino
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </WebFListviewCupertino>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export const WebFListviewCupertino = createWebFComponent<WebFListviewCupertinoElement, WebFListviewCupertinoProps>({
  tagName: 'webf-listview-cupertino',
  displayName: 'WebFListviewCupertino',
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