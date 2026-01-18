/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-button>
 *
 * A versatile button component with multiple variants and sizes.
 *
 * @example
 * ```html
 * <flutter-shadcn-button variant="default" size="default">
 *   Click me
 * </flutter-shadcn-button>
 * ```
 */
interface FlutterShadcnButtonProperties {
  /**
   * Visual variant of the button.
   * - 'default': Primary filled button
   * - 'secondary': Secondary muted button
   * - 'destructive': Red destructive action button
   * - 'outline': Bordered outline button
   * - 'ghost': Transparent with hover effect
   * - 'link': Text link style button
   * Default: 'default'
   */
  variant?: string;

  /**
   * Size of the button.
   * - 'default': Standard size
   * - 'sm': Small size
   * - 'lg': Large size
   * - 'icon': Square icon-only button
   * Default: 'default'
   */
  size?: string;

  /**
   * Disable button interactions.
   */
  disabled?: boolean;

  /**
   * Show loading spinner and disable interactions.
   */
  loading?: boolean;

  /**
   * Icon name to show before the button text.
   */
  icon?: string;
}

/**
 * Events emitted by <flutter-shadcn-button>
 */
interface FlutterShadcnButtonEvents {
  /** Fired when the button is pressed (not emitted when disabled or loading). */
  click: Event;
}
