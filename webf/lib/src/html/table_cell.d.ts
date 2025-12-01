/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface WebFTableCellProperties {
  /**
   * Vertical alignment for this specific cell.
   * Overrides the table's defaultVerticalAlignment.
   * - 'top': Align content to the top
   * - 'middle': Center content vertically
   * - 'bottom': Align content to the bottom
   * - 'baseline': Align to baseline
   * - 'fill': Expand to fill cell height
   */
  verticalAlignment?: 'top' | 'middle' | 'bottom' | 'baseline' | 'fill';
  
  /**
   * Fixed column width in pixels when this cell is used in a header.
   * This property is only effective when the cell is inside a WebFTableHeader.
   * @example 150 (for 150px wide column)
   */
  columnWidth?: number;
}
interface WebFTableCellMethods {}
interface WebFTableCellEvents {}
