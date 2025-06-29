import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "../../../utils/createWebFComponent";
interface WebFListViewMethods {
  /**
   * Completes a refresh operation with the specified resultThis method finishes the current pull-to-refresh operation and displays
   * the appropriate indicator based on the result parameter.
   * 
   * @param result - The result of the refresh operation, can be:
   *   - 'success': The refresh was successful (default)
   *   - 'fail': The refresh operation failed
   *   - 'noMore': There is no more data to refresh
   *   - Any other value: No specific result indicator is shown
   */
  finishRefresh(result: string): void;
  /**
   * Completes a load-more operation with the specified resultThis method finishes the current load-more operation and displays
   * the appropriate indicator based on the result parameter.
   * 
   * @param result - The result of the load-more operation, can be:
   *   - 'success': The load operation was successful (default)
   *   - 'fail': The load operation failed
   *   - 'noMore': There is no more data to load
   *   - Any other value: No specific result indicator is shown
   */
  finishLoad(result: string): void;
  /**
   * Resets the refresh header to its initial stateThis method programmatically resets the pull-to-refresh header to its
   * initial state, canceling any ongoing refresh operation and hiding any
   * refresh indicators. This is useful when you need to abort a refresh
   * operation without completing it.
   */
  resetHeader(): void;
  /**
   * Resets the load-more footer to its initial stateThis method programmatically resets the load-more footer to its
   * initial state, canceling any ongoing load operation and hiding any
   * load indicators. This is useful when you need to abort a load-more
   * operation without completing it.
   */
  resetFooter(): void;
}
export interface WebFListViewProps {
  /**
   * Whether the ListView should shrink-wrap its contents
   *  true
   */
  shrinkWrap?: boolean;
  /**
   * Fired when pull-to-refresh is triggered
   */
  onRefresh?: (event: Event) => void;
  /**
   * Fired when scrolling near the end of the list (infinite scroll)
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
/**
 * Element interface with methods accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<WebFListViewElement>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
 * ```
 */
export interface WebFListViewElement extends WebFElementWithMethods<{
  /**
   * Completes a refresh operation with the specified resultThis method finishes the current pull-to-refresh operation and displays
   * the appropriate indicator based on the result parameter.
   * 
   * @param result - The result of the refresh operation, can be:
   *   - 'success': The refresh was successful (default)
   *   - 'fail': The refresh operation failed
   *   - 'noMore': There is no more data to refresh
   *   - Any other value: No specific result indicator is shown
   */
  finishRefresh(result: string): void;
  /**
   * Completes a load-more operation with the specified resultThis method finishes the current load-more operation and displays
   * the appropriate indicator based on the result parameter.
   * 
   * @param result - The result of the load-more operation, can be:
   *   - 'success': The load operation was successful (default)
   *   - 'fail': The load operation failed
   *   - 'noMore': There is no more data to load
   *   - Any other value: No specific result indicator is shown
   */
  finishLoad(result: string): void;
  /**
   * Resets the refresh header to its initial stateThis method programmatically resets the pull-to-refresh header to its
   * initial state, canceling any ongoing refresh operation and hiding any
   * refresh indicators. This is useful when you need to abort a refresh
   * operation without completing it.
   */
  resetHeader(): void;
  /**
   * Resets the load-more footer to its initial stateThis method programmatically resets the load-more footer to its
   * initial state, canceling any ongoing load operation and hiding any
   * load indicators. This is useful when you need to abort a load-more
   * operation without completing it.
   */
  resetFooter(): void;
}> {}
/**
 * A custom element that renders a Flutter ListView in WebFThis element implements a scrollable list view that can be used in HTML with
either the  or  tag names. It supports common list
features like:
- Vertical or horizontal scrolling
- Pull-to-refresh functionality
- Infinite scrolling with load-more capabilities
- Proper handling of absolute/fixed positioned childrenThe element supports these JavaScript events:
- 'refresh': Triggered when pull-to-refresh is activated
- 'loadmore': Triggered when scrolling near the end of the list
 * 
 * @example
 * ```tsx
 * const ref = useRef<WebFListViewElement>(null);
 * 
 * <WebFListView
 *   ref={ref}
 *   // Add props here
 * >
 *   Content
 * </WebFListView>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
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