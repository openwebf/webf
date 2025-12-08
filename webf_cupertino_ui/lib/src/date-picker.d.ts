/*
 * iOS-style date & time picker.
 *
 * This maps Flutter's `CupertinoDatePicker` into a WebF custom element.
 */

/**
 * Properties for <flutter-cupertino-date-picker>.
 */
interface FlutterCupertinoDatePickerProperties {
  /**
   * Display mode of the picker.
   * - 'time'
   * - 'date'
   * - 'dateAndTime'
   * - 'monthYear'
   * Default: 'dateAndTime'.
   */
  mode?: string;

  /**
   * Minimum selectable date/time, encoded as an ISO8601 string.
   * Example: '2024-01-01T00:00:00.000'.
   */
  'minimum-date'?: string;

  /**
   * Maximum selectable date/time, encoded as an ISO8601 string.
   * Example: '2025-12-31T23:59:59.000'.
   */
  'maximum-date'?: string;

  /**
   * Minimum year in 'date' / 'monthYear' modes.
   * Default: 1.
   */
  'minimum-year'?: int;

  /**
   * Maximum year in 'date' / 'monthYear' modes.
   * When omitted, there is no upper limit.
   */
  'maximum-year'?: int;

  /**
   * Minute interval for the minutes column.
   * Must be a positive factor of 60. Default: 1.
   */
  'minute-interval'?: int;

  /**
   * Whether to use 24-hour format for time display.
   * Default: false (12-hour with AM/PM).
   */
  'use-24-h'?: boolean;

  /**
   * Whether to show the day of week in 'date' mode.
   * Default: false.
   */
  'show-day-of-week'?: boolean;

  /**
   * Initial value of the picker, encoded as an ISO8601 string.
   * When omitted, defaults to `DateTime.now()` at the time of first build.
   */
  value?: string;
}

interface FlutterCupertinoDatePickerMethods {
  /**
   * Imperatively set the current value.
   * The argument must be an ISO8601 string (same format as `value`).
   */
  setValue(value: string): void;
}

interface FlutterCupertinoDatePickerEvents {
  /**
   * Fired whenever the selected date/time changes according to
   * the underlying widget's change reporting behavior.
   * detail = ISO8601 string of the selected DateTime.
   */
  change: CustomEvent<string>;
}

