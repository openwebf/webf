/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-calendar>
 *
 * A calendar component for date selection.
 *
 * @example
 * ```html
 * <flutter-shadcn-calendar mode="single" value="2024-01-15" onchange="handleDateChange(event)" />
 * ```
 */
interface FlutterShadcnCalendarProperties {
  /**
   * Selection mode.
   * - 'single': Select one date
   * - 'multiple': Select multiple dates
   * - 'range': Select a date range
   * Default: 'single'
   */
  mode?: string;

  /**
   * Selected date(s) in ISO format (YYYY-MM-DD).
   * For multiple: comma-separated, for range: startDate,endDate
   */
  value?: string;

  /**
   * Disable the calendar.
   */
  disabled?: boolean;

  /**
   * Minimum selectable date (YYYY-MM-DD).
   */
  min?: string;

  /**
   * Maximum selectable date (YYYY-MM-DD).
   */
  max?: string;
}

/**
 * Events emitted by <flutter-shadcn-calendar>
 */
interface FlutterShadcnCalendarEvents {
  /** Fired when date selection changes. */
  change: Event;
}
