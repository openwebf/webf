/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

/**
 * Properties for <flutter-shadcn-theme>
 *
 * Theme provider element that wraps content with shadcn_ui theming.
 * Use this as a root element to provide consistent theming to all
 * shadcn components within.
 *
 * @example
 * ```html
 * <flutter-shadcn-theme color-scheme="blue" brightness="light">
 *   <flutter-shadcn-button variant="default">Click me</flutter-shadcn-button>
 * </flutter-shadcn-theme>
 * ```
 */
interface FlutterShadcnThemeProperties {
  /**
   * The color scheme to use for theming.
   * Available options: 'blue', 'gray', 'green', 'neutral', 'orange',
   * 'red', 'rose', 'slate', 'stone', 'violet', 'yellow', 'zinc'.
   * Default: 'zinc'
   */
  'color-scheme'?: string;

  /**
   * The brightness mode for the theme.
   * - 'light': Light mode
   * - 'dark': Dark mode
   * - 'system': Follow system preference
   * Default: 'system'
   */
  brightness?: string;

  /**
   * Radius multiplier for border radius values.
   * Default: 0.5
   */
  radius?: string;

  /**
   * Focus outline/ring color used by inputs and other focusable controls.
   * Supports hex colors like '#2563eb' or '#FF2563EB'.
   * Default: uses the active color scheme ring color.
   */
  'outline-color'?: string;
}

interface FlutterShadcnThemeEvents {}
