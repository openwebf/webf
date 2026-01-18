/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-time-picker>
 *
 * A time picker component.
 *
 * @example
 * ```html
 * <flutter-shadcn-time-picker
 *   value="14:30"
 *   placeholder="Select time"
 *   onchange="handleChange(event)"
 * />
 * ```
 */
interface FlutterShadcnTimePickerProperties {
  /**
   * Selected time in HH:mm format.
   */
  value?: string;

  /**
   * Placeholder text when no time is selected.
   */
  placeholder?: string;

  /**
   * Disable the picker.
   */
  disabled?: boolean;

  /**
   * Use 24-hour format.
   * Default: true
   */
  'use-24-hour'?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-time-picker>
 */
interface FlutterShadcnTimePickerEvents {
  /** Fired when time selection changes. */
  change: Event;
}
