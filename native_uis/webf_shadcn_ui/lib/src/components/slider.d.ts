/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-slider>
 *
 * A slider control for selecting a value from a range.
 *
 * @example
 * ```html
 * <flutter-shadcn-slider
 *   value="50"
 *   min="0"
 *   max="100"
 *   step="1"
 *   oninput="handleInput(event)"
 * />
 * ```
 */
interface FlutterShadcnSliderProperties {
  /**
   * Current value of the slider.
   */
  value?: string;

  /**
   * Minimum value.
   * Default: 0
   */
  min?: string;

  /**
   * Maximum value.
   * Default: 100
   */
  max?: string;

  /**
   * Step increment.
   * Default: 1
   */
  step?: string;

  /**
   * Disable the slider.
   */
  disabled?: boolean;

  /**
   * Orientation of the slider.
   * Options: 'horizontal', 'vertical'
   * Default: 'horizontal'
   */
  orientation?: string;
}

/**
 * Events emitted by <flutter-shadcn-slider>
 */
interface FlutterShadcnSliderEvents {
  /** Fired continuously while sliding. */
  input: Event;

  /** Fired when sliding ends. */
  change: Event;
}
