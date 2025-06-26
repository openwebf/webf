import React, { useRef, useEffect, useCallback, ReactNode } from 'react';

export interface WebFListViewProps {
  /**
   * The scroll direction for the list view
   * @default 'vertical'
   */
  scrollDirection?: 'vertical' | 'horizontal';

  /**
   * Whether the list should shrink-wrap its contents
   * @default true
   */
  shrinkWrap?: boolean;

  /**
   * Callback triggered when pull-to-refresh is activated
   * Must call finishRefresh() when the refresh operation completes
   */
  onRefresh?: () => void | Promise<void>;

  /**
   * Callback triggered when scrolling near the end of the list
   * Must call finishLoad() when the load operation completes
   */
  onLoadMore?: () => void | Promise<void>;

  /**
   * Children elements to render in the list
   */
  children?: ReactNode;

  /**
   * Additional CSS class names
   */
  className?: string;

  /**
   * Inline styles
   */
  style?: React.CSSProperties;
}

export interface WebFListViewElement extends HTMLElement {
/**
   * Completes a refresh operation with the specified result
   * @param result - The result of the refresh operation: 'success', 'fail', 'noMore', or any other value
   */
  finishRefresh: (result?: 'success' | 'fail' | 'noMore') => void;

  /**
   * Completes a load-more operation with the specified result
   * @param result - The result of the load operation: 'success', 'fail', 'noMore', or any other value
   */
  finishLoad: (result?: 'success' | 'fail' | 'noMore') => void;

  /**
   * Resets the refresh header to its initial state
   */
  resetHeader: () => void;

  /**
   * Resets the load-more footer to its initial state
   */
  resetFooter: () => void;
}

/**
 * WebFListView - A React component that wraps the WebF ListView element
 * 
 * This component provides a scrollable list view with pull-to-refresh and infinite scrolling capabilities.
 * It renders as a custom HTML element that is handled by the WebF framework.
 * 
 * @example
 * ```tsx
 * const listRef = useRef<WebFListViewElement>(null);
 * 
 * const handleRefresh = async () => {
 *   await fetchNewData();
 *   listRef.current?.finishRefresh('success');
 * };
 * 
 * const handleLoadMore = async () => {
 *   const hasMore = await loadMoreData();
 *   listRef.current?.finishLoad(hasMore ? 'success' : 'noMore');
 * };
 * 
 * <WebFListView
 *   ref={listRef}
 *   onRefresh={handleRefresh}
 *   onLoadMore={handleLoadMore}
 * >
 *   {items.map(item => <div key={item.id}>{item.content}</div>)}
 * </WebFListView>
 * ```
 */
export const WebFListView = React.forwardRef<WebFListViewElement, WebFListViewProps>(
  ({ scrollDirection = 'vertical', shrinkWrap = false, onRefresh, onLoadMore, children, className, style }, ref) => {
    const elementRef = useRef<WebFListViewElement>(null);

    // Expose the element ref directly
    React.useImperativeHandle(ref, () => elementRef.current!, []);

    // Handle refresh event
    const handleRefresh = useCallback(() => {
      if (onRefresh) {
        const result = onRefresh();
        if (result instanceof Promise) {
          result.catch(console.error);
        }
      }
    }, [onRefresh]);

    // Handle loadmore event
    const handleLoadMore = useCallback(() => {
      if (onLoadMore) {
        const result = onLoadMore();
        if (result instanceof Promise) {
          result.catch(console.error);
        }
      }
    }, [onLoadMore]);

    // Set up event listeners
    useEffect(() => {
      const element = elementRef.current;
      if (!element) return;

      if (onRefresh) {
        element.addEventListener('refresh', handleRefresh);
      }
      if (onLoadMore) {
        element.addEventListener('loadmore', handleLoadMore);
      }

      return () => {
        if (onRefresh) {
          element.removeEventListener('refresh', handleRefresh);
        }
        if (onLoadMore) {
          element.removeEventListener('loadmore', handleLoadMore);
        }
      };
    }, [handleRefresh, handleLoadMore, onRefresh, onLoadMore]);

    // Compute attributes
    const attributes: Record<string, string> = {
      'scroll-direction': scrollDirection,
      'shrink-wrap': String(shrinkWrap),
    };

    return React.createElement(
      'webf-listview',
      {
        ref: elementRef,
        className,
        style,
        ...attributes,
      },
      children
    );
  }
);

WebFListView.displayName = 'WebFListView';