interface WebFTableCellProperties {
  /**
   * Text alignment
   * @default "left"
   */
  align?: 'left' | 'center' | 'right';
  
  /**
   * Cell type (header or data)
   * @default "data"
   */
  type?: 'header' | 'data';
  
  /**
   * Column span
   * @default 1
   */
  colspan?: number;
  
  /**
   * Row span
   * @default 1
   */
  rowspan?: number;
  
  /**
   * Cell width
   * @default undefined
   */
  width?: string;
  
  /**
   * Text color based on value
   * @default undefined
   */
  'value-color'?: string;
}

interface WebFTableCellEvents {
  /**
   * Cell click event
   */
  click: CustomEvent<{row: number, column: number, value: any}>;
}