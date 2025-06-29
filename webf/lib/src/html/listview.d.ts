interface WebFListViewProperties {
  /**
   * Whether the ListView should shrink-wrap its contents
   * @default "true"
   */
  'shrink-wrap'?: string;
}

interface WebFListViewMethods {
  /**
   * Complete a pull-to-refresh operation
   * @param result - The result of the refresh operation: "success", "fail", "noMore", or any other value
   */
  finishRefresh(result?: string): void;
  
  /**
   * Complete a load-more operation
   * @param result - The result of the load operation: "success", "fail", "noMore", or any other value
   */
  finishLoad(result?: string): void;
  
  /**
   * Reset the refresh header to its initial state
   */
  resetHeader(): void;
  
  /**
   * Reset the load-more footer to its initial state
   */
  resetFooter(): void;
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