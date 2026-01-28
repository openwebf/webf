/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-switch>
 *
 * A toggle switch control.
 *
 * @example
 * ```html
 * <flutter-shadcn-switch
 *   checked
 *   onchange="handleChange(event)"
 * >
 *   Enable notifications
 * </flutter-shadcn-switch>
 * ```
 */
interface FlutterShadcnSwitchProperties {
  /**
   * Whether the switch is on.
   */
  checked?: boolean;

  /**
   * Disable the switch.
   */
  disabled?: boolean;
}

/**
 * Events emitted by <flutter-shadcn-switch>
 */
interface FlutterShadcnSwitchEvents {
  /** Fired when the switch state changes. */
  change: Event;
}
