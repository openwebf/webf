interface WebFTableRowProperties {
  /**
   * Row index
   * @default undefined
   */
  index?: number;
  
  /**
   * Highlight this row
   * @default false
   */
  highlighted?: boolean;
  
  /**
   * Clickable row
   * @default true
   */
  clickable?: boolean;
}

interface WebFTableRowEvents {
  /**
   * Row click event
   */
  click: CustomEvent<{index: number}>;
}