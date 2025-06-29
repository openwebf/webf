interface WebFTableProperties {
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
  'sticky-header'?: boolean;
  
  /**
   * Hover effect on rows
   * @default false
   */
  hoverable?: boolean;
}

interface WebFTableEvents {
  /**
   * Table data change event
   */
  datachange: Event;
}