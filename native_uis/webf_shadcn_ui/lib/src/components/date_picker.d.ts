/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-date-picker>
 *
 * A date picker with a popover calendar.
 *
 * @example
 * ```html
 * <flutter-shadcn-date-picker
 *   value="2024-01-15"
 *   placeholder="Pick a date"
 *   onchange="handleChange(event)"
 * />
 * ```
 */
interface FlutterShadcnDatePickerProperties {
  /**
   * Selected date in ISO format (YYYY-MM-DD).
   */
  value?: string;

  /**
   * Placeholder text when no date is selected.
   */
  placeholder?: string;

  /**
   * Disable the picker.
   */
  disabled?: boolean;

  /**
   * Date format for display.
   * Default: 'yyyy-MM-dd'
   */
  format?: string;
}

/**
 * Events emitted by <flutter-shadcn-date-picker>
 */
interface FlutterShadcnDatePickerEvents {
  /** Fired when date selection changes. */
  change: Event;
}
