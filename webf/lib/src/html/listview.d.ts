/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/**
 * A custom element that renders a Flutter ListView in WebF
 *
 * This element implements a scrollable list view that can be used in HTML with
 * either the <LISTVIEW> or <WEBF-LISTVIEW> tag names. It supports common list
 * features like:
 * - Vertical or horizontal scrolling
 * - Pull-to-refresh functionality
 * - Infinite scrolling with load-more capabilities
 * - Proper handling of absolute/fixed positioned children
 *
 * The element supports these JavaScript events:
 * - 'refresh': Triggered when pull-to-refresh is activated
 * - 'loadmore': Triggered when scrolling near the end of the list
 */
interface WebFListViewProperties {
  /**
   * Whether the ListView should shrink-wrap its contents
   * @default true
   */
  'shrink-wrap'?: boolean;

  /**
   * Whether the ListView should shrink-wrap its contents
   * @default true
  */
  'scroll-direction'?: 'horizontal' | 'vertical';
}

interface WebFListViewMethods {
  /**
   * Completes a refresh operation with the specified result
   *
   * This method finishes the current pull-to-refresh operation and displays
   * the appropriate indicator based on the result parameter.
   *
   * @param result - The result of the refresh operation, can be:
   *   - 'success': The refresh was successful (default)
   *   - 'fail': The refresh operation failed
   *   - 'noMore': There is no more data to refresh
   *   - Any other value: No specific result indicator is shown
   */
  finishRefresh(result?: string): void;

  /**
   * Completes a load-more operation with the specified result
   *
   * This method finishes the current load-more operation and displays
   * the appropriate indicator based on the result parameter.
   *
   * @param result - The result of the load-more operation, can be:
   *   - 'success': The load operation was successful (default)
   *   - 'fail': The load operation failed
   *   - 'noMore': There is no more data to load
   *   - Any other value: No specific result indicator is shown
   */
  finishLoad(result?: string): void;

  /**
   * Resets the refresh header to its initial state
   *
   * This method programmatically resets the pull-to-refresh header to its
   * initial state, canceling any ongoing refresh operation and hiding any
   * refresh indicators. This is useful when you need to abort a refresh
   * operation without completing it.
   */
  resetHeader(): void;

  /**
   * Resets the load-more footer to its initial state
   *
   * This method programmatically resets the load-more footer to its
   * initial state, canceling any ongoing load operation and hiding any
   * load indicators. This is useful when you need to abort a load-more
   * operation without completing it.
   */
  resetFooter(): void;

  /**
   * Scrolls the ListView until the child at `index` is visible.
   *
   * This method is intended for lazily-built lists where the total scroll extent
   * can't be known up front. To scroll to the bottom, call with the last index:
   * `await el.scrollByIndex(el.children.length - 1)`.
   *
   * @returns `true` if the target item was found and scrolled into view.
   */
  scrollByIndex(
    index: number,
    options?: {
      /**
       * Whether to animate the scroll.
       * @default true
       */
      animated?: boolean;
      /**
       * Animation duration in milliseconds.
       * @default 250
       */
      duration?: number;
      /**
       * Alignment within viewport, from 0.0 (start) to 1.0 (end).
       * If omitted, defaults to 1.0 for the last index, otherwise 0.0.
       */
      alignment?: number;
    }
  ): Promise<boolean>;
}

interface WebFListViewEvents {
  /**
   * Fired when pull-to-refresh is triggered
   */
  refresh: Event;

  /**
   * Fired when scrolling near the end of the list (infinite scroll)
   */
  loadmore: Event;
}
