/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-checkbox>
 *
 * A checkbox control for boolean input.
 *
 * @example
 * ```html
 * <flutter-shadcn-checkbox
 *   checked
 *   onchange="handleChange(event)"
 * >
 *   Accept terms and conditions
 * </flutter-shadcn-checkbox>
 * ```
 */
interface FlutterShadcnCheckboxProperties {
  /**
   * Whether the checkbox is checked.
   */
  checked?: boolean;

  /**
   * Disable the checkbox.
   */
  disabled?: boolean;

  /**
   * Show indeterminate state (neither checked nor unchecked).
   */
  indeterminate?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-checkbox>
 */
interface FlutterShadcnCheckboxEvents {
  /** Fired when the checked state changes. */
  change: Event;
}
