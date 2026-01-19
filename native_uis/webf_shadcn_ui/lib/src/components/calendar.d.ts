/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-calendar>
 *
 * A calendar component for date selection with support for single, multiple, and range modes.
 *
 * @example
 * ```html
 * <!-- Single date selection -->
 * <flutter-shadcn-calendar mode="single" value="2024-01-15" />
 *
 * <!-- Multiple date selection -->
 * <flutter-shadcn-calendar mode="multiple" value="2024-01-15,2024-01-20,2024-01-25" />
 *
 * <!-- Date range selection -->
 * <flutter-shadcn-calendar mode="range" value="2024-01-15,2024-01-20" />
 *
 * <!-- With dropdown year/month -->
 * <flutter-shadcn-calendar caption-layout="dropdown" />
 *
 * <!-- Multiple months view -->
 * <flutter-shadcn-calendar number-of-months="2" />
 * ```
 */
interface FlutterShadcnCalendarProperties {
  /**
   * Selection mode.
   * - 'single': Select one date
   * - 'multiple': Select multiple dates (value is comma-separated)
   * - 'range': Select a date range (value is start,end)
   * @default 'single'
   */
  mode?: 'single' | 'multiple' | 'range';

  /**
   * Selected date(s) in ISO format (YYYY-MM-DD).
   * - For single: '2024-01-15'
   * - For multiple: '2024-01-15,2024-01-20,2024-01-25'
   * - For range: '2024-01-15,2024-01-20' (start,end)
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

  /**
   * Caption layout style.
   * - 'label': Default label style
   * - 'dropdown': Both month and year dropdowns
   * - 'dropdown-months': Month dropdown only
   * - 'dropdown-years': Year dropdown only
   * @default 'label'
   */
  captionLayout?: 'label' | 'dropdown' | 'dropdown-months' | 'dropdown-years';

  /**
   * Hide the navigation arrows (prev/next month).
   * @default false
   */
  hideNavigation?: boolean;

  /**
   * Show week numbers column.
   * @default false
   */
  showWeekNumbers?: boolean;

  /**
   * Show days from adjacent months.
   * @default true
   */
  showOutsideDays?: boolean;

  /**
   * Always display 6 weeks for consistent height.
   * @default false
   */
  fixedWeeks?: boolean;

  /**
   * Hide the weekday name headers (Mon, Tue, etc.).
   * @default false
   */
  hideWeekdayNames?: boolean;

  /**
   * Number of months to display simultaneously.
   * @default 1
   */
  numberOfMonths?: number;

  /**
   * Allow deselecting a selected date by clicking it again.
   * Only applies to 'single' selection mode.
   * @default false
   */
  allowDeselection?: boolean;
}

/**
 * Detail for calendar change event.
 */
interface FlutterShadcnCalendarChangeEventDetail {
  /**
   * The selected value.
   * - For single mode: ISO date string (YYYY-MM-DD) or null
   * - For multiple mode: Comma-separated ISO date strings
   * - For range mode: Comma-separated start and end dates
   */
  value: string | null;
}

/**
 * Events emitted by <flutter-shadcn-calendar>
 */
interface FlutterShadcnCalendarEvents {
  /** Fired when date selection changes. Detail contains the selected value. */
  change: CustomEvent<FlutterShadcnCalendarChangeEventDetail>;
}
