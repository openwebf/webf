/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-progress>
 *
 * A progress indicator component.
 *
 * @example
 * ```html
 * <flutter-shadcn-progress value="60" max="100" />
 * ```
 */
interface FlutterShadcnProgressProperties {
  /**
   * Current progress value.
   */
  value?: string;

  /**
   * Maximum value.
   * Default: 100
   */
  max?: string;

  /**
   * Visual variant.
   * Options: 'default', 'indeterminate'
   * Default: 'default'
   */
  variant?: string;

  /**
   * Background color of the progress track.
   * Accepts hex color string (e.g. '#e0e0e0', '#FF808080').
   */
  backgroundColor?: string;

  /**
   * Color of the progress indicator.
   * Accepts hex color string (e.g. '#3b82f6', '#FF0000FF').
   */
  color?: string;

  /**
   * Minimum height of the progress bar in logical pixels.
   * Default: 16
   */
  minHeight?: string;

  /**
   * Border radius of the progress bar in logical pixels.
   * Applied uniformly to all corners.
   * Default: 16
   */
  borderRadius?: string;
}

interface FlutterShadcnProgressEvents {}
