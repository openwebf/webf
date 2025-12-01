/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
interface WebFTableProperties {
  /**
   * The text direction for the table content.
   * - 'ltr': Left-to-right text direction
   * - 'rtl': Right-to-left text direction
   * @default 'ltr'
   */
  textDirection?: 'ltr' | 'rtl';

  /**
   * The default vertical alignment for table cells.
   * - 'top': Align content to the top of cells
   * - 'middle': Center content vertically in cells
   * - 'bottom': Align content to the bottom of cells
   * - 'baseline': Align content to the baseline
   * - 'fill': Expand content to fill the cell height
   * @default 'middle'
   */
  defaultVerticalAlignment?: 'top' | 'middle' | 'bottom' | 'baseline' | 'fill';

  /**
   * The default fixed width for all columns in pixels.
   * If not specified, columns will use flex layout by default.
   * @example 120 (for 120px wide columns)
   */
  defaultColumnWidth?: number;

  /**
   * JSON string to configure individual column widths.
   * Format: {"columnIndex": {"type": "fixed", "width": 100}}
   * This property allows fine-grained control over column sizing.
   * @example '{"0": {"type": "fixed", "width": 150}, "1": {"type": "flex", "flex": 2}}'
   */
  columnWidths?: string;

  /**
   * JSON string to configure table borders.
   * When set to any non-empty value, applies borders to all table cells.
   * Future versions will support more detailed border configuration.
   * @example 'all' or '{"all": true}'
   */
  border?: string;

  /**
   * The text baseline for table content alignment.
   * - 'alphabetic': Use alphabetic baseline (for Latin scripts)
   * - 'ideographic': Use ideographic baseline (for CJK scripts)
   * This affects how text is vertically aligned when using baseline alignment.
   * @default 'alphabetic'
   */
  textBaseline?: 'alphabetic' | 'ideographic';
}
interface WebFTableMethods {}
interface WebFTableEvents {}
